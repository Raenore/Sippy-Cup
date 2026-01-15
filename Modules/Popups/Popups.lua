-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Popups = {};

local L = SIPPYCUP.L;
local SharedMedia = LibStub("LibSharedMedia-3.0");

SIPPYCUP.Popups.Reason = {
	ADDITION = 0,
	REMOVAL = 1,
	PRE_EXPIRATION = 2,
	TOGGLE = 3,
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

---ResetIgnored clears all the session-based option popups.
---@return nil
function SIPPYCUP.Popups.ResetIgnored()
	for auraID in pairs(sessionData) do
		local profileOptionData = SIPPYCUP.Profile[auraID];
		SIPPYCUP.Popups.Toggle(nil, auraID, profileOptionData.enable);
	end

	wipe(sessionData);
end

---IsEmpty returns true if no options are currently ignored in the session.
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
		local loc = self.popupData and self.popupData.optionData and self.popupData.optionData.loc;
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
			SIPPYCUP.Popups.HandleReminderPopup(nextData);
		end

		GameTooltip:Hide(); -- Hide any tooltip lingering from this popup
	end);

	SIPPYCUP.ElvUI.RegisterSkinnableElement(popup, "frame", true);

	if not popup.isScriptSetup then -- Use a flag to ensure this runs only once per popup instance
		popup.ItemIcon:SetScript("OnEnter", function(self)
			local currentPopup = self:GetParent();
			local data = currentPopup and currentPopup.popupData;
			local itemID = data and data.optionData and data.optionData.itemID;
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
				local isFlying = IsFlying();
				local tooltipText;
				local currentPopup = self:GetParent();
				local popupData = currentPopup and currentPopup.popupData;

				if isFlying then
					popupData.isFlying = true;
					self:Disable();
				end

				if not self:IsEnabled() then
					if isFlying then
						tooltipText = "|cnWARNING_FONT_COLOR:" .. L.POPUP_IN_FLIGHT_TEXT .. "|r";
					elseif popupData and popupData.optionData and popupData.optionData.delayedAura then
						tooltipText = "|cnWARNING_FONT_COLOR:" .. L.POPUP_FOOD_BUFF_TEXT .. "|r";
					else
						tooltipText = "|cnWARNING_FONT_COLOR:" .. L.POPUP_ON_COOLDOWN_TEXT .. "|r";
					end
				else
					if popupData then
						local optionData = popupData.optionData;
						if optionData.type == SIPPYCUP.Options.Type.CONSUMABLE then
							local profileOptionData = popupData.profileOptionData;

							local itemID = optionData.itemID;
							local itemCount = C_Item.GetItemCount(itemID);
							local maxCount = itemCount + profileOptionData.currentStacks;

							if itemCount == 0 then
								tooltipText = "|cnWARNING_FONT_COLOR:" .. L.POPUP_NOT_IN_INVENTORY_TEXT .. "|r";
							elseif maxCount < profileOptionData.desiredStacks then
								tooltipText = "|cnWARNING_FONT_COLOR:" .. L.POPUP_NOT_ENOUGH_IN_INVENTORY_TEXT:format(profileOptionData.desiredStacks - maxCount);
							end
						end
					end
				end
				if tooltipText then
					GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -5);
					GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true);
					GameTooltip:Show();
				end
			end);

			popup.RefreshButton:HookScript("OnLeave", function(self)
				local currentPopup = self:GetParent();
				local popupData = currentPopup and currentPopup.popupData;

				-- We re-enable the button always and account for potential isFlying left-overs during landing.
				if IsFlying() or (not IsFlying() and popupData.isFlying) then
					popupData.isFlying = false;
					self:Enable();
				end
				GameTooltip:Hide();
			end);

			popup.RefreshButton:HookScript("OnClick", function(self)
				-- Prevent spam; resets when next charge is ready.
				local currentPopup = self:GetParent();
				local popupData = currentPopup and currentPopup.popupData;
				local optionData = popupData.optionData;
				local itemID = optionData.itemID;
				local itemCount = C_Item.GetItemCount(itemID);

				-- If no more charges, don't disable as next charge doesn't exist to re-enable.
				if itemCount > 0 then
					self:Disable();
				else
					self:Enable();
				end
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
				if sessionData and popup.popupData and popup.popupData.optionData then
					sessionData[popup.popupData.optionData.auraID] = true;
					if SIPPYCUP.configFrame then
						SIPPYCUP_ConfigMenuFrame:RefreshWidgets();
					end
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

	popupPool[#popupPool + 1] = popup;
	return popup;
end

---GetPopup returns an available popup frame of the specified template type.
---It reuses inactive popups from the pool or creates a new one if under the max limit.
---@param templateType string? The optional popup template type, defaults to "SIPPYCUP_RefreshPopupTemplate".
---@return Frame? popup The popup frame or nil if the max popup count is reached.
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
---@param data ReminderPopupData Table containing all necessary information about the option and profile.
---@return nil
local function UpdatePopupVisuals(popup, data)
	local optionData = data.optionData;
	local profileOptionData = data.profileOptionData;

	local itemID = optionData.itemID;

	local itemName, itemLink = C_Item.GetItemInfo(itemID);
	itemName = itemName or optionData.name;

	local item = Item:CreateFromItemID(itemID);

	item:ContinueOnItemLoad(function()
		local icon = item:GetItemIcon()
		-- If for some reason itemName or itemLink is still not valid by now, pull it again.
		if not itemName or not itemLink then
			itemName = item:GetItemName();
			itemLink = item:GetItemLink();
			-- Save it for good measure
			optionData.name = itemName;
		end

		popup.Title:SetText(SIPPYCUP.AddonMetadata.title);
		if #itemName > 30 then
			itemName = string.sub(itemName, 1, 27) .. "...";
		end
		popup.Name:SetText("|cnGREEN_FONT_COLOR:" .. itemName .. "|r");
		popup.ItemIcon:SetTexture(icon);

		if popup.templateType == "SIPPYCUP_RefreshPopupTemplate" then
			local text = L.POPUP_LOW_STACK_COUNT_TEXT;
			if data.reason == SIPPYCUP.Popups.Reason.PRE_EXPIRATION then
				text = L.POPUP_EXPIRING_SOON_TEXT;
			elseif not optionData.stacks then
				text = L.POPUP_NOT_ACTIVE_TEXT;
			end

			popup.Text:SetText((text or ""));
			popup.Counter:SetText(profileOptionData.currentStacks .. " / " .. profileOptionData.desiredStacks);

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
			local itemCount = C_Item.GetItemCount(itemID) or 0;
			local text = L.POPUP_INSUFFICIENT_NEXT_REFRESH_TEXT:format(itemCount, profileOptionData.desiredStacks);
			popup.Text:SetText(text or "");
			popup.OkayButton:SetText(OKAY);

			if ElvUI and ElvUI[1] and popup.SetBackdropBorderColor then
				popup:SetBackdropBorderColor(1, 0, 0);
			end
		end
	end);
end

---@class ReminderPopupData
---@field active boolean Whether the option is considered active (false = inactive, true = active).
---@field optionData table Contains the option's data (e.g. itemID, loc, profile, etc.).
---@field itemCount number Number of matching items in the player's inventory when the popup is created.
---@field profileOptionData table Profile-related data for the option (e.g. enabled state, currentInstanceID, etc.).
---@field reason number Why the popup was triggered. (0 - add/update, 1 = removal, 2 = pre-expire, 3 = toggle)
---@field requiredStacks number Number of item stacks required for the reminder to be satisfied.

---HandleReminderPopup Handles whether a popup with reminder and item interaction options should be displayed or not.
---@param data ReminderPopupData Table containing all necessary information about the option and profile.
---@param templateTypeID? number What kind of template to create (0 = reminder, 1 = missing); defaults to 0.
function SIPPYCUP.Popups.HandleReminderPopup(data, templateTypeID)
	if not SIPPYCUP or not SIPPYCUP.db or not SIPPYCUP.db.global then
		return;
	end

	data.isFlying = false;
	local loc = data.optionData.loc;
	templateTypeID = templateTypeID or 0;  -- default to 0 if nil
	local templateType = (templateTypeID == 1) and "SIPPYCUP_MissingPopupTemplate" or "SIPPYCUP_RefreshPopupTemplate";
	local popup = activePopupByLoc[loc];
	local popupInstance = popup and popup:IsShown();

	-- If missing popup is still shown, we remove that first before showing new ones.
	if popup and popup.templateType == "SIPPYCUP_MissingPopupTemplate" then
		if popupInstance then
			popup:Hide();
		end

		SIPPYCUP.Popups.HandleReminderPopup(data, 0);
		return;
	end

	if templateTypeID == 0 then
		-- Popup request for addition or toggle, but we already have enough (or too many) required stacks?
		if (data.reason == SIPPYCUP.Popups.Reason.ADDITION or data.reason == SIPPYCUP.Popups.Reason.TOGGLE) and data.requiredStacks <= 0 then
			-- If a popup is currently shown, we bail out.
			if popupInstance then
				popup:Hide();
			end

			-- If user wants a missing reminder, we'll do that now (unless it's a toy as that has no item counts).
			if data.itemCount < data.profileOptionData.desiredStacks and SIPPYCUP.global.InsufficientReminder and data.optionData.type ~= SIPPYCUP.Options.Type.TOY then
				SIPPYCUP.Popups.HandleReminderPopup(data, 1);
			end
			return;
		end
	end

	if not popupInstance then
		popup = GetPopup(templateType);
		-- Nil when the queue is full (5 popups shown).
		if not popup then
			popupQueue[#popupQueue + 1] = data;
			return;
		end
	end

	-- Common data setup for both existing and new popups
	popup.popupData = data;

	-- Position the popup only if it's a new instance being added to the active list
	-- or if it was previously hidden and is now being re-shown.
	if not popupInstance then
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

	local shouldPlayAlert = false;
	if not popupInstance then
		activePopups[#activePopups + 1] = popup; -- Add to active list only if it's a new instance
		activePopupByLoc[loc] = popup; -- Store in lookup for loc-based replacement
		shouldPlayAlert = true;
	elseif lastProfileAlert ~= SIPPYCUP.Database.GetCurrentProfileName() then
		-- If profile change happens, fire an alert as-is for popups (throttle will still hold them)
		shouldPlayAlert = true;
	elseif data.reason == SIPPYCUP.Popups.Reason.REMOVAL then
		-- Removal popups should always fire an alert, because they might come after pre-expiration
		shouldPlayAlert = true;
	end

	if shouldPlayAlert then
		HandleAlerts();
	end
end

---Toggle handles what should happen after a option is enabled or disabled in regards to popup logic.
---@param itemName string? The toggled option's name.
---@param auraID number? The aura ID of the option.
---@param enabled boolean Whether the option tracking is enabled or disabled.
---@return nil
function SIPPYCUP.Popups.Toggle(itemName, auraID, enabled)
	-- Grab the right option by name, and check if aura exists.
	local optionData;

	if itemName then
		optionData = SIPPYCUP.Options.ByName[itemName];
	elseif auraID then
		optionData = SIPPYCUP.Options.ByAuraID[auraID];
	end

	if not optionData then
		return;
	end

	local profileOptionData = SIPPYCUP.Profile[optionData.auraID];
	if not profileOptionData then
		return;
	end

	-- Update aura map incrementally for this option
	SIPPYCUP.Database.UpdateAuraMapForOption(profileOptionData, enabled);

	-- If the option is not enabled, kill all its associated popups and timers!
	if not enabled then
		RemoveDeferredActionsByLoc(optionData.loc);
		local existingPopup = SIPPYCUP.Popups.activeByLoc[optionData.loc];

		if existingPopup and existingPopup:IsShown() then
			existingPopup:Hide();
		end

		if profileOptionData.untrackableByAura then
			SIPPYCUP.Items.CancelItemTimer(nil, optionData.auraID);
		else
			SIPPYCUP.Auras.CancelPreExpirationTimer(nil, optionData.auraID);
		end

		return;
	end

	-- For the enabled case: we need to check auraInfo and possibly cooldown. We'll define continuation logic.
	local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(optionData.auraID);
	local active = false;
	local startTime = 0;
	local trackBySpell = false;
	local trackByItem = false;

	if optionData.type == SIPPYCUP.Options.Type.CONSUMABLE then
		trackBySpell = optionData.spellTrackable;
		trackByItem = optionData.itemTrackable;
	elseif optionData.type == SIPPYCUP.Options.Type.TOY then
		-- Always track by item if itemTrackable
		if optionData.itemTrackable then
			trackByItem = true;
		end

		if optionData.spellTrackable then
			if SIPPYCUP.global.UseToyCooldown then
				trackByItem = true;
			else
				trackBySpell = true;
			end
		end
	end

	-- If item can only be tracked by the item cooldown (worst)
	if trackByItem then
		SIPPYCUP_OUTPUT.Debug("Tracking through Item");
		startTime = C_Item.GetItemCooldown(optionData.itemID);
		if startTime and startTime > 0 then
			active = true;
		end
	-- If item can be tracked through the spell cooldown (fine).
	elseif trackBySpell then
		SIPPYCUP_OUTPUT.Debug("Tracking through Spell");
		local spellCooldownInfo = C_Spell.GetSpellCooldown(optionData.auraID);
		if canaccessvalue == nil or canaccessvalue(spellCooldownInfo) then
			startTime = spellCooldownInfo and spellCooldownInfo.startTime;
		end
		if startTime and startTime > 0 then
			active = true;
		end
	end

	local preExpireFired;
	if profileOptionData.untrackableByAura then
		preExpireFired = SIPPYCUP.Items.CheckNoAuraSingleOption(profileOptionData, optionData.auraID, nil, startTime);
	else
		preExpireFired = SIPPYCUP.Auras.CheckPreExpirationForSingleOption(profileOptionData);
	end

	-- Only queue popup if no pre-expiration has already fired
	if not preExpireFired then
		local data = {
			active = auraInfo and true or active,
			auraID = optionData.auraID,
			auraInfo = auraInfo,
			optionData = optionData,
			profileOptionData = profileOptionData,
			reason = SIPPYCUP.Popups.Reason.TOGGLE,
		};

		-- auraInfo may be truthy/table; active is boolean from cooldown check
		SIPPYCUP.Popups.QueuePopupAction(data, "Toggle");
	end
end

local DEBOUNCE_DELAY = 0.05;
local pendingCalls = {};

---@class PopupActionData
---@field active boolean Whether the option is considered active (false = inactive, true = active).
---@field auraID number The aura ID.
---@field auraInfo table? Aura information for the popup action.
---@field optionData table? option item data.
---@field profileOptionData table? Profile-specific option item data.
---@field reason number Reason for triggering the popup action. (0 - add/update, 1 = removal, 2 = pre-expire, 3 = toggle)

---QueuePopupAction queues up popup action calls, adding a debounce to avoid repeated calls (UNIT_AURA & COMBAT_LOG_EVENT_UNFILTERED).
---@param data PopupActionData Data bundle containing aura and option context for the popup action.
---@param caller string What function called the popup action.
---@return nil
function SIPPYCUP.Popups.QueuePopupAction(data,  caller)
	SIPPYCUP_OUTPUT.Debug("QueuePopupAction");
	-- If MSP status checks are on and the character is currently OOC, we skip everything.
	if SIPPYCUP.MSP.IsEnabled() and SIPPYCUP.global.MSPStatusCheck then
		local _, _, isIC = SIPPYCUP.MSP.CheckRPStatus();
		if not isIC then
			return;
		end
	end

	-- Use a composite key of auraID and reason so different reasons don't collide
	local key = tostring(data.auraID) .. "-" .. tostring(data.reason);
	local args = { data, caller };

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

		local d, c = unpack(entry.args);
		SIPPYCUP.Popups.HandlePopupAction(d, c);
	end)
end

---HandlePopupAction executes the popup action for a option aura.
---@param data PopupActionData Data bundle containing aura and option context for the popup action.
---@param caller string What function called the popup action.
---@return nil
function SIPPYCUP.Popups.HandlePopupAction(data, caller)
	SIPPYCUP_OUTPUT.Debug("HandlePopupAction");
	local optionData = data.optionData or SIPPYCUP.Options.ByAuraID[data.auraID];
	local profileOptionData = data.profileOptionData or SIPPYCUP.Profile[data.auraID];

	if not optionData or not profileOptionData or SIPPYCUP.Popups.IsIgnored(optionData.auraID) then
		return;
	end

	local reason = data.reason;
	local active = data.active;

	local auraID = data.auraID;
	local auraInfo = data.auraInfo;
	local currentInstanceID = profileOptionData.currentInstanceID;

	-- Removal of a spell/aura count generally is not due to an item's action, mark bag as synchronized.
	-- Pre-expiration also does not do any bag changes, so mark as synchronised in case.
	-- Delayed (e.g. eating x seconds) UNIT_AURA calls, mark bag as synchronized (as it was removed earlier).
	-- Toys UNIT_AURA calls, mark bag as synchronized (as no items are actually used).
	if reason == SIPPYCUP.Popups.Reason.REMOVAL or reason == SIPPYCUP.Popups.Reason.PRE_EXPIRATION or optionData.delayedAura or optionData.type == SIPPYCUP.Options.Type.TOY then
		SIPPYCUP.Items.HandleBagUpdate();
	end

	-- We defer popups in three situations:
	-- > Bag data is desynch'd from UNIT_AURA.
	-- > We're in combat (experimental).
	-- > We're in a loading screen.
	-- This should be handled before any other logic, as there's no point to calculate deferred logic.
	if SIPPYCUP.Items.bagUpdateUnhandled or InCombatLockdown() or SIPPYCUP.InLoadingScreen then
		local blockedBy;
		if SIPPYCUP.Items.bagUpdateUnhandled then
			blockedBy = "bag";
		elseif InCombatLockdown() then
			blockedBy = "combat"; -- Won't ever happen anymore as UNIT_AURA does not run in combat, legacy code.
		elseif SIPPYCUP.States.loadingScreen then
			blockedBy = "loading";
		end

		local deferredData = {
			active = active,
			auraID = auraID,
			auraInfo = auraInfo,
			optionData = optionData,
			profileOptionData = profileOptionData,
			reason = reason,
		};

		deferredActions[#deferredActions + 1] = {
			data = deferredData,
			caller = caller,
			blockedBy = blockedBy,
		};
		return;
	end
	-- At this point, we're certain that we're safe to execute further!

	-- Recover auraInfo if possible (perhaps triggered through combat or other means)
	local auraInfoAccessible = canaccessvalue == nil or (auraInfo and canaccessvalue(auraInfo));

	if auraInfo == nil or not auraInfoAccessible then
		if currentInstanceID then
			auraInfo = C_UnitAuras.GetAuraDataByAuraInstanceID("player", currentInstanceID);

			if not auraInfo then
				SIPPYCUP.Database.instanceToProfile[currentInstanceID] = nil;
				profileOptionData.currentInstanceID = nil;
			end
		else
			auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(auraID);

			if auraInfo then
				print("auraInfo found!");
				local auraInstanceID = auraInfo.auraInstanceID;
				SIPPYCUP.Database.instanceToProfile[auraInstanceID] = profileOptionData;
				profileOptionData.currentInstanceID = auraInstanceID;
			end
		end
	end

	if auraInfo then
		-- Do not change reason if pre-expiration
		if reason ~= SIPPYCUP.Popups.Reason.PRE_EXPIRATION then
			reason = SIPPYCUP.Popups.Reason.TOGGLE;
		end
		active = true;
	end

	local auraInstanceID = auraInfo and auraInfo.auraInstanceID;

	local trackBySpell = false;
	local trackByItem = false;

	if optionData.type == SIPPYCUP.Options.Type.CONSUMABLE then
		trackBySpell = optionData.spellTrackable;
		trackByItem = optionData.itemTrackable;
	elseif optionData.type == SIPPYCUP.Options.Type.TOY then
		-- Always track by item if itemTrackable
		if optionData.itemTrackable then
			trackByItem = true;
		end

		if optionData.spellTrackable then
			if SIPPYCUP.global.UseToyCooldown then
				trackByItem = true;
			else
				trackBySpell = true;
			end
		end
	end

	-- Extra check because toys have longer cooldowns than option tend to, so don't fire if cd is still up.
	if optionData.type == SIPPYCUP.Options.Type.TOY and reason == SIPPYCUP.Popups.Reason.REMOVAL then
		local cooldownActive = false;

		-- If item can only be tracked by the item cooldown (worst)
		if trackByItem then
			SIPPYCUP_OUTPUT.Debug("Tracking through Item");
			local startTime = C_Item.GetItemCooldown(optionData.itemID);
			if startTime and startTime > 0 then
				cooldownActive = true;
			end
		-- If item can be tracked through the spell cooldown (fine).
		elseif trackBySpell then
			SIPPYCUP_OUTPUT.Debug("Tracking through Spell");
			local spellCooldownInfo = C_Spell.GetSpellCooldown(optionData.auraID);
			local startTime;
			if canaccessvalue == nil or canaccessvalue(spellCooldownInfo) then
				startTime = spellCooldownInfo and spellCooldownInfo.startTime;
			end
			if startTime and startTime > 0 then
				cooldownActive = true;
			end
		end

		-- Cooldown is active when removal happened? We don't show anything.
		if cooldownActive then
			return;
		end
	end

	SIPPYCUP_OUTPUT.Debug({ caller = caller, auraID = optionData.auraID, itemID = optionData.itemID, name = optionData.name });

	-- First, let's grab the latest currentInstanceID (or have it be nil if none which is fine).
	profileOptionData.currentInstanceID = (auraInfo and auraInfo.auraInstanceID) or auraInstanceID;

	-- If the option does not support stacks, we always desire just 1.
	profileOptionData.desiredStacks = optionData.stacks and profileOptionData.desiredStacks or 1;

	local itemCount;
	if optionData.type == SIPPYCUP.Options.Type.CONSUMABLE then
		profileOptionData.currentStacks = SIPPYCUP.Auras.CalculateCurrentStacks(auraInfo, auraID, reason, active);
		itemCount = C_Item.GetItemCount(optionData.itemID);
	elseif optionData.type == SIPPYCUP.Options.Type.TOY then
		if auraInfo then
			profileOptionData.currentStacks = SIPPYCUP.Auras.CalculateCurrentStacks(auraInfo, auraID, reason, active);
		else
			profileOptionData.currentStacks = active and 1 or 0;
		end
		itemCount = PlayerHasToy(optionData.itemID) and 1 or 0;
	end

	local requiredStacks = profileOptionData.desiredStacks - profileOptionData.currentStacks;

	SIPPYCUP.Popups.HandleReminderPopup({
		optionData = optionData,
		profileOptionData = profileOptionData,
		requiredStacks = requiredStacks,
		reason = reason,
		itemCount = itemCount,
		active = active,
	});
end

--- HideAllRefreshPopups cleans up all visible and queued popups.
---@param reason number? Optional reason for hiding popups. (0 - add/update, 1 = removal, 2 = pre-expire, 3 = toggle)
function SIPPYCUP.Popups.HideAllRefreshPopups(reason)
	if not reason then
		-- Clear the popup queue entirely
		wipe(popupQueue);
	else
		for i = #popupQueue, 1, -1 do
			local popup = popupQueue[i];

			if popup.popupData.reason == reason then
				table.remove(popupQueue, i);
			end
		end
	end

	-- Hide and remove all active popups
	for i = #activePopups, 1, -1 do
		local popup = activePopups[i];

		if not reason or popup.popupData.reason == reason then
			popup:Hide(); -- Cleans up activePopupByLoc and other stuff.
		end
	end
end

---DeferAllRefreshPopups defers all active and queued popups to be processed later.
-- Typically called when popups cannot be shown due to bags, combat, or loading screen.
---@param reason number Why a deferred action is being handled (0 - bag, 1 - combat, 2 - loading)
---@return nil
function SIPPYCUP.Popups.DeferAllRefreshPopups(reasonKey)
	local blockedBy;
	if reasonKey == 0 or SIPPYCUP.Items.bagUpdateUnhandled then
		blockedBy = "bag";
	elseif reasonKey == 1 or InCombatLockdown() then
		blockedBy = "combat"; -- Only way combat is ever used, by deferring before combat.
	elseif reasonKey == 2 or SIPPYCUP.States.loadingScreen then
		blockedBy = "loading";
	end

	local function MakeDeferredData(popup)
		local d = popup.popupData;
		return {
			active = d.active,
			auraID = d.optionData.auraID,
			auraInfo = nil, -- Cannot query at this point (e.g. combat lockdown)
			optionData = d.optionData,
			profileOptionData = d.profileOptionData,
			reason = d.reason,
		};
	end

	-- Defer queued popups
	for i = #popupQueue, 1, -1 do
		local popup = popupQueue[i];
		deferredActions[#deferredActions + 1] = {
			data = MakeDeferredData(popup),
			caller = "DeferAllRefreshPopups - popupQueue",
			blockedBy = blockedBy,
		};
		table.remove(popupQueue, i);
	end

	-- Defer and hide active popups
	for i = #activePopups, 1, -1 do
		local popup = activePopups[i];
		-- Preserves order of active popups
		table.insert(deferredActions, 1, {
			data = MakeDeferredData(popup),
			caller = "DeferAllRefreshPopups - activePopups",
			blockedBy = blockedBy,
		});
		popup:Hide(); -- Also removes from activePopups and activePopupByLoc
	end
end

---HandleDeferredActions Processes and flushes all queued popup actions.
-- Called after bag data is synced (BAG_UPDATE_DELAYED) to ensure accurate context.
---@param reason number Why a deferred action is being handled (0 - bag, 1 - combat, 2 - loading)
function SIPPYCUP.Popups.HandleDeferredActions(reasonKey)
	if not deferredActions or #deferredActions == 0 then
		return;
	end

	local i = 1;
	while i <= #deferredActions do
		local action = deferredActions[i];
		if action.blockedBy == reasonKey then
			SIPPYCUP.Popups.QueuePopupAction(
				action.data,
				action.caller
			);
			tremove(deferredActions, i); -- remove handled item, don't increment
		else
			i = i + 1; -- skip non-matching item
		end
	end
end
