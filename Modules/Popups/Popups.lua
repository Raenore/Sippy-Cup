-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Popups = {};

local L = SIPPYCUP.L;
local SharedMedia = LibStub("LibSharedMedia-3.0");

SIPPYCUP.Popups.Reason = {
	ADDITION = 0,
	REMOVAL = 1,
	PRE_EXPIRATION = 2,
};

---PlayPopupSound plays the chosen alert sound during a popup.
---@return nil
local function PlayPopupSound()
	local soundPath = SharedMedia:Fetch("sound", SIPPYCUP.global.AlertSoundID);
	if soundPath then
		PlaySoundFile(soundPath, "Master");
	end
end

local alertThrottle = false;
local lastProfileAlert;

---HandleAlerts handles playing a popup sound and/or flashing the taskbar.
---Ensures only one alert is triggered per frame to prevent spamming,
---especially during situations where many popups appear at once (e.g. startup).
---@return nil
local function HandleAlerts()
	if alertThrottle then
		return;
	end
	alertThrottle = true;

	if SIPPYCUP.global.AlertSound then
		PlayPopupSound();
	end
	if SIPPYCUP.global.FlashTaskbar then
		FlashClientIcon();
	end

	-- We save the last profile an alert played for, so we can play a new
	-- alert for cases where a popup exists on both profiles when it is switched.
	lastProfileAlert = SIPPYCUP.Database.GetCurrentProfileName();

	RunNextFrame(function()
		alertThrottle = false;
	end);
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

local popupPool = {};
local activePopups = {};
local popupQueue = {};
local MAX_POPUPS = 5;

-- Hold deferred popups (for item counts)
SIPPYCUP.Popups.deferredActions = SIPPYCUP.Popups.deferredActions or {};
local deferredActions = SIPPYCUP.Popups.deferredActions;

---RemoveDeferredActionsByLoc Removes all deferred popup actions for a given loc key.
---@param loc string The loc key identifier to remove.
---@return nil
local function RemoveDeferredActionsByLoc(loc)
	if not deferredActions then return; end

	for i = #deferredActions, 1, -1 do
		if deferredActions[i].loc == loc then
			tremove(deferredActions, i);
		end
	end
end

-- Track active popups by loc
SIPPYCUP.Popups.activeByLoc = SIPPYCUP.Popups.activeByLoc or {};
local activePopupByLoc = SIPPYCUP.Popups.activeByLoc;

---CalculatePopupOffset determines the vertical position and anchor for stacked popups.
---@param index number The 1-based index of the popup in the stack.
---@return number offsetY Calculated vertical offset.
---@return string anchorPoint Screen anchor ("TOP", "BOTTOM", or "CENTER").
local function CalculatePopupOffset(index)
	local position = "TOP"; -- default fallback

	if SIPPYCUP and SIPPYCUP.db and SIPPYCUP.db.global and SIPPYCUP.global.PopupPosition then
		position = SIPPYCUP.global.PopupPosition;
	end

	if position == "BOTTOM" then
		return 100 + ((index - 1) * 120), "BOTTOM";
	elseif position == "CENTER" then
		return ((index - 1) * -120), "CENTER";
	else -- default to TOP
		return -100 - ((index - 1) * 120), "TOP";
	end
end

---CreatePopup creates a new popup frame of the specified template type,
---sets up its scripts, skins it via ElvUI, and adds it to the popup pool.
---@param templateType string? The popup frame template to use. Defaults to "SIPPYCUP_RefreshPopupTemplate".
---@return Frame popup The newly created popup frame.
local function CreatePopup(templateType)
	templateType = templateType or "SIPPYCUP_RefreshPopupTemplate";
	local popup = CreateFrame("Frame", nil, UIParent, templateType);
	popup.templateType = templateType;

	popup:SetScript("OnHide", function(self)
		if not UIParent:IsShown() then
			-- Don't hide popups when UIParent is hidden (ALT+Z / ElvUI AFK mode) so positions don't get broken.
			return;
		end

		-- Remove from activePopups
		for i, frame in ipairs(activePopups) do
			if frame == self then
				tremove(activePopups, i);
				break;
			end
		end

		-- Clear loc mapping if it exists
		local loc = self.popupData and self.popupData.consumableData and self.popupData.consumableData.loc;
		if loc then
			activePopupByLoc[loc] = nil;
		end

		-- Reposition remaining popups
		for i, frame in ipairs(activePopups) do
			local offsetY, anchorPoint = CalculatePopupOffset(i);
			frame:ClearAllPoints();
			frame:SetPoint(anchorPoint, UIParent, anchorPoint, 0, offsetY);
		end

		-- Show next in queue if any
		if #popupQueue > 0 then
			local nextData = tremove(popupQueue, 1);
			SIPPYCUP.Popups.CreateReminderPopup(nextData);
		end

		GameTooltip:Hide(); -- Hide any tooltip lingering from this popup
	end);

	SIPPYCUP.ElvUI.RegisterSkinnableElement(popup, "frame", true);

	if not popup.isScriptSetup then -- Use a flag to ensure this runs only once per popup instance
		popup.ItemIcon:SetScript("OnEnter", function(self)
			local currentPopup = self:GetParent();
			local data = currentPopup and currentPopup.popupData;
			local itemID = data and data.consumableData and data.consumableData.itemID;
			if not itemID then return; end

			local item = Item:CreateFromItemID(itemID);

			item:ContinueOnItemLoad(function()
				local itemLink = item:GetItemLink();
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
				GameTooltip:SetHyperlink(itemLink);
				GameTooltip:Show();
			end);
		end);

		popup.ItemIcon:SetScript("OnLeave", function()
			GameTooltip:Hide();
		end);

		if templateType == "SIPPYCUP_RefreshPopupTemplate" then
			popup.RefreshButton:HookScript("OnEnter", function(self)
				local tooltipText;
				local currentPopup = self:GetParent();
				if not self:IsEnabled() then
					tooltipText = "|cnWARNING_FONT_COLOR:" .. L.POPUP_ON_COOLDOWN_TEXT:gsub("^%l", string.upper) .. "|r";
				else
					if currentPopup and currentPopup.popupData then
						local consumableData = currentPopup.popupData.consumableData;
						local profileConsumableData = currentPopup.popupData.profileConsumableData;

						local itemID = consumableData.itemID;
						local itemCount = C_Item.GetItemCount(itemID);
						local maxCount = itemCount + profileConsumableData.currentStacks;

						if itemCount == 0 then
							tooltipText = "|cnWARNING_FONT_COLOR:" .. L.POPUP_NOT_IN_INVENTORY_TEXT:gsub("^%l", string.upper) .. "|r";
						elseif maxCount < profileConsumableData.desiredStacks then
							tooltipText = "|cnWARNING_FONT_COLOR:" .. L.POPUP_NOT_ENOUGH_IN_INVENTORY_TEXT:gsub("^%l", string.upper):format(profileConsumableData.desiredStacks - maxCount);
						end
					end
				end
				if tooltipText then
					GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -5);
					GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true);
					GameTooltip:Show();
				end
			end);

			popup.RefreshButton:HookScript("OnLeave", function()
				GameTooltip:Hide();
			end);

			popup.IgnoreButton:HookScript("OnEnter", function()
				GameTooltip:SetOwner(popup.IgnoreButton, "ANCHOR_BOTTOM", 0, -5);
				GameTooltip:SetText(IGNORE, 1, 1, 1);
				GameTooltip:AddLine(L.POPUP_IGNORE_TT, nil, nil, nil, true);
				GameTooltip:Show();
			end);

			popup.IgnoreButton:HookScript("OnLeave", function()
				GameTooltip:Hide();
			end);

			popup.IgnoreButton:SetScript("OnClick", function()
				if sessionData and popup.popupData and popup.popupData.consumableData then
					sessionData[popup.popupData.consumableData.auraID] = true;
					SIPPYCUP_ConfigMenuFrame:RefreshWidgets();
				end
				popup:Hide();
			end);
		elseif templateType == "SIPPYCUP_MissingPopupTemplate" then
			popup.OkayButton:SetScript("OnClick", function()
				popup:Hide();
			end);
		end

		popup.CloseButton:SetScript("OnClick", function()
			popup:Hide();
		end);

		popup.isScriptSetup = true;
	end

	tinsert(popupPool, popup);
	return popup;
end

---GetPopup returns an available popup frame of the specified template type.
---It reuses inactive popups from the pool or creates a new one if under the max limit.
---@param templateType string? The optional popup template type, defaults to "SIPPYCUP_RefreshPopupTemplate".
---@return Frame|nil popup The popup frame or nil if the max popup count is reached.
local function GetPopup(templateType)
	templateType = templateType or "SIPPYCUP_RefreshPopupTemplate";

	for _, popup in ipairs(popupPool) do
		if not popup:IsShown() and popup.templateType == templateType then
			return popup;
		end
	end

	if #popupPool < MAX_POPUPS then
		return CreatePopup(templateType);
	end

	return nil;
end

---UpdatePopupVisuals updates the popup frame visuals based on the given data.
---@param popup Frame The popup frame to update.
---@param data table Holds all the popup information.
---@return nil
local function UpdatePopupVisuals(popup, data)
	local itemID = data.consumableData.itemID;
	local itemName, itemLink = C_Item.GetItemInfo(itemID);
	itemName = itemName or data.consumableData.name;

	local item = Item:CreateFromItemID(itemID);

	item:ContinueOnItemLoad(function()
		local icon = item:GetItemIcon();
		-- If for some reason itemName or itemLink is still not valid by now, pull it again.
		if not itemName or not itemLink then
			itemName = item:GetItemName();
			itemLink = item:GetItemLink();
			-- Save it for good measure
			data.consumableData.name = itemName;
		end

		popup.Title:SetText(SIPPYCUP.AddonMetadata.title);
		popup.Name:SetText("|cnGREEN_FONT_COLOR:" .. itemName .. "|r");
		popup.ItemIcon:SetTexture(icon);

		if popup.templateType == "SIPPYCUP_RefreshPopupTemplate" then
			local text = L.POPUP_LOW_STACK_COUNT_TEXT;
			if data.reason == SIPPYCUP.Popups.Reason.PRE_EXPIRATION then
				text = L.POPUP_EXPIRING_SOON_TEXT;
			elseif not data.consumableData.stacks then
				text = L.POPUP_NOT_ACTIVE_TEXT;
			end

			popup.Text:SetText((text or ""):gsub("^%l", string.upper));
			popup.Counter:SetText(data.profileConsumableData.currentStacks .. " / " .. data.profileConsumableData.desiredStacks);

			popup.RefreshButton:SetText(REFRESH);
			popup.RefreshButton:SetAttribute("type", "item");
			popup.RefreshButton:SetAttribute("item", itemLink or itemID); -- should be item name/link
			popup.RefreshButton:SetAttribute("useOnKeyDown", false); -- Only use on key up
			popup.RefreshButton:RegisterForClicks("AnyUp"); -- Only register for "AnyUp" clicks

			popup.IgnoreButton:SetText(IGNORE);

			-- Handle cooldown for RefreshButton
			local startTime, duration = C_Container.GetItemCooldown(itemID);
			local remaining = 0;
			if duration and duration > 0 then
				remaining = (startTime + duration) - GetTime();
			end

			if remaining > 0 then
				popup.cooldownActive = true;
				popup.RefreshButton:Disable();
				popup.RefreshButton:EnableMouse(true); -- Keep mouse enabled for tooltip
				GameTooltip:Hide(); -- Hide any active tooltip immediately
				C_Timer.After(remaining, function()
					if popup.RefreshButton and popup.RefreshButton:IsShown() then
						GameTooltip:Hide();
						popup.cooldownActive = false;
						popup.RefreshButton:Enable();
					end
				end);
			else
				popup.cooldownActive = false;
				popup.RefreshButton:Enable();
			end
		elseif popup.templateType == "SIPPYCUP_MissingPopupTemplate" then
			local itemCount = C_Item.GetItemCount(itemID);
			local text = L.POPUP_INSUFFICIENT_NEXT_REFRESH_TEXT:format(itemCount, data.profileConsumableData.desiredStacks);
			popup.Text:SetText((text or ""):gsub("^%l", string.upper));
			popup.OkayButton:SetText(OKAY);

			if ElvUI and ElvUI[1] and popup.SetBackdropBorderColor then
				popup:SetBackdropBorderColor(1, 0, 0);
			end
		end
	end);
end

---@class ReminderPopupData
---@field consumableData table Contains the consumable's data (e.g. itemID, loc, profile, etc.).
---@field profileConsumableData table Profile-related data for the consumable (e.g. enabled state, currentInstanceID, etc.).
---@field requiredStacks number Number of item stacks required for the reminder to be satisfied.
---@field reason number Why the popup was triggered: 0 = add/update, 1 = removal, 2 = pre-expire.
---@field itemCount number Number of matching items in the player's inventory when the popup is created.

---CreateReminderPopup Displays a popup with reminder and item interaction options.
---@param data ReminderPopupData Table containing all necessary information about the consumable and profile.
---@param templateTypeID? number What kind of template to create (0 = reminder, 1 = missing); defaults to 0.
function SIPPYCUP.Popups.CreateReminderPopup(data, templateTypeID)
	if not SIPPYCUP or not SIPPYCUP.db or not SIPPYCUP.db.global then return; end

	local loc = data.consumableData.loc;
	templateTypeID = templateTypeID or 0;  -- default to 0 if nil
	local templateType = (templateTypeID == 1) and "SIPPYCUP_MissingPopupTemplate" or "SIPPYCUP_RefreshPopupTemplate";
	local popup = activePopupByLoc[loc];
	local isNew = not popup or not popup:IsShown();

	-- If correct stack count reached, we're done!
	if data.reason == SIPPYCUP.Popups.Reason.ADDITION and templateTypeID == 0 and data.requiredStacks <= 0 then
		if popup and popup:IsShown() then
			popup:Hide();
		end

		-- If user wants a missing reminder, we'll do that now.
		if data.itemCount < data.profileConsumableData.desiredStacks and SIPPYCUP.global.InsufficientReminder then
			SIPPYCUP.Popups.CreateReminderPopup(data, 1);
		end
		return;
	elseif popup and popup.templateType == "SIPPYCUP_MissingPopupTemplate" then
	-- If missing popup is still shown, we remove that first before showing new ones.
		if popup and popup:IsShown() then
			popup:Hide();
		end

		SIPPYCUP.Popups.CreateReminderPopup(data, 0);
		return;
	end

	if isNew then
		popup = GetPopup(templateType);
		if not popup then
			tinsert(popupQueue, data);
			return;
		end
	end

	-- Common data setup for both existing and new popups
	popup.popupData = data;

	-- Position the popup only if it's a new instance being added to the active list
	-- or if it was previously hidden and is now being re-shown.
	if isNew then
		local index = #activePopups + 1;
		local offsetY, anchor = CalculatePopupOffset(index);
		popup:ClearAllPoints();
		popup:SetPoint(anchor, UIParent, anchor, 0, offsetY);
	end

	-- Update all visual elements and button states (common logic)
	UpdatePopupVisuals(popup, data);

	-- Show the popup and manage active lists
	if not popup:IsShown() then
		popup:Show();
	end

	if isNew then
		tinsert(activePopups, popup); -- Add to active list only if it's a new instance
		activePopupByLoc[loc] = popup; -- Store in lookup for loc-based replacement
		HandleAlerts();
	elseif data.reason == SIPPYCUP.Popups.Reason.REMOVAL then
		-- Removal popups should always fire an alert, because they might come after pre-expiration
		HandleAlerts();
	elseif lastProfileAlert ~= SIPPYCUP.Database.GetCurrentProfileName() then
		-- If profile change happens, fire an alert as-is for popups (throttle will still hold them)
		HandleAlerts();
	end
end

---Toggle handles what should happen after a consumable is enabled or disabled in regards to popup logic.
---@param itemName string The toggled consumable's name.
---@param enabled boolean Whether the consumable tracking is enabled or disabled.
---@return nil
function SIPPYCUP.Popups.Toggle(itemName, enabled)
	-- Grab the right consumable by name, and check if aura exists.
	local consumableData = SIPPYCUP.Consumables.ByName[itemName];
	if not consumableData then
		return;
	end
	SIPPYCUP.Database.RebuildAuraMap();

	local profileConsumableData = SIPPYCUP.profile[consumableData.auraID];
	-- If the consumable is not enabled, kill all its associated popups and timers!
	if not enabled then
		RemoveDeferredActionsByLoc(consumableData.loc);
		local existingPopup = SIPPYCUP.Popups.activeByLoc[consumableData.loc];

		if existingPopup and existingPopup:IsShown() then
			existingPopup:Hide();
		end

		if profileConsumableData.noAuraTrackable then
			SIPPYCUP.Items.CancelItemTimer(nil, consumableData.auraID);
		else
			SIPPYCUP.Auras.CancelPreExpirationTimer(nil, consumableData.auraID);
		end

		return;
	end

	-- For the enabled case: we need to check auraInfo and possibly cooldown. We'll define continuation logic.
	local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(consumableData.auraID);
	local active = false;
	local startTime = 0;

	-- If item can only be tracked by the item cooldown (worst)
	if consumableData.itemTrackable then
		startTime = C_Item.GetItemCooldown(consumableData.itemID);
		if startTime and startTime > 0 then
			active = true;
		end
	-- If item can be tracked through the spell cooldown (fine).
	elseif consumableData.spellTrackable then
		local spellCooldownInfo = C_Spell.GetSpellCooldown(consumableData.auraID);
		startTime = spellCooldownInfo and spellCooldownInfo.startTime;
		if startTime and startTime > 0 then
			active = true;
		end
	end

	local preExpireFired;
	if profileConsumableData.noAuraTrackable then
		preExpireFired = SIPPYCUP.Items.CheckNoAuraSingleConsumable(profileConsumableData, consumableData.auraID, nil, startTime);
	else
		preExpireFired = SIPPYCUP.Auras.CheckPreExpirationForSingleConsumable(profileConsumableData);
	end

	-- Only queue popup if no pre-expiration has already fired
	if not preExpireFired then
		-- auraInfo may be truthy/table; active is boolean from cooldown check
		SIPPYCUP.Popups.QueuePopupAction((auraInfo or active) and SIPPYCUP.Popups.Reason.ADDITION or SIPPYCUP.Popups.Reason.REMOVAL, consumableData.auraID, auraInfo, auraInfo and auraInfo.auraInstanceID, "Toggle");
	end
end

local DEBOUNCE_DELAY = 0.05;
local pendingCalls = {};

---QueuePopupAction queues up popup action calls, adding a debounce to avoid repeated calls (UNIT_AURA & COMBAT_LOG_EVENT_UNFILTERED).
---@param reason number Why a popup is getting called (0 - add/update, 1 = removal, 2 = pre-expire)
---@param auraID number The aura ID.
---@param auraInfo table|nil Information about the aura, or nil if not present.
---@param auraInstanceID number|nil The instance ID of the aura, or nil if not applicable.
---@param caller string What function called the popup action.
---@return nil
function SIPPYCUP.Popups.QueuePopupAction(reason, auraID, auraInfo, auraInstanceID,  caller)
	if InCombatLockdown() then return; end

	-- If MSP status checks are on and the character is currently OOC, we skip everything.
	if SIPPYCUP.MSP.IsEnabled() and SIPPYCUP.global.MSPStatusCheck and SIPPYCUP.Player.OOC then
		return;
	end

	-- Use a composite key of auraID and reason so different reasons don't collide
	local key = tostring(auraID) .. "-" .. tostring(reason);
	local args = { reason, auraID, auraInfo, auraInstanceID, caller };

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

		local res, aID, aI, aIID, c = unpack(entry.args);
		SIPPYCUP.Popups.HandlePopupAction(res, aID, aI, aIID, c);
	end)
end

---HandlePopupAction executes the popup action for a consumable aura.
---@param reason number Why a popup is getting called (0 - add/update, 1 = removal, 2 = pre-expire)
---@param auraID number The aura ID.
---@param auraInfo table|nil Information about the aura, or nil if not present.
---@param auraInstanceID number|nil The instance ID of the aura, or nil if not applicable.
---@param caller string What function called the popup action.
---@return nil
function SIPPYCUP.Popups.HandlePopupAction(reason, auraID, auraInfo, auraInstanceID, caller)
	if InCombatLockdown() then return end;

	SIPPYCUP_OUTPUT.Debug({ caller = caller });

	local consumableData = SIPPYCUP.Consumables.ByAuraID[auraID];
	local profileConsumableData = consumableData and SIPPYCUP.profile[consumableData.auraID];

	if not consumableData or not profileConsumableData or SIPPYCUP.Popups.IsIgnored(consumableData.auraID) then
		return;
	end

	-- Removal of a spell/aura count generally is not due to an item's action, mark bag as synchronized.
	if reason == 1 then
		SIPPYCUP.Items.HandleBagUpdate();
	end

	-- Bag data is desynch'd from UNIT_AURA fires, defer handling.
	if SIPPYCUP.Items.bagUpdateUnhandled then
		-- Consumable items go to deferredPopups to wait for BAG_UPDATE_DELAYED.
		tinsert(deferredActions, {
			loc = consumableData.loc,
			auraID = auraID,
			reason = reason,
			auraInfo = auraInfo,
			auraInstanceID = auraInstanceID,
			caller = caller
		});
		return;
	end

	-- First, let's grab the latest currentInstanceID (or have it be nil if none which is fine).
	profileConsumableData.currentInstanceID = (auraInfo and auraInfo.auraInstanceID) or auraInstanceID;
	profileConsumableData.currentStacks = SIPPYCUP.Auras.CalculateCurrentStacks(auraInfo, auraID, reason);

	-- If the consumable does not support stacks, we always desire just 1.
	profileConsumableData.desiredStacks = consumableData.stacks and profileConsumableData.desiredStacks or 1;

	local requiredStacks = profileConsumableData.desiredStacks - profileConsumableData.currentStacks;
	local itemCount = C_Item.GetItemCount(consumableData.itemID);

	SIPPYCUP.Popups.CreateReminderPopup({
		consumableData = consumableData,
		profileConsumableData = profileConsumableData,
		requiredStacks = requiredStacks,
		reason = reason,
		itemCount = itemCount
	});
end

--- HideAllRefreshPopups cleans up all visible and queued popups.
function SIPPYCUP.Popups.HideAllRefreshPopups()
	-- Clear the popup queue entirely
	wipe(popupQueue);

	-- Hide and remove all active popups
	for i = #activePopups, 1, -1 do
		local popup = activePopups[i];
		popup:Hide(); -- Cleans up activePopupByLoc and other stuff.
	end
end

---HandleDeferredActions Processes and flushes all queued popup actions.
-- Called after bag data is synced (BAG_UPDATE_DELAYED) to ensure accurate context.
function SIPPYCUP.Popups.HandleDeferredActions()
	if not deferredActions then return; end

	for _, action in ipairs(deferredActions) do
		SIPPYCUP.Popups.QueuePopupAction(
			action.reason,
			action.auraID,
			action.auraInfo,
			action.auraInstanceID,
			action.caller
		);
	end

	wipe(deferredActions);
end
