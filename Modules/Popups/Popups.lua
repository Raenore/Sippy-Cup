-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Popups = {};

local L = SIPPYCUP.L;
local E, S;
local SharedMedia = LibStub("LibSharedMedia-3.0");
local ICON_SIZE = 36;

-- ElvUI skinning the refresh button.
if C_AddOns.IsAddOnLoaded('ElvUI') then
	E = ElvUI[1];
	S = E:GetModule("Skins");
end

---PlayPopupSound plays the chosen alert sound during a popup.
---@return nil
local function PlayPopupSound()
	local soundPath = SharedMedia:Fetch("sound", SIPPYCUP.db.global.AlertSoundID);
	if soundPath then
		PlaySoundFile(soundPath, "Master");
	end
end

local alertThrottle = {};

---HandleAlerts handles playing a popup sound or flash the taskbar, plus throttling to avoid spam based on loc key.
---@param loc string? The localization key used for throttling alert actions (optional).
---@param reset boolean? If true, resets the throttling for the specified location (optional).
---@return nil
local function HandleAlerts(loc, reset)
	-- First handle no arguments, then no throttling is necessary.
	if not loc then
		if SIPPYCUP.db.global.AlertSound then
			PlayPopupSound();
		end

		if SIPPYCUP.db.global.FlashTaskbar then
			FlashClientIcon();
		end

		return;
	end

	-- Reset throttle if requested.
	if reset then
		alertThrottle[loc] = nil;
		return;
	end

	-- If the popup alerts actions are not throttled, handle it.
	if not alertThrottle[loc] then
		if SIPPYCUP.db.global.AlertSound then
			PlayPopupSound();
		end

		if SIPPYCUP.db.global.FlashTaskbar then
			FlashClientIcon();
		end

		alertThrottle[loc] = true;
	end
end

local sessionData = {};

---ResetIgnored clears all the session-based consumable popups.
---@return nil
function SIPPYCUP.Popups.ResetIgnored()
	wipe(sessionData);
end

---IsEmpty returns true if no consumables are currently ignored in the session.
---@return boolean isEmpty True if SessionData is empty, otherwise false.
function SIPPYCUP.Popups.IsEmpty()
	return next(sessionData) == nil;
end

---IsIgnored checks if the given profile is marked as ignored for this session.
---@param profile string The profile key to check.
---@return boolean isIgnored True if the profile is ignored, otherwise false.
function SIPPYCUP.Popups.IsIgnored(profile)
	return sessionData[profile] == true;
end

local hiddenAFKPopups = {};
SIPPYCUP.Popups.SuppressGameMenuCallback = false;

---SaveOpenedPopups Handles saving all opened popups before hiding them.
---@param mainMenu boolean? If true, triggered by the Main Menu.
---@return nil
function SIPPYCUP.Popups.SaveOpenedPopups(mainMenu)
	if mainMenu and SIPPYCUP.Popups.SuppressGameMenuCallback then
		return;
	end
	if mainMenu then
		SIPPYCUP.Popups.SuppressGameMenuCallback = true;
	end

	wipe(hiddenAFKPopups);

	for _, consumable in ipairs(SIPPYCUP.Consumables.Data) do
		local popupKey = "SIPPYCUP_REFRESH_" .. consumable.loc;
		if StaticPopup_Visible(popupKey) then
			-- Game Main Menu needs to be hidden if our popups are visible.
			if mainMenu and GameMenuFrame:IsShown() then
				GameMenuFrame:Hide();
			end

			hiddenAFKPopups[#hiddenAFKPopups + 1] = consumable.name;
			StaticPopup_Hide(popupKey);
		end
	end

	-- After we've cleaned our popups, we re-show the game's Main Menu.
	if mainMenu and not GameMenuFrame:IsShown() then
		GameMenuFrame:Show();
		RunNextFrame(function()
			SIPPYCUP.Popups.SuppressGameMenuCallback = false;
		end);
	elseif mainMenu then
		-- Edge case: no need to call :Show(), but still reset the flag
		SIPPYCUP.Popups.SuppressGameMenuCallback = false;
	end
end

---LoadOpenedPopups Handles reopening all the prior saved and hidden popups.
---@param mainMenu boolean? If true, triggered by the Main Menu.
---@return nil
function SIPPYCUP.Popups.LoadOpenedPopups(mainMenu)
	if mainMenu and SIPPYCUP.Popups.SuppressGameMenuCallback then
		return;
	end

	for _, popupName in ipairs(hiddenAFKPopups) do
		-- On MainMenu, we spawn the popups a second after to allow the logout popup to still show.
		SIPPYCUP.Popups.Toggle(popupName, true, mainMenu);
	end
	wipe(hiddenAFKPopups);
end

---BaseConsumablePopupTemplate defines the default behavior and appearance of the consumable popup.
---@type table<string, any>
local BaseConsumablePopupTemplate = {
	text = "%s",
	button1 = REFRESH,
	button2 = CANCEL,
	button3 = IGNORE,
	timeout = false,
	whileDead = false,
	hideOnEscape = false,
	showAlert = true,

	OnCancel = function(self, data)
		if data then
			HandleAlerts(data.loc, true);
		end
	end,

	OnAlt = function(self, data)
		if data then
			sessionData[data.profile] = true;
		end
	end,

	OnHide = function(popup)
		if popup and popup.popupButton then
			popup.popupButton:Hide();
			popup.popupButton:SetParent(nil);
			popup.popupButton = nil;
		end
	end,
}

---ClonePopupTemplate creates a copy of a popup template.
---Note: This performs a shallow copy. Nested tables will be shared.
---@param template table The base popup template to clone.
---@return table copy A new table cloned from the base template.
local function ClonePopupTemplate(template)
	local copy = {};
	for k, v in pairs(template) do
		copy[k] = v;
	end
	return copy;
end

---CreateConsumablePopup creates a consumable popup with dynamic button behavior and customized output.
---@param consumableData table A table containing the consumable's data (itemID, loc, profile, etc.).
---@param requiredStacks number The number of stacks the user required for the consumable.
---@param reason number The consumable's reason.
---@return nil
local function CreateConsumablePopup(consumableData, requiredStacks, reason)
	local popupKey = "SIPPYCUP_REFRESH_" .. consumableData.loc;
	local popupData = ClonePopupTemplate(BaseConsumablePopupTemplate);

	popupData.OnShow = function(popup, data)
		local popupButton = CreateFrame("Button", nil, popup, "StaticPopupButtonTemplate, SecureActionButtonTemplate");
		popupButton:SetAttribute("type", "item");
		popupButton:SetAttribute("item", data.item);
		popupButton:RegisterForClicks("AnyUp", "AnyDown");
		popupButton:SetAllPoints(popup.button1);
		popupButton:SetText(data.buttonText);
		popupButton:SetMotionScriptsWhileDisabled(true);

		if S and S.HandleButton then
			S:HandleButton(popupButton);
		end

		popup.popupButton = popupButton
		popup.button1:Hide()
		popupButton:Show()

		-- Handle missing item situation after popup has already spawned, as button will do nothing.
		if popupButton then
			-- Normally we don't want to use duration as it can also just show a GCD instead of spell, but that's okay because we want that.
			local startTime, duration = C_Container.GetItemCooldown(consumableData.itemID);
			if duration > 0 then
				-- Calculate how many seconds are left on cooldown right now, to use that to disable & re-enable the button.
				local expiresAt = startTime + duration;
				local remaining = expiresAt - GetTime();
				if remaining > 0 then
					popupButton:Disable();
					popupButton:EnableMouse(true);
					C_Timer.After(remaining, function()
						if popupButton and popupButton:IsShown() then
							GameTooltip:Hide();
							popupButton:Enable();
						end
					end);
				end
			end

			popupButton:HookScript("OnEnter", function(self)
				local tooltipText;

				if not self:IsEnabled() then
					tooltipText = "|cnWARNING_FONT_COLOR:" .. L.POPUP_COOLDOWN_TEXT:gsub("^%l", string.upper) .. "|r";
				else
					local itemCount = C_Item.GetItemCount(consumableData.itemID);

					if itemCount == 0 then
						tooltipText = "|cnWARNING_FONT_COLOR:" .. L.POPUP_LACKING_TEXT:gsub("^%l", string.upper) .. "|r";
					elseif itemCount < requiredStacks then
						tooltipText = "|cnWARNING_FONT_COLOR:" .. L.POPUP_LACKING_TEXT_AMOUNT:gsub("^%l", string.upper) .. "|n(" .. itemCount .. " / " .. requiredStacks .. ")|r";
					end
				end

				if tooltipText then
					GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -5);
					GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true);
					GameTooltip:Show();
				end
			end)
			popupButton:HookScript("OnLeave", function()
				GameTooltip:Hide();
			end)
		end

		if popup.button3 then
			popup.button3:HookScript("OnEnter", function()
				GameTooltip:SetOwner(popup.button3, "ANCHOR_BOTTOM", 0, -5);
				GameTooltip:SetText(L.POPUP_IGNORE_TT, nil, nil, nil, nil, true);
				GameTooltip:Show();
			end);
			popup.button3:HookScript("OnLeave", function()
				GameTooltip:Hide();
			end);
		end
	end

	StaticPopupDialogs[popupKey] = popupData;

	local text = SIPPYCUP.AddonMetadata.title;
	local popupText = L.POPUP_STACK_TEXT;
	if reason == 2 then
		popupText = L.POPUP_EXPIRING_SOON_TEXT;
	elseif not consumableData.stacks then
		popupText = L.POPUP_MISSING_TEXT;
	end

	-- Builds the popup message with optional item icon and capitalizes the first letter of the follow-up text if enabled.
	if SIPPYCUP.db.global.PopupIcon then
		text = text .. "|n|n|TInterface\\Icons\\" .. SIPPYCUP_ICON.RetrieveIcon(consumableData.name) .. ":" .. ICON_SIZE .. "|t |cnGREEN_FONT_COLOR:" .. consumableData.name .. "|r|n|n" .. popupText:gsub("^%l", string.upper);
	else
		text = text .. "|n|n|cnGREEN_FONT_COLOR:" .. consumableData.name .. "|r " .. popupText;
	end

	local dialog = StaticPopup_Show(popupKey, text, nil, {
		item = C_Item.GetItemInfo(consumableData.itemID) or consumableData.name,
		loc = consumableData.loc,
		profile = consumableData.profile,
		buttonText = REFRESH .. " (" .. requiredStacks .. "x)",
	});

	if dialog then
		dialog.popupKey = popupKey;

		if SIPPYCUP.db.global.PopupPosition == "center" then
			dialog:ClearAllPoints();
			dialog:SetPoint("CENTER", UIParent, "CENTER");
		end
	end
end

---Toggle handles what should happen after a consumable is enabled or disabled in regards to popup logic.
---@param itemName string The toggled consumable's name.
---@param enabled boolean Whether the consumable tracking is enabled or disabled.
---@param mainMenu boolean? Whether this was triggered from the Main Menu hide or not.
---@return nil
function SIPPYCUP.Popups.Toggle(itemName, enabled, mainMenu)
	-- Grab the right consumable by name, and check if aura exists.
	local consumableData = SIPPYCUP.Consumables.ByName[itemName];
	if not consumableData then
		return;
	end
	SIPPYCUP.Database.RebuildAuraMap();

	-- If the consumable is not enabled, kill all its associated popups and timers!
	if not enabled then
		local popupKey = "SIPPYCUP_REFRESH_" .. consumableData.loc;
		HandleAlerts(consumableData.loc, true);

		if StaticPopup_Visible(popupKey) then
			StaticPopup_Hide(popupKey);
		end

		if consumableData.nonTrackable then
			SIPPYCUP.Items.CancelItemTimer(nil, consumableData.auraID);
		else
			SIPPYCUP.Auras.CancelPreExpirationTimer(nil, consumableData.auraID);
		end

		return;
	end

	-- For the enabled case: we need to check auraInfo and possibly cooldown. We'll define continuation logic.
	local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(consumableData.auraID);
		-- continuation: runs after we know `active` value
	local function continueToggle(active, startTimer)
		-- Check potential pre-expiration timers that might be relevant for the newly enabled consumable.
		local profileConsumableData = SIPPYCUP.db.profile[consumableData.profile];
		local preExpireFired;
		if consumableData.nonTrackable then
			preExpireFired = SIPPYCUP.Items.CheckNonTrackableSingleConsumable(profileConsumableData, nil, nil, startTimer);
		else
			preExpireFired = SIPPYCUP.Auras.CheckPreExpirationForSingleConsumable(profileConsumableData);
		end

		-- Only queue popup if no pre-expiration has already fired
		if not preExpireFired then
			-- auraInfo may be truthy/table; active is boolean from cooldown check
			SIPPYCUP.Popups.QueuePopupAction((auraInfo or active) and 0 or 1, consumableData.auraID, auraInfo, auraInfo and auraInfo.auraInstanceID, mainMenu, "Toggle");
		end
	end

	-- If non-trackable, do cooldown check with retry; otherwise we can continue immediately with active=false if no aura.
	if consumableData.nonTrackable then
		-- Start with active=false; callback will override if startTime>0
		SIPPYCUP.Items.GetItemCooldownWithRetry(consumableData.itemID, 2, 0.2, function(startTime)
			local active = false;
			if startTime and startTime > 0 then
				active = true;
			end
			continueToggle(active, startTime);
		end);
	else
		-- No cooldown check needed; only auraInfo matters. active = false here.
		continueToggle(false);
	end
end

local DEBOUNCE_DELAY = 0.05;
local pendingCalls = {};

---QueuePopupAction queues up popup action calls, adding a debounce to avoid repeated calls (UNIT_AURA & COMBAT_LOG_EVENT_UNFILTERED).
---@param reason number Why a popup is getting called (0 - add/update, 1 = removal, 2 = pre-expire)
---@param auraID number The aura ID.
---@param auraInfo table|nil Information about the aura, or nil if not present.
---@param auraInstanceID number|nil The instance ID of the aura, or nil if not applicable.
---@param mainMenu boolean? Whether this was triggered from the Main Menu hide or not.
---@param caller string What function called the popup action.
---@return nil
function SIPPYCUP.Popups.QueuePopupAction(reason, auraID, auraInfo, auraInstanceID, mainMenu, caller)
	if InCombatLockdown() then return; end

	-- If MSP status checks are on and the character is currently OOC, we skip everything.
	if SIPPYCUP.db.global.MSPStatusCheck and SIPPYCUP.Player.OOC then
		return;
	end

	-- Use a composite key of auraID and reason so different reasons don't collide
	local key = tostring(auraID) .. "-" .. tostring(reason);
	local args = { reason, auraID, auraInfo, auraInstanceID, mainMenu, caller };

	if pendingCalls[key] then
		-- Update the existing entry with the latest arguments for this auraID+reason
		pendingCalls[key].args = args;
		return
	end

	-- first call for this auraID+reason: store args and schedule
	pendingCalls[key] = { args = args }
	C_Timer.After(DEBOUNCE_DELAY, function()
		local entry = pendingCalls[key];
		pendingCalls[key] = nil;

		if not entry or not entry.args then
			return;
		end

		local res, aID, aI, aIID, mM, c = unpack(entry.args);
		SIPPYCUP.Popups.HandlePopupAction(res, aID, aI, aIID, mM, c);
	end)
end

---HandlePopupAction executes the popup action for a consumable aura.
---@param reason number Why a popup is getting called (0 - add/update, 1 = removal, 2 = pre-expire)
---@param auraID number The aura ID.
---@param auraInfo table|nil Information about the aura, or nil if not present.
---@param auraInstanceID number|nil The instance ID of the aura, or nil if not applicable.
---@param mainMenu boolean? Whether this was triggered from the Main Menu hide or not.
---@param caller string What function called the popup action.
---@return nil
function SIPPYCUP.Popups.HandlePopupAction(reason, auraID, auraInfo, auraInstanceID, mainMenu, caller)
	if InCombatLockdown() then return end

	SIPPYCUP_OUTPUT.Debug({ caller = caller});

	local consumableData = SIPPYCUP.Consumables.ByAuraID[auraID];
	if not consumableData then return; end

	local profileConsumableData = SIPPYCUP.db.profile[consumableData.profile];
	if not profileConsumableData then return; end

	if SIPPYCUP.Popups.IsIgnored(consumableData.profile) then return; end

	-- Bag data is desynch'd from UNIT_AURA fires, defer handling.
	if SIPPYCUP.Items.bagUpdateUnhandled then
	end

	-- Establish if we're dealing with a trackable or nontrackable item.
	local nonTrackable = consumableData.nonTrackable;

	-- First, let's grab the latest currentInstanceID (or have it be nil if none which is fine).
	profileConsumableData.currentInstanceID = auraInfo and auraInfo.auraInstanceID or auraInstanceID or nil;

	-- Then we do a check on the special checks on currentStacks
	-- If an expire is coming, we pretend all stacks are at 0 regardless if we can track it or not.
	if reason == 2 then
		profileConsumableData.currentStacks = 0;
	-- Then we check if we're dealing with nontrackable consumables, as they're special
	elseif not auraInfo and nonTrackable then
		-- If a nontrackable was added, it'll be at 1 regardless. As the stack is applied before we even get here.
		if reason == 0 then
			profileConsumableData.currentStacks = 1;
		-- If removed, we know the currentStacks are at 0 and thus we set it to 0.
		elseif reason == 1 then
			profileConsumableData.currentStacks = 0;
		end
	-- On addition, the currentstacks will always be 1 (sometimes it'll say 0 for 1 applications).
	elseif auraInfo and reason == 0 and auraInfo.applications == 0 then
		profileConsumableData.currentStacks = 1;
	else -- Once we're past the special exception stacks, we do the normal auraInfo checks.
		profileConsumableData.currentStacks = auraInfo and auraInfo.applications or 0;
	end

	-- If the consumable does not support stacks, we always desire just 1.
	if not consumableData.stacks then
		profileConsumableData.desiredStacks = 1;
	end

	local popupKey = "SIPPYCUP_REFRESH_" .. consumableData.loc;
	local isShown  = StaticPopup_Visible(popupKey);

	if profileConsumableData.currentStacks < profileConsumableData.desiredStacks then

		if isShown then
			StaticPopup_Hide(popupKey);
		end

		if reason == 1 and mainMenu ~= true and (not isShown or consumableData.preExpiration ~= 0) then
			HandleAlerts(consumableData.loc, true);
		end

		local requiredStacks = profileConsumableData.desiredStacks - profileConsumableData.currentStacks;
		CreateConsumablePopup(consumableData, requiredStacks, reason);
		HandleAlerts(consumableData.loc);
	elseif profileConsumableData.currentStacks == profileConsumableData.desiredStacks then

		if isShown then
			StaticPopup_Hide(popupKey);
		end

		HandleAlerts(consumableData.loc, true);
	end
end

function SIPPYCUP.Popups.HideAllRefreshPopups()
	for i = 1, STATICPOPUP_NUMDIALOGS do
		local frame = _G["StaticPopup"..i];
		if frame and frame:IsShown() and frame.which and frame.which:match("^SIPPYCUP_REFRESH_") then
			StaticPopup_Hide(frame.which);
		end
	end
end
