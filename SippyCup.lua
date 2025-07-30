-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local L = SIPPYCUP.L;

function SIPPYCUP_Addon:OnInitialize()
	SIPPYCUP.Database.Setup();

	SIPPYCUP_Addon:RegisterChatCommand("sippycup", "ExecuteCommand");
	SIPPYCUP_Addon:RegisterChatCommand("sc", "ExecuteCommand");
end

function SIPPYCUP_Addon:ExecuteCommand(msg)
	-- Trim leading and trailing whitespaces if msg exists, otherwise empty msg.
	msg = (msg:match("^%s*(.-)%s*$") or ""):lower();

	if msg == "auras" and SIPPYCUP.IS_DEV_BUILD then
		SIPPYCUP.Auras.DebugEnabledAuras();
	else
		if InterfaceOptionsFrame_OpenToCategory then
			InterfaceOptionsFrame_OpenToCategory(SIPPYCUP.AddonMetadata.title);
		else
			Settings.OpenToCategory(SIPPYCUP.AddonMetadata.title);
		end
	end
end

function SIPPYCUP_Addon:OnEnable()
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LEAVING_WORLD");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	self:RegisterEvent("BAG_UPDATE_DELAYED");

	-- Adapt saved variables structures between versions
	SIPPYCUP.Flyway:ApplyPatches();

	-- 1 - We set up the minimap buttons.
	SIPPYCUP.Minimap:SetupMinimapButtons();

	-- 2 - We get the player's full name (for MSP checks).
	SIPPYCUP_PLAYER.GetFullName();

	-- 3 - If msp exists, we listen to its update callbacks from the own player.
	if not SIPPYCUP.MSP.EnableIfAvailable() then
		-- If not, we'll do a simple stacksize refresh.
		SIPPYCUP.Consumables.RefreshStackSizes(false);
	end

	-- 4 - We start our 5s AuraCheck (mismatch from UNIT_AURA)
	-- Handled in PLAYER_ENTERING_WORLD on login through self:StartAuraCheck();

	-- 5 - We start our 3m Pre-Expiration Check if it's enabled (check is done within the function itself).
	-- Handled in PLAYER_ENTERING_WORLD on login through self:StartContinuousCheck();

	-- 6 - If we've gotten here, we can send our Welcome Message (if it's enabled).
	if SIPPYCUP.db.global.WelcomeMessage then
		SIPPYCUP_OUTPUT.Write(L.WELCOMEMSG_VERSION:format(SIPPYCUP.AddonMetadata.version));
		SIPPYCUP_OUTPUT.Write(L.WELCOMEMSG_OPTIONS);
	end
end

function SIPPYCUP_Addon:UNIT_AURA(_, unitTarget, updateInfo)
	if unitTarget ~= "player" then
		return;
	end

	-- Bag data is not synched immediately when UNIT_AURA fires, signal desync to the addon.
	SIPPYCUP.Items.bagUpdateUnhandled = true;
	SIPPYCUP.Auras.Convert(1, updateInfo);
end

local AURA_CHECK_INTERVAL = 5.0;
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

function SIPPYCUP_Addon:StopAuraCheck()
	if self.auraTimer then
		self:CancelTimer(self.auraTimer, true);  -- silent = true
		self.auraTimer = nil;
	end
end

local CONTINUOUS_CHECK_INTERVAL = 180.0;
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
			SIPPYCUP.Items.CheckNonTrackableItemUsage,
			CONTINUOUS_CHECK_INTERVAL
		);
	end
end

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

function SIPPYCUP_Addon:PLAYER_REGEN_DISABLED()
	-- Combat is entered when regen is disabled.
	self:StopAuraCheck();
	self:StopContinuousCheck();
end

function SIPPYCUP_Addon:PLAYER_REGEN_ENABLED()
	-- Combat is left when regen is enabled.
	self:StartAuraCheck();
	self:StartContinuousCheck();
end

function SIPPYCUP_Addon:PLAYER_ENTERING_WORLD(_, isInitialLogin, isReloadingUi)
	if not isInitialLogin and not isReloadingUi then
		SIPPYCUP.InLoadingScreen = true;
		self:StopAuraCheck();
		self:StopContinuousCheck();
	else
		-- On login and reload, ZONE_CHANGED_NEW_AREA does not fire so we start checks.
		SIPPYCUP.InLoadingScreen = false;
		self:StartAuraCheck();
		self:StartContinuousCheck();
	end
end

function SIPPYCUP_Addon:PLAYER_LEAVING_WORLD()
	SIPPYCUP.InLoadingScreen = true;
	self:StopAuraCheck();
	self:StopContinuousCheck();
end

function SIPPYCUP_Addon:ZONE_CHANGED_NEW_AREA()
	if SIPPYCUP.InLoadingScreen then
		SIPPYCUP.InLoadingScreen = false;
		self:StartAuraCheck();
		self:StartContinuousCheck();
	end
end

function SIPPYCUP_Addon:UNIT_SPELLCAST_SUCCEEDED(_, unitTarget, _, spellID)
	if unitTarget ~= "player" then
		return;
	end

	-- Necessary to handle nontrackable items (that don't fire UNIT_AURA).
	SIPPYCUP.Items.CheckNonTrackableSingleConsumable(nil, spellID);
end

function SIPPYCUP_Addon:BAG_UPDATE_DELAYED()
	SIPPYCUP.Items.HandleBagUpdate();
end
