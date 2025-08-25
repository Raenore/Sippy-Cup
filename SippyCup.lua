-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local L = SIPPYCUP.L;

---ADDON_LOADED Initializes the addon when ADDON_LOADED fires for "SippyCup".
---Unregisters the event and calls OnInitialize.
function SIPPYCUP_Addon:ADDON_LOADED(_, addonName)
	if addonName == "SippyCup" then
		SIPPYCUP_Addon:UnregisterEvent("ADDON_LOADED");
		self:OnInitialize();
	end
end

---OnInitialize Loads saved variables, sets up database, consumables, and slash commands.
function SIPPYCUP_Addon:OnInitialize()
	if not SippyCupDB then
		SippyCupDB = {
			global = {},
			profileKeys = {},
			profiles = {},
		};
	end

	SIPPYCUP.db = SippyCupDB;

	-- Set up DB internals & Consumables
	SIPPYCUP.Database.Setup();
	SIPPYCUP.Consumables.Setup();

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

---OpenSettings Toggles the main config frame and optionally switches to a specified tab.
---@param view number? Optional tab index, defaults to 1.
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

---CheckPlayerLogin Ensures PLAYER_LOGIN processing runs after DB and consumables are loaded.
local function CheckPlayerLogin()
	if SIPPYCUP.States.databaseLoaded and SIPPYCUP.States.consumablesLoaded and SIPPYCUP.States.playerLoggedIn then
		SIPPYCUP_OUTPUT.Debug("Addon (Consumables & Database) loaded.");
		SIPPYCUP_Addon:OnPlayerLogin();
	end
end

---PLAYER_LOGIN Fires after the UI is fully loaded, triggers OnPlayerLogin if DB and consumables are ready.
function SIPPYCUP_Addon:PLAYER_LOGIN()
	SIPPYCUP_Addon:UnregisterEvent("PLAYER_LOGIN");
	SIPPYCUP.States.playerLoggedIn = true;
	CheckPlayerLogin();
end

---CONSUMABLES_LOADED Callback triggered when all consumable data is loaded from the game.
---Sets consumablesLoaded state and checks if PLAYER_LOGIN processing can proceed.
SIPPYCUP.Callbacks:RegisterCallback(SIPPYCUP.Events.CONSUMABLES_LOADED, function()
	SIPPYCUP.States.consumablesLoaded = true;
	CheckPlayerLogin();
end);

---OnPlayerLogin Handles game event registration and config frame creation after player login.
function SIPPYCUP_Addon:OnPlayerLogin()
	-- Register game events on the unified event frame
	SIPPYCUP_Addon:RegisterUnitEvent("UNIT_AURA", "player");
	SIPPYCUP_Addon:RegisterEvent("PLAYER_REGEN_DISABLED");
	SIPPYCUP_Addon:RegisterEvent("PLAYER_REGEN_ENABLED");
	SIPPYCUP_Addon:RegisterEvent("PLAYER_ENTERING_WORLD");
	SIPPYCUP_Addon:RegisterEvent("PLAYER_LEAVING_WORLD");
	SIPPYCUP_Addon:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	SIPPYCUP_Addon:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");
	SIPPYCUP_Addon:RegisterEvent("BAG_UPDATE_DELAYED");

	SIPPYCUP.Config.TryCreateConfigFrame();
end

---OnInitialPlayerInWorld Runs initial setup after the player enters the world for the first time.
---Handles MSP checks, DB profile migration, saved variable patches, and minimap setup.
function SIPPYCUP_Addon:OnInitialPlayerInWorld()
	-- Prepare our MSP checks.
	SIPPYCUP.MSP.EnableIfAvailable(); -- True/False if enable successfully, we don't need that info right now.
	-- Depending on if MSP status checks are on or off, we check differently.
	SIPPYCUP.Consumables.RefreshStackSizes(SIPPYCUP.MSP.IsEnabled() and SIPPYCUP.global.MSPStatusCheck);

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

	SIPPYCUP.Minimap:SetupMinimapButtons();

	if SIPPYCUP.global.WelcomeMessage then
		SIPPYCUP_OUTPUT.Write(L.WELCOMEMSG_VERSION:format(SIPPYCUP.Database.GetCurrentProfileName(), SIPPYCUP.AddonMetadata.version));
		SIPPYCUP_OUTPUT.Write(L.WELCOMEMSG_OPTIONS);
	end

	SIPPYCUP.States.addonReady = true;
end

---BAG_UPDATE_DELAYED Handles delayed bag updates and triggers item update processing.
function SIPPYCUP_Addon:BAG_UPDATE_DELAYED()
	SIPPYCUP.Items.HandleBagUpdate();
end

---PLAYER_ENTERING_WORLD Handles player entering world or UI reload; triggers loading screen end logic if reloading.
---@param event string Event name (ignored)
---@param isInitialLogin boolean Unused
---@param isReloadingUi boolean Whether UI is reloading
function SIPPYCUP_Addon:PLAYER_ENTERING_WORLD(_, _, isReloadingUi)
	-- ZONE_CHANGED_NEW_AREA fires on isInitialLogin, but not on isReloadingUi
	if isReloadingUi then
		-- Reloading fires PLAYER_ENTERING_WORLD when reload is done, data is fine.
		SIPPYCUP.Callbacks:TriggerEvent(SIPPYCUP.Events.LOADING_SCREEN_ENDED);
	end
end

---PLAYER_LEAVING_WORLD Handles leaving the world; triggers loading screen start logic.
function SIPPYCUP_Addon:PLAYER_LEAVING_WORLD()
	SIPPYCUP.Callbacks:TriggerEvent(SIPPYCUP.Events.LOADING_SCREEN_STARTED);
end

---PLAYER_REGEN_DISABLED Stops continuous checks when entering combat.
function SIPPYCUP_Addon:PLAYER_REGEN_DISABLED()
	-- Combat is entered when regen is disabled.
	self:StopContinuousCheck();
end

---PLAYER_REGEN_ENABLED Restarts continuous checks and handles deferred combat actions after leaving combat.
function SIPPYCUP_Addon:PLAYER_REGEN_ENABLED()
	-- Combat is left when regen is enabled.
	self:StartContinuousCheck();
	SIPPYCUP.Popups.HandleDeferredActions("combat");
end

---UNIT_AURA Handles player aura updates, flags bag desync, and triggers aura conversion.
---@param event string Event name (ignored)
---@param unitTarget string Unit affected, automatically "player" through RegisterUnitEvent.
---@param updateInfo any Update data passed to aura conversion
function SIPPYCUP_Addon:UNIT_AURA(_, unitTarget, updateInfo) -- luacheck: no unused (unitTarget)
	-- Bag data is not synched immediately when UNIT_AURA fires, signal desync to the addon.
	SIPPYCUP.Items.bagUpdateUnhandled = true;
	SIPPYCUP.Auras.Convert(SIPPYCUP.Auras.Sources.UNIT_AURA, updateInfo);
end

---UNIT_SPELLCAST_SUCCEEDED Handles successful player spell casts; checks items that don't trigger UNIT_AURA.
---@param event string Event name (ignored)
---@param unitTarget string Unit that cast the spell, automatically "player" through RegisterUnitEvent.
---@param _, _ Ignored parameters
---@param spellID number Spell identifier
function SIPPYCUP_Addon:UNIT_SPELLCAST_SUCCEEDED(_, unitTarget, _, spellID) -- luacheck: no unused (unitTarget)
	-- Necessary to handle items that don't fire UNIT_AURA.
	SIPPYCUP.Items.CheckNoAuraSingleConsumable(nil, spellID);
end

---ZONE_CHANGED_NEW_AREA Handles zone changes and triggers loading screen end logic if needed.
function SIPPYCUP_Addon:ZONE_CHANGED_NEW_AREA()
	SIPPYCUP.Callbacks:TriggerEvent(SIPPYCUP.Events.LOADING_SCREEN_ENDED);
end

---LOADING_SCREEN_STARTED Callback triggered when a loading screen begins.
---Sets loading screen state and stops continuous checks if addon is ready.
SIPPYCUP.Callbacks:RegisterCallback(SIPPYCUP.Events.LOADING_SCREEN_STARTED, function()
	SIPPYCUP.States.loadingScreen = true;

	-- Do not continue if addon is not ready.
	if not SIPPYCUP.States.addonReady then
		return;
	end

	SIPPYCUP_Addon:StopContinuousCheck();
end);

---LOADING_SCREEN_ENDED Callback triggered when a loading screen ends.
---Runs initial world setup, starts continuous checks, handles deferred actions, and processes full aura updates if pending.
SIPPYCUP.Callbacks:RegisterCallback(SIPPYCUP.Events.LOADING_SCREEN_ENDED, function()
	SIPPYCUP.States.loadingScreen = false;

	-- Initial loading screen data run.
	if not SIPPYCUP.States.addonReady then
		SIPPYCUP_Addon:OnInitialPlayerInWorld();
	end

	SIPPYCUP_Addon:StartContinuousCheck()
	SIPPYCUP.Popups.HandleDeferredActions("loading");

	-- isFullUpdate can pass through loading screens (but our code can't), so handle it now.
	if SIPPYCUP.States.hasSeenFullUpdate then
		SIPPYCUP.States.hasSeenFullUpdate = false;
		SIPPYCUP.Auras.CheckAllActiveConsumables();
	end
end);
