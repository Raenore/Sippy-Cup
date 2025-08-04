-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local L = SIPPYCUP.L;

---OnInitialize sets up saved variables and command handlers.
function SIPPYCUP_Addon:OnInitialize()
    if not SippyCupDB then
        SippyCupDB = {
            global = {},
            profileKeys = {},
            profiles = {},
        };
    end

    SIPPYCUP.db = SippyCupDB; -- SINGLE reference

    SIPPYCUP.Database.Setup();

	SIPPYCUP_Addon:RegisterChatCommand("sippycup", "ExecuteCommand");
	SIPPYCUP_Addon:RegisterChatCommand("sc", "ExecuteCommand");
end

---ExecuteCommand processes slash command input.
---@param msg string Command text entered by the user.
function SIPPYCUP_Addon:ExecuteCommand(msg)
	-- Trim leading and trailing whitespaces if msg exists, otherwise empty msg.
	msg = (msg:match("^%s*(.-)%s*$") or ""):lower();

	if msg == "auras" and SIPPYCUP.IS_DEV_BUILD then
		SIPPYCUP.Auras.DebugEnabledAuras();
	else
		SIPPYCUP_Addon:OpenSettings();
	end
end

local configFrame = nil;

---OpenSettings toggles the main configuration frame and switches to a specified tab.
---@param view integer? Optional tab number to open, defaults to 1.
function SIPPYCUP_Addon:OpenSettings(view)
    if not configFrame then
        configFrame = CreateFrame("Frame", "SIPPYCUP_ConfigMenuFrame", UIParent, "SIPPYCUP_ConfigMenuTemplate");
    end

    configFrame:SetShown(not configFrame:IsShown());
    configFrame:Raise();

    local tabToOpen = view or 1;
    SIPPYCUP_ConfigMenuFrame:SetTab(tabToOpen);
end

---OnEnable registers event handlers, migrates unknown profiles, applies DB patches, sets up minimap buttons, initializes player info, and starts periodic checks.
function SIPPYCUP_Addon:OnEnable()
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LEAVING_WORLD");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	self:RegisterEvent("BAG_UPDATE_DELAYED");

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

	-- 4 - We start our 5s AuraCheck (mismatch from UNIT_AURA)
	-- Handled in PLAYER_ENTERING_WORLD on login through self:StartAuraCheck();

	-- 5 - We start our 3m Pre-Expiration Check if it's enabled (check is done within the function itself).
	-- Handled in PLAYER_ENTERING_WORLD on login through self:StartContinuousCheck();

	-- 6 - If we've g	otten here, we can send our Welcome Message (if it's enabled).
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
	SIPPYCUP.Auras.Convert(1, updateInfo);
end

local AURA_CHECK_INTERVAL = 5.0;
---StartAuraCheck begins a repeating 5-second timer to check aura stack mismatches, unless in combat or already running.
function SIPPYCUP_Addon:StartAuraCheck()
	-- Should never happen, but just in case.
	if InCombatLockdown() then
		return;
	end

	-- Only run this if it's not already running, no point to duplicate.
	if not self.auraTimer then
		-- Run once immediately
		SIPPYCUP.Auras.CheckStackMismatchInDBForAllActiveConsumables();

		-- schedule and keep the handle so we can cancel it later
		self.auraTimer = self:ScheduleRepeatingTimer(
			SIPPYCUP.Auras.CheckStackMismatchInDBForAllActiveConsumables,
			AURA_CHECK_INTERVAL
		);
	end
end


---StopAuraCheck cancels the repeating aura mismatch check timer if active.
function SIPPYCUP_Addon:StopAuraCheck()
	if self.auraTimer then
		self:CancelTimer(self.auraTimer, true);  -- silent = true
		self.auraTimer = nil;
	end
end

local CONTINUOUS_CHECK_INTERVAL = 180.0;
---StartContinuousCheck begins repeating timers (3 minutes interval) for pre-expiration aura checks and no-aura item usage, if not in combat.
function SIPPYCUP_Addon:StartContinuousCheck()
	-- don’t run if we’re in combat or the user has disabled pre‑expiration checks
	if InCombatLockdown() then
		return
	end

	-- Both below timers don't need an immediate run as startup + new enables run these partially.

	if not self.preExpTimer then
		-- schedule and keep the handle so we can cancel it later
		self.preExpTimer = self:ScheduleRepeatingTimer(
			SIPPYCUP.Auras.CheckPreExpirationForAllActiveConsumables,
			CONTINUOUS_CHECK_INTERVAL
		);
	end

	if not self.itemTimer then
		-- schedule and keep the handle so we can cancel it later
		self.itemTimer = self:ScheduleRepeatingTimer(
			SIPPYCUP.Items.CheckNoAuraItemUsage,
			CONTINUOUS_CHECK_INTERVAL
		);
	end
end

---StopContinuousCheck cancels all continuous check timers if active.
function SIPPYCUP_Addon:StopContinuousCheck()
	if self.preExpTimer then
		self:CancelTimer(self.preExpTimer, true);  -- silent = true
		self.preExpTimer = nil;
	end

	if self.itemTimer then
		self:CancelTimer(self.itemTimer, true);  -- silent = true
		self.itemTimer = nil;
	end
end

---PLAYER_REGEN_DISABLED handles entering combat by stopping aura and continuous checks.
function SIPPYCUP_Addon:PLAYER_REGEN_DISABLED()
	-- Combat is entered when regen is disabled.
	self:StopAuraCheck();
	self:StopContinuousCheck();
end

---PLAYER_REGEN_ENABLED handles leaving combat by restarting aura and continuous checks.
function SIPPYCUP_Addon:PLAYER_REGEN_ENABLED()
	-- Combat is left when regen is enabled.
	self:StartAuraCheck();
	self:StartContinuousCheck();
end

local startupCheck = true;
---PlayerLoading handles loading screen state changes, stopping checks when loading and starting them when done.
---@param isLoading boolean True if loading screen is active, false if loading finished.
local function PlayerLoading(isLoading)
	if isLoading then
		SIPPYCUP.InLoadingScreen = true;
		SIPPYCUP_Addon:StopAuraCheck();
		SIPPYCUP_Addon:StopContinuousCheck();
	else
		SIPPYCUP.InLoadingScreen = false;
		SIPPYCUP_Addon:StartAuraCheck();
		SIPPYCUP_Addon:StartContinuousCheck()

		if startupCheck then
			if not SIPPYCUP.MSP.EnableIfAvailable() then
				-- If not, we'll do a simple stacksize refresh.
				SIPPYCUP.Consumables.RefreshStackSizes(false);
			end
			startupCheck = false;
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
	if SIPPYCUP.InLoadingScreen then
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
