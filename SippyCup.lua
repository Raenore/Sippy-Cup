-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local L = SIPPYCUP.L;

---ADDON_LOADED initializes addon on matching name.
function SIPPYCUP_Addon:ADDON_LOADED(_, addonName)
	if addonName == "SippyCup" then
		SIPPYCUP.Events:UnregisterEvent("ADDON_LOADED");
		self:OnInitialize();
	end
end

---OnInitialize runs during ADDON_LOADED, load saved variables and set up slash commands.
function SIPPYCUP_Addon:OnInitialize()
	if not SippyCupDB then
		SippyCupDB = {
			global = {},
			profileKeys = {},
			profiles = {},
		};
	end

	SIPPYCUP.db = SippyCupDB;

	-- Set up DB internals
	SIPPYCUP.Database.Setup();

	-- Register slash commands
	SLASH_SIPPYCUP1, SLASH_SIPPYCUP2 = "/sc", "/sippycup";
	SlashCmdList["SIPPYCUP"] = function(msg)
		msg = (msg:match("^%s*(.-)%s*$") or ""):lower();

		if msg == "auras" and SIPPYCUP.IS_DEV_BUILD then
			SIPPYCUP.Auras.DebugEnabledAuras();
		else
			SIPPYCUP_Addon:OpenSettings();
		end
	end
end

---PLAYER_LOGIN triggers the addon OnEnable phase after the UI is fully loaded.
function SIPPYCUP_Addon:PLAYER_LOGIN()
	self:OnEnable();

	SIPPYCUP.Events:UnregisterEvent("PLAYER_LOGIN");
end

---OpenSettings toggles the main configuration frame and switches to a specified tab.
---@param view number? Optional tab number to open, defaults to 1.
function SIPPYCUP_Addon:OpenSettings(view)
	if not SIPPYCUP.configFrame then
		SIPPYCUP.Config.TryCreateConfigFrame();
	end

	if SIPPYCUP.configFrame then
		SIPPYCUP.configFrame:SetShown(not SIPPYCUP.configFrame:IsShown());
		SIPPYCUP.configFrame:Raise();

		local tabToOpen = view or 1;
		SIPPYCUP_ConfigMenuFrame:SetTab(tabToOpen);
	end
end

---OnEnable runs during PLAYER_LOGIN, register game events, hook functions, create frames, etc.
function SIPPYCUP_Addon:OnEnable()
	-- Register game events on the unified event frame
	SIPPYCUP.Events:RegisterEvent("UNIT_AURA");
	SIPPYCUP.Events:RegisterEvent("PLAYER_REGEN_DISABLED");
	SIPPYCUP.Events:RegisterEvent("PLAYER_REGEN_ENABLED");
	SIPPYCUP.Events:RegisterEvent("PLAYER_ENTERING_WORLD");
	SIPPYCUP.Events:RegisterEvent("PLAYER_LEAVING_WORLD");
	SIPPYCUP.Events:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	SIPPYCUP.Events:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	SIPPYCUP.Events:RegisterEvent("BAG_UPDATE_DELAYED");

	local realCharKey = SIPPYCUP.Database.GetUnitName();
	if realCharKey then
		local db = SIPPYCUP.db;
		if db.profileKeys["Unknown"] and not db.profileKeys[realCharKey] then
			db.profileKeys[realCharKey] = db.profileKeys["Unknown"];
			db.profileKeys["Unknown"] = nil;
			-- Optional: move profile data as well if you saved it under Unknown profile
			-- local profileName = db.profileKeys[realCharKey];
			-- if db.profiles and db.profiles[profileName] then
			--     db.profiles[profileName] = db.profiles[profileName] or {};
			-- end
		end
		SIPPYCUP.Database.Setup();
	end

	-- Adapt saved variables structures between versions
	SIPPYCUP.Flyway:ApplyPatches();

	-- 1 - We set up the minimap buttons.
	SIPPYCUP.Minimap:SetupMinimapButtons();

	-- 2 - We get the player's full name (for MSP checks).
	SIPPYCUP_PLAYER.GetFullName();

	-- 3 - If msp exists, we listen to its update callbacks from the own player.
	-- Handled in PlayerLoading on login/reloads.

	-- 4 - We start our 3m Pre-Expiration Check if it's enabled (check is done within the function itself).
	-- Handled in PLAYER_ENTERING_WORLD on login through self:StartContinuousCheck();

	-- 5 - If we've gotten here, we can send our Welcome Message (if it's enabled).
	if SIPPYCUP.global.WelcomeMessage then
		SIPPYCUP_OUTPUT.Write(L.WELCOMEMSG_VERSION:format(SIPPYCUP.Database.GetCurrentProfileName(), SIPPYCUP.AddonMetadata.version));
		SIPPYCUP_OUTPUT.Write(L.WELCOMEMSG_OPTIONS);
	end
end

---UNIT_AURA handles aura updates for the player, flags bag update desync, and triggers aura conversion.
---@param event string Event name (ignored)
---@param unitTarget string Unit affected, must be "player"
---@param updateInfo any Update data passed to aura conversion
function SIPPYCUP_Addon:UNIT_AURA(_, unitTarget, updateInfo)
	if unitTarget ~= "player" then
		return;
	end

	-- Bag data is not synched immediately when UNIT_AURA fires, signal desync to the addon.
	SIPPYCUP.Items.bagUpdateUnhandled = true;
	SIPPYCUP.Auras.Convert(SIPPYCUP.Auras.Sources.UNIT_AURA, updateInfo);
end

local CONTINUOUS_CHECK_INTERVAL = 180.0;
---StartContinuousCheck begins repeating timers (3 minutes interval) for pre-expiration aura checks and no-aura item usage, if not in combat.
function SIPPYCUP_Addon:StartContinuousCheck()
	-- don’t run if we’re in combat or addon is not loaded fully.
	if InCombatLockdown() or not SIPPYCUP.State.addonLoaded then
		return;
	end

	-- Both below timers don't need an immediate run as startup + new enables run these partially.

	if not self.preExpTicker then
		-- schedule and keep the handle so we can cancel it later
		self.preExpTicker = C_Timer.NewTicker(CONTINUOUS_CHECK_INTERVAL, function()
			SIPPYCUP.Auras.CheckPreExpirationForAllActiveConsumables();
		end);
	end

	if not self.itemTicker then
		-- schedule and keep the handle so we can cancel it later
		self.itemTicker = C_Timer.NewTicker(CONTINUOUS_CHECK_INTERVAL, function()
			SIPPYCUP.Items.CheckNoAuraItemUsage();
		end);
	end
end

---StopContinuousCheck cancels all continuous check timers if active.
function SIPPYCUP_Addon:StopContinuousCheck()
	if self.preExpTicker then
		self.preExpTicker:Cancel();
		self.preExpTicker = nil;
	end

	if self.itemTicker then
		self.itemTicker:Cancel();
		self.itemTicker = nil;
	end
end

---PLAYER_REGEN_DISABLED handles entering combat by stopping aura and continuous checks.
function SIPPYCUP_Addon:PLAYER_REGEN_DISABLED()
	-- Combat is entered when regen is disabled.
	self:StopContinuousCheck();
end

---PLAYER_REGEN_ENABLED handles leaving combat by restarting aura and continuous checks.
function SIPPYCUP_Addon:PLAYER_REGEN_ENABLED()
	-- Combat is left when regen is enabled.
	self:StartContinuousCheck();
	SIPPYCUP.Popups.HandleDeferredActions("combat");
end

local function CheckAddonLoaded()
    if SIPPYCUP.State.databaseLoaded and SIPPYCUP.State.consumablesLoaded then
        SIPPYCUP.State.addonLoaded = true;
    end
end

SIPPYCUP.State.RegisterListener("addonLoaded", function(_, _)
	-- newVal, oldVal
	SIPPYCUP_OUTPUT.Debug("Addon (Consumables & Database) loaded.");

	SIPPYCUP.Config.TryCreateConfigFrame();

	-- Prepare our MSP checks.
	SIPPYCUP.MSP.EnableIfAvailable(); -- True/False if enable successfully, we don't need that info right now.
	-- Depending on if MSP status checks are on or off, we check differently.

	if not SIPPYCUP.State.inLoadingScreen then
		SIPPYCUP.Consumables.RefreshStackSizes(SIPPYCUP.MSP.IsEnabled() and SIPPYCUP.global.MSPStatusCheck);
		SIPPYCUP_Addon:StartContinuousCheck()
		SIPPYCUP.Popups.HandleDeferredActions("loading");

		-- isFullUpdate can pass through loading screens (but our code can't), so handle it now.
		if SIPPYCUP.State.hasSeenFullUpdate then
			SIPPYCUP.State.hasSeenFullUpdate = false;
			SIPPYCUP.Auras.CheckAllActiveConsumables();
		end

		SIPPYCUP.State.startupLoaded = true;
	end
end)

SIPPYCUP.State.RegisterListener("databaseLoaded", function()
	CheckAddonLoaded();
end)

SIPPYCUP.State.RegisterListener("consumablesLoaded", function()
	CheckAddonLoaded();
end)

SIPPYCUP.State.RegisterListener("startupLoaded", function()
	-- We don't use this for now.
end)

---PlayerLoading handles loading screen state changes, stopping checks when loading and starting them when done.
---@param isLoading boolean True if loading screen is active, false if loading finished.
local function PlayerLoading(isLoading)
	if isLoading then
		SIPPYCUP.State.inLoadingScreen = true;
		SIPPYCUP_Addon:StopContinuousCheck();
	else
		SIPPYCUP.State.inLoadingScreen = false;
		if not SIPPYCUP.State.startupLoaded then
			SIPPYCUP.Consumables.RefreshStackSizes(SIPPYCUP.MSP.IsEnabled() and SIPPYCUP.global.MSPStatusCheck);
			SIPPYCUP.State.startupLoaded = true;
		end
		SIPPYCUP_Addon:StartContinuousCheck()
		SIPPYCUP.Popups.HandleDeferredActions("loading");

		-- isFullUpdate can pass through loading screens (but our code can't), so handle it now.
		if SIPPYCUP.State.hasSeenFullUpdate then
			SIPPYCUP.State.hasSeenFullUpdate = false;
			SIPPYCUP.Auras.CheckAllActiveConsumables();
		end
	end
end

---PLAYER_ENTERING_WORLD handles the event when the player enters the world or reloads UI; triggers loading screen exit logic.
---@param event string Event name (ignored)
---@param isInitialLogin boolean Unused
---@param isReloadingUi boolean Whether UI is reloading
function SIPPYCUP_Addon:PLAYER_ENTERING_WORLD(_, _, isReloadingUi)
	-- ZONE_CHANGED_NEW_AREA fires on isInitialLogin, but not on isReloadingUi
	if isReloadingUi then
		-- Reloading fires PLAYER_ENTERING_WORLD when reload is done, data is fine.
		PlayerLoading(false);
	end
end

---PLAYER_LEAVING_WORLD handles the event when the player leaves the world; triggers loading screen enter logic.
function SIPPYCUP_Addon:PLAYER_LEAVING_WORLD()
	PlayerLoading(true);
end

---ZONE_CHANGED_NEW_AREA handles zone changes to exit loading screen state if needed.
function SIPPYCUP_Addon:ZONE_CHANGED_NEW_AREA()
	if SIPPYCUP.State.inLoadingScreen then
		PlayerLoading(false);
	end
end

---UNIT_SPELLCAST_SUCCEEDED handles successful spell casts by the player; checks for items that don't trigger aura events.
---@param event string Event name (ignored)
---@param unitTarget string Unit that cast the spell, must be "player"
---@param _, _ Ignored parameters
---@param spellID number Spell identifier
function SIPPYCUP_Addon:UNIT_SPELLCAST_SUCCEEDED(_, unitTarget, _, spellID)
	if unitTarget ~= "player" then
		return;
	end

	-- Necessary to handle items that don't fire UNIT_AURA.
	SIPPYCUP.Items.CheckNoAuraSingleConsumable(nil, spellID);
end

---BAG_UPDATE_DELAYED handles delayed bag updates; triggers item update handling.
function SIPPYCUP_Addon:BAG_UPDATE_DELAYED()
	SIPPYCUP.Items.HandleBagUpdate();
end
