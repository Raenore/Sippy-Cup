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
		HandleAlerts(data.loc, true);
	end,

	OnAlt = function(self, data)
		sessionData[data.profile] = true;
	end,

	OnHide = function(popup)
		if popup.popupButton then
			popup.popupButton:Hide();
			popup.popupButton:SetParent(nil);
			popup.popupButton = nil;
		end

		if popup.popupKey and StaticPopupDialogs[popup.popupKey] then
			StaticPopupDialogs[popup.popupKey] = nil;
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
---@return nil
local function CreateConsumablePopup(consumableData, requiredStacks)
	local popupKey = "SIPPYCUP_REFRESH_" .. consumableData.loc;
	local popupData = ClonePopupTemplate(BaseConsumablePopupTemplate);

	popupData.OnShow = function(popup, data)
		local popupButton = CreateFrame("Button", nil, popup, "StaticPopupButtonTemplate, SecureActionButtonTemplate");
		popupButton:SetAttribute("type", "item");
		popupButton:SetAttribute("item", data.item);
		popupButton:RegisterForClicks("AnyUp", "AnyDown");

		popupButton:SetAllPoints(popup.button1);
		popupButton:SetText(data.buttonText);

		if S and S.HandleButton then
			S:HandleButton(popupButton);
		end

		popup.popupButton = popupButton;

		popup.button1:Hide();

		local button = popup.button3;
		if button then
			button:HookScript("OnEnter", function()
				GameTooltip:SetOwner(button, "ANCHOR_BOTTOM", 0, -5);
				GameTooltip:SetText(L.POPUP_IGNORE_TT, nil, nil, nil, nil, true);
				GameTooltip:Show();
			end)
			button:HookScript("OnLeave", function()
				GameTooltip:Hide();
			end)
		end

		popupButton:Show();

		-- Handle missing item situation after popup has already spawned, as button will do nothing.
		if popupButton then
			popupButton:HookScript("OnEnter", function()
				local itemCount = C_Item.GetItemCount(consumableData.itemID);
				local tooltipText;

				if itemCount == 0 then
					tooltipText = "|cnWARNING_FONT_COLOR:" .. L.POPUP_LACKING_TEXT:gsub("^%l", string.upper) .. "|r";
				elseif itemCount < requiredStacks then
					tooltipText = "|cnWARNING_FONT_COLOR:" .. L.POPUP_LACKING_TEXT_AMOUNT:gsub("^%l", string.upper) .. "|n(" .. itemCount .. " / " .. requiredStacks .. ")|r";
				end

				if tooltipText then
					GameTooltip:SetOwner(popupButton, "ANCHOR_BOTTOM", 0, -5);
					GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true);
					GameTooltip:Show();
				end
			end)
			popupButton:HookScript("OnLeave", function()
				GameTooltip:Hide();
			end)
		end
	end

	StaticPopupDialogs[popupKey] = popupData;

	local text = SIPPYCUP.AddonMetadata.title;

	-- Builds the popup message with optional item icon and capitalizes the first letter of the follow-up text if enabled.
	if SIPPYCUP.db.global.PopupIcon then
		text = text .. "|n|n|TInterface\\Icons\\" .. SIPPYCUP_ICON.RetrieveIcon(consumableData.name) .. ":" .. ICON_SIZE .. "|t |cnGREEN_FONT_COLOR:" .. consumableData.name .. "|r|n|n" .. L.POPUP_TEXT:gsub("^%l", string.upper);
	else
		text = text .. "|n|n|cnGREEN_FONT_COLOR:" .. consumableData.name .. "|r " .. L.POPUP_TEXT;
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
	local consumable = SIPPYCUP.Consumables.ByName[itemName];
	if not consumable then
		return;
	end

	-- If the consumable is not enabled, kill all its associated popups.
	if not enabled then
		local popupKey = "SIPPYCUP_REFRESH_" .. consumable.loc;
		HandleAlerts(consumable.loc, true);

		if StaticPopup_Visible(popupKey) then
			StaticPopup_Hide(popupKey);
		end
		return;
	end

	-- Check if the aura is active, and use that further information later.
	local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(consumable.auraID);

	SIPPYCUP.Popups.QueuePopupAction(not auraInfo, consumable.auraID, auraInfo, auraInfo and auraInfo.auraInstanceID, mainMenu);
end

local DEBOUNCE_DELAY = 0.05;
local pendingCalls = {};

---QueuePopupAction queues up popup action calls, adding a debounce to avoid repeated calls (UNIT_AURA & COMBAT_LOG_EVENT_UNFILTERED).
---@param removal boolean Whether the aura is getting removed or not.
---@param auraID number The aura ID.
---@param auraInfo table|nil Information about the aura, or nil if not present.
---@param auraInstanceID number|nil The instance ID of the aura, or nil if not applicable.
---@param mainMenu boolean? Whether this was triggered from the Main Menu hide or not.
---@return nil
function SIPPYCUP.Popups.QueuePopupAction(removal, auraID, auraInfo, auraInstanceID, mainMenu)
	if InCombatLockdown() then return; end

	local args = { removal, auraID, auraInfo, auraInstanceID, mainMenu };

	if pendingCalls[auraID] then
		-- Update the existing entry with the latest arguments
		pendingCalls[auraID].args = args;
		return
	end

	-- first call for this auraID: store args and schedule
	pendingCalls[auraID] = { args = args };
	C_Timer.After(DEBOUNCE_DELAY, function()
		local entry = pendingCalls[auraID];
		pendingCalls[auraID] = nil;

		if not entry or not entry.args then
			return;
		end

		local rem, aID, aI, aIID, mM = unpack(entry.args)
		SIPPYCUP.Popups.HandlePopupAction(rem, aID, aI, aIID, mM);
	end)
end

---HandlePopupAction executes the popup action for a consumable aura.
---@param removal boolean Whether the aura is getting removed or not.
---@param auraID number The aura ID.
---@param auraInfo table|nil Information about the aura, or nil if not present.
---@param auraInstanceID number|nil The instance ID of the aura, or nil if not applicable.
---@param mainMenu boolean? Whether this was triggered from the Main Menu hide or not.
---@return nil
function SIPPYCUP.Popups.HandlePopupAction(removal, auraID, auraInfo, auraInstanceID, mainMenu)
	if InCombatLockdown() then return end

	local consumableData = SIPPYCUP.Consumables.ByAuraID[auraID];
	if not consumableData then return; end

	local profileConsumableInfo = SIPPYCUP.db.profile[consumableData.profile];
	if not profileConsumableInfo then return; end

	local sessionProfile = sessionData[consumableData.profile];
	if sessionProfile then return; end

	profileConsumableInfo.currentInstanceID = auraInfo and auraInfo.auraInstanceID or auraInstanceID or nil;
	profileConsumableInfo.currentStacks = auraInfo and auraInfo.applications or 0;

	if not removal and profileConsumableInfo.currentStacks == 0 then
		profileConsumableInfo.currentStacks = 1;
	end
	if not consumableData.stacks then
		profileConsumableInfo.desiredStacks = 1;
	end

	local popupKey = "SIPPYCUP_REFRESH_" .. consumableData.loc;
	local isShown  = StaticPopupDialogs[popupKey] and true or false;

	if isShown then
		StaticPopup_Hide(popupKey);
	end

	if removal and not isShown and mainMenu ~= true then
		HandleAlerts(consumableData.loc, true);
	end

	if profileConsumableInfo.currentStacks < profileConsumableInfo.desiredStacks then
		local requiredStacks = profileConsumableInfo.desiredStacks - profileConsumableInfo.currentStacks;
		CreateConsumablePopup(consumableData, requiredStacks);
		HandleAlerts(consumableData.loc);
	elseif profileConsumableInfo.currentStacks == profileConsumableInfo.desiredStacks then
		HandleAlerts(consumableData.loc, true);
		if StaticPopupDialogs[popupKey] then
			StaticPopup_Hide(popupKey);
		end
	end
end
