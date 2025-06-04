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
	self:RegisterEvent("PLAYER_FLAGS_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LEAVING_WORLD");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");

	SIPPYCUP.Minimap:SetupMinimapButtons();

	self:StartAuraCheck();
	-- Check all enabled consumables to see if we have to track any (or enable if setting is set).
	SIPPYCUP.Auras.CheckConsumableStackSizes(SIPPYCUP.db.global.MSPStatusCheck);

	if msp and msp.my then
		table.insert(msp.callback["updated"], function()
			SIPPYCUP.Auras.CheckConsumableStackSizes(SIPPYCUP.db.global.MSPStatusCheck)
		end)
	end

	if SIPPYCUP.db.global.WelcomeMessage then
		SIPPYCUP_OUTPUT.Write(L.WELCOMEMSG_VERSION:format(SIPPYCUP.AddonMetadata.version));
		SIPPYCUP_OUTPUT.Write(L.WELCOMEMSG_OPTIONS);
	end

	GameMenuFrame:HookScript("OnShow", function()
		if not SIPPYCUP.Popups.SuppressGameMenuCallback then
			SIPPYCUP.Popups.SaveOpenedPopups(true);
		end
	end);

	GameMenuFrame:HookScript("OnHide", function()
		if not SIPPYCUP.Popups.SuppressGameMenuCallback then
			SIPPYCUP.Popups.LoadOpenedPopups(true);
		end
	end);
end

function SIPPYCUP_Addon:UNIT_AURA(_, unitTarget, updateInfo)
	if unitTarget ~= "player" then
		return;
	end

	SIPPYCUP.Auras.Convert(1, updateInfo);
end

local AURA_CHECK_INTERVAL = 5.0;
function SIPPYCUP_Addon:StartAuraCheck()
	-- Should never happen, but just in case.
	if InCombatLockdown() then
		return;
	end

	if not self.timer then
		-- schedule and keep the handle so we can cancel it later
		self.timer = self:ScheduleRepeatingTimer(SIPPYCUP.Auras.CheckStackMismatchInDB, AURA_CHECK_INTERVAL);
	end
end

function SIPPYCUP_Addon:StopAuraCheck()
	if self.timer then
		self:CancelTimer(self.timer, true);  -- silent = true
		self.timer = nil;
	end
end

function SIPPYCUP_Addon:PLAYER_REGEN_DISABLED()
	-- Combat is entered when regen is disabled.
	self:StopAuraCheck();
end

function SIPPYCUP_Addon:PLAYER_REGEN_ENABLED()
	-- Combat is left when regen is enabled.
	self:StartAuraCheck();
end

function SIPPYCUP_Addon:PLAYER_FLAGS_CHANGED(_, unitTarget)
	-- ElvUI has the chance to cause errors when AFK Mode is enabled.
	if unitTarget ~= "player" or not C_AddOns.IsAddOnLoaded("ElvUI") then
		return;
	end

	local isAFK = UnitIsAFK("player");

	if isAFK then
		-- On AFK, we save the poupups that were visible and then kill them.
		SIPPYCUP.Popups.SaveOpenedPopups();
	else
		-- On returning from AFK, we re-spawn the killed popups if any have to be.
		SIPPYCUP.Popups.LoadOpenedPopups();
	end
end

function SIPPYCUP_Addon:PLAYER_ENTERING_WORLD(_, isInitialLogin, isReloadingUi)
	if not isInitialLogin and not isReloadingUi then
		SIPPYCUP.Auras.InLoadingScreen = true;
		self:StopAuraCheck();
	end
end

function SIPPYCUP_Addon:PLAYER_LEAVING_WORLD()
	SIPPYCUP.Auras.InLoadingScreen = true;
	self:StopAuraCheck();
end

function SIPPYCUP_Addon:ZONE_CHANGED_NEW_AREA()
	SIPPYCUP.Auras.InLoadingScreen = false;
	self:StartAuraCheck();
end
