-- Copyright The Sippy Cup Authors
-- Inspired by Eavesdropper
-- SPDX-License-Identifier: Apache-2.0

---@type SippyCupSettingsElements
local SettingsElements = SC.SettingsElements;

---@class SippyCupSettings
local Settings = {};

---@type table
local SharedMedia = LibStub("LibSharedMedia-3.0");

local L = SC.Localization;

SippyCup_SettingsMixin = {};

local lastSelectedTab;

local defaultSounds = {
	{ key = "aggro_enter_warning_state", fid = 567401 },
	{ key = "belltollhorde", fid = 565853 },
	{ key = "belltolltribal", fid = 566027 },
	{ key = "belltollnightelf", fid = 566558 },
	{ key = "belltollalliance", fid = 566564 },
	{ key = "fx_darkmoonfaire_bell", fid = 1100031 },
	{ key = "fx_ship_bell_chime_01", fid = 1129273 },
	{ key = "fx_ship_bell_chime_02", fid = 1129274 },
	{ key = "fx_ship_bell_chime_03", fid = 1129275 },
	{ key = "raidwarning", fid = 567397 },
};

-- Register default sounds
for _, sound in ipairs(defaultSounds) do
	SharedMedia:Register("sound", sound.key, sound.fid)
end

-- Build soundList with keys = values for quick lookup/use
local soundList = {};
for _, soundName in ipairs(SharedMedia:List("sound")) do
	soundList[soundName] = soundName;
end

-- Utility to get the first valid itemID from number or table
local function GetFirstItemID(itemID)
	if type(itemID) == "table" then
		for _, id in ipairs(itemID) do
			if id and id > 0 then
				return id;
			end
		end
		return nil;
	else
		return itemID;
	end
end

-- Example: toy checkbox disabled function
local function IsToyDisabled(toyID)
	local firstID = GetFirstItemID(toyID);
	return not firstID or not PlayerHasToy(firstID);
end

---AddTab creates a new tab button under the given parent frame and adds it to the parent's Tabs list.
---It positions the new tab relative to existing tabs, sets up its scripts for show and click events, and registers it for ElvUI skinning.
---@param parent table Frame containing the Tabs table and the SetTab function.
---@return table tab The created tab button frame.
function SippyCup_SettingsMixin:AddTab()
	local tabs = self.Tabs;
	local tab = CreateFrame("Button", nil, self, "SippyCup_SettingsMenuTabTopTemplate");

	if tIndexOf(tabs, tab) == nil then
		table.insert(tabs, tab);
	end

	local tabCount = #tabs;
	if tabCount > 1 then
		tab:SetPoint("TOPLEFT", tabs[tabCount - 1], "TOPRIGHT", 5, 0);
	else
		tab:SetPoint("TOPLEFT", 10, -20);
	end

	local tabIndex = tabCount;

	local function OnShow(tabButton)
		PanelTemplates_TabResize(tabButton, 15, nil, 65);
		PanelTemplates_DeselectTab(tabButton);
	end

	local function OnClick()
		self:SetTab(tabIndex);
	end

	tab:SetScript("OnShow", OnShow);
	tab:SetScript("OnClick", OnClick);

	SC.ElvUI.RegisterSkinnableElement(tab, "toptapbutton");

	return tab;
end

---GetWrapperFrame creates a content frame within the parent frame.
---@param parent table The parent frame to contain the wrapper. Must have a `Views` table.
---@return table contentFrame The content frame.
function SippyCup_SettingsMixin:AddFrame()
	local frame = CreateFrame("Frame", nil, self);
	frame:SetPoint("TOP", 0, -65);
	frame:SetPoint("LEFT");
	frame:SetPoint("RIGHT");
	frame:SetPoint("BOTTOM");

	frame.isScrollable = false;
	frame.scrollFrame = nil;

	self.Views[#self.Views + 1] = frame;

	return frame;
end

---Creates a scrollable panel for a settings tab
---@param parent table The parent frame to contain the scrollable wrapper. Must have a Views table.
---@return table The scrollable content frame, with a reference to its scrollFrame and isScrollable flag.
function SippyCup_SettingsMixin:AddScrollableFrame()
	local frame = CreateFrame("Frame", nil, self);
	frame:SetPoint("TOP", 0, -65);
	frame:SetPoint("LEFT");
	frame:SetPoint("RIGHT");
	frame:SetPoint("BOTTOM");

	local paddingLeft, paddingRight, paddingTop, paddingBottom = 0, 25, 0, 16;

	local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "ScrollFrameTemplate");
	scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", paddingLeft, -paddingTop);
	scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -paddingRight, paddingBottom);

	-- Extend mouse interaction into the scrollbar area
	scrollFrame:SetHitRectInsets(0, -paddingRight, 0, 0);

	-- Scroll child holds all content
	local scrollChild = CreateFrame("Frame", nil, scrollFrame);
	scrollChild:SetPoint("TOPLEFT");
	scrollFrame:SetScrollChild(scrollChild);

	scrollFrame:HookScript("OnSizeChanged", function(_, width, height)
		scrollChild:SetWidth(width);
		scrollChild:SetHeight(height);
	end);

	frame.isScrollable = true;
	frame.scrollFrame = scrollFrame;
	frame.scrollChild = scrollChild;

	self.Views[#self.Views + 1] = frame;
	SC.ElvUI.RegisterSkinnableElement(scrollFrame.ScrollBar, "scrollbar");

	return frame, scrollChild;
end

---SetTab shows the selected configuration tab and hides others.
---@param index number The index of the tab to activate.
function SippyCup_SettingsMixin:SetTab(index)
	for i, panel in ipairs(self.Views) do
		local isSelected = (i == index);
		panel:SetShown(isSelected);

		local scroll = panel.scrollFrame;
		if scroll then
			scroll:SetShown(isSelected);
			if scroll.ScrollBar then
				scroll.ScrollBar:SetShown(isSelected);
			end
		end
	end

	PanelTemplates_SetTab(self, index);
	self.selectedTab = index;
	lastSelectedTab = index;
end

---SwitchProfileValues updates all profile-bound widgets with current values.
---Ensures each widget reflects its getter's value and applies corresponding set or disabled logic.
function SippyCup_SettingsMixin:SwitchProfileValues()
	if not self.profileWidgets then return; end

	local grayR, grayG, grayB = GRAY_FONT_COLOR:GetRGB();
	local whiteR, whiteG, whiteB = WHITE_FONT_COLOR:GetRGB();

	for _, widgetList in ipairs(self.profileWidgets) do
		for _, widget in ipairs(widgetList) do
			local data = widget.data;
			if data and type(data.get) == "function" then
				local value = data.get();

				if widget.SetChecked and widget.GetChecked then
					local oldVal = widget:GetChecked();
					if oldVal ~= value then
						widget:SetChecked(value);
					end
				elseif widget.SetValue and widget.GetValue then
					local oldVal = widget:GetValue();
					if oldVal ~= value then
						widget:SetValue(value);
						if widget.Text then
							widget.Text:SetText(string.format("%s: %d", data.label or "", math.floor(value + 0.5)));
						end
					end
					if type(data.disabled) == "function" then
						local isDisabled = data.disabled();
						widget:SetEnabled(not isDisabled);
						local r, g, b = isDisabled and grayR or whiteR, isDisabled and grayG or whiteG, isDisabled and grayB or whiteB;
						if widget.RightText then
							widget.RightText:SetVertexColor(r, g, b);
						end
						if widget.MinText then
							widget.MinText:SetVertexColor(r, g, b);
						end
						if widget.MaxText then
							widget.MaxText:SetVertexColor(r, g, b);
						end
					end
				end
			end
		end
	end
end

---RefreshWidgets re-evaluates and updates all widgets' values and states.
---Ensures dynamic content, enabled/disabled states, and labels are current across all widget types.
function SippyCup_SettingsMixin:RefreshWidgets()
	if not self.allWidgets then return; end

	local grayR, grayG, grayB = GRAY_FONT_COLOR:GetRGB();
	local whiteR, whiteG, whiteB = WHITE_FONT_COLOR:GetRGB();

	for _, widgetList in ipairs(self.allWidgets) do
		for _, widget in ipairs(widgetList) do
			local data = widget.data;
			if data then
				local dtype = data.type;

				if type(data.disabled) == "function" then
					local isDisabled = data.disabled();
					if widget.SetEnabled then
						widget:SetEnabled(not isDisabled);
					elseif isDisabled and widget.Disable then
						widget:Disable();
					elseif not isDisabled and widget.Enable then
						widget:Enable();
					end

					-- Apply grayed text color for sliders (or others) if applicable
					local r, g, b = whiteR, whiteG, whiteB;
					if isDisabled then
						r, g, b = grayR, grayG, grayB;
					end
					if widget.RightText then
						widget.RightText:SetVertexColor(r, g, b);
					end
					if widget.MinText then
						widget.MinText:SetVertexColor(r, g, b);
					end
					if widget.MaxText then
						widget.MaxText:SetVertexColor(r, g, b);
					end
				end

				if dtype == "checkbox" then
					if type(data.get) == "function" then
						widget:SetChecked(data.get());
					end

				elseif dtype == "description" then
					local text = type(data.name) == "function" and data.name() or data.name;
					widget:SetText(text or "");

				elseif dtype == "dropdown" then
					if widget.Text and type(data.get) == "function" then
						local currentValue = data.get();
						local values = type(data.values) == "function" and data.values() or data.values;
						local label;

						if data.style == "button" then
							label = type(data.label) == "function" and data.label() or data.label;
						else
							if type(values) == "table" then
								label = values[currentValue];
							end
							if not label then
								label = type(data.label) == "function" and data.label() or data.label;
							end
						end

						widget.Text:SetText(label or "");
					end
				end
			end
		end
	end
end

local categories = { "Appearance", "Effect", "Handheld", "Placement", "Prism", "Size" };

-- Sort `categories` in-place by their localized title:
table.sort(categories, function(a, b)
	local locA = L["OPTIONS_TAB_" .. string.upper(a) .. "_TITLE"] or "";
	local locB = L["OPTIONS_TAB_" .. string.upper(b) .. "_TITLE"] or "";

	-- Normalize and lowercase for case-insensitive comparison
	return SC.Utils.Normalize(locA:lower()) < SC.Utils.Normalize(locB:lower());
end);

---OnLoad initializes the config menu frame, creating tabs, panels, and all widget content.
function SippyCup_SettingsMixin:OnLoad()
	ButtonFrameTemplate_HidePortrait(self);
	ButtonFrameTemplate_HideButtonBar(self);
	tinsert(UISpecialFrames, self:GetName());

	self.Inset:Hide();

	self:SetTitle(SC.Globals.addon_title .. " " .. MAIN_MENU);

	self.Tabs = {};
	self.TabsByName = {};
	self.PanelsByName = {};
	self.Views = {};
	self.lowestFrames = {};
	self.optionFrames = {};

	self:RegisterForDrag("LeftButton");

	self.CloseButton:SetScript("OnClick", function()
		self:Hide();
	end)

	-- Create tabs and their panels
	local generalTab = self:AddTab();
	generalTab:SetText(L.OPTIONS_GENERAL_HEADER);
	self.TabsByName["GENERAL"] = generalTab;
	local generalPanel = self:AddFrame();

	for _, category in ipairs(categories) do
		local localized = L["OPTIONS_TAB_" .. string.upper(category) .. "_TITLE"] or category;

		local categoryTab = self:AddTab();
		categoryTab:SetText(localized);
		self.TabsByName[string.upper(category)] = categoryTab;

		local categoryPanel, categoryContent = self:AddScrollableFrame(); -- luacheck: no unused (categoryPanel)
		self.PanelsByName[string.upper(category)] = categoryContent;
	end

	local profilesTab = self:AddTab();
	profilesTab:SetText(L.OPTIONS_PROFILES_HEADER);
	self.TabsByName["PROFILES"] = profilesTab;
	local profilesPanel = self:AddFrame();

	PanelTemplates_SetNumTabs(self, #self.Tabs);

	local totalWidth = 0;
	for _, tab in ipairs(self.Tabs) do
		PanelTemplates_TabResize(tab, 15, nil, 65);
		PanelTemplates_DeselectTab(tab);
		totalWidth = totalWidth + tab:GetWidth() + 5; -- 5px spacing between tabs
	end
	self:SetWidth(totalWidth + 0); -- padding

	-- Test content for General tab
	SettingsElements.CreateTitleWithDescription(generalPanel, L.OPTIONS_GENERAL_HEADER, SC.Globals.addon_notes);

	local generalCheckboxData = {
		{
			type = "checkbox",
			label = L.OPTIONS_GENERAL_WELCOME_NAME,
			tooltip = L.OPTIONS_GENERAL_WELCOME_DESC,
			get = function()
				return SC.Database:GetGlobalSetting("WelcomeMessage");
			end,
			set = function(val)
				SC.Database:SetGlobalSetting("WelcomeMessage", val);
			end,
		},
		{
			type = "dropdown",
			label = L.OPTIONS_GENERAL_MINIMAP_NAME,
			tooltip = L.OPTIONS_GENERAL_MINIMAP_DESC,
			style = "checkbox",
			values = {
				["MINIMAPBUTTON"] = {
					L.OPTIONS_GENERAL_MINIMAPBUTTON_NAME,
					L.OPTIONS_GENERAL_MINIMAPBUTTON_DESC,
					function()
						return not SC.Database:GetGlobalSetting("MinimapButton").Hide;
					end,
					function(val)
						-- Update with inversion: save 'Hide' as NOT val
						local minimapSettings = SC.Database:GetGlobalSetting("MinimapButton");
						minimapSettings.Hide = not val;
						SC.Database:SetGlobalSetting("MinimapButton", minimapSettings);
						SC.Minimap:UpdateMinimapButtons();
					end,
				},
				["ADDONCOMPARTMENT"] = {
					L.OPTIONS_GENERAL_ADDONCOMPARTMENT_NAME,
					L.OPTIONS_GENERAL_ADDONCOMPARTMENT_DESC,
					function()
						return SC.Database:GetGlobalSetting("MinimapButton").ShowAddonCompartmentButton;
					end,
					function(val)
						local minimapSettings = SC.Database:GetGlobalSetting("MinimapButton");
						minimapSettings.ShowAddonCompartmentButton = val;
						SC.Database:SetGlobalSetting("MinimapButton", minimapSettings);
						SC.Minimap:UpdateMinimapButtons();
					end,
				},
			},
			sorting = {
				"MINIMAPBUTTON",
				"ADDONCOMPARTMENT",
			},
			get = function() end,
			set = function() end,
		},
		{
			type = "checkbox",
			label = L.OPTIONS_GENERAL_NEW_FEATURE_NOTIFICATION_NAME,
			tooltip = L.OPTIONS_GENERAL_NEW_FEATURE_NOTIFICATION_DESC,
			notificationToggle = true,
			get = function()
				return SC.Database:GetGlobalSetting("NewFeatureNotification");
			end,
			set = function(val)
				SC.Popups.CreateReloadPopup(
					function() -- ACCEPT
						SC.Database:SetGlobalSetting("NewFeatureNotification", val);
						ReloadUI();
					end
				);
			end,
		},
	};

	-- Initialize an empty table to hold all checkbox lists
	self.allWidgets = self.allWidgets or {};
	self.profileWidgets = self.profileWidgets or {};

	self.allWidgets[#self.allWidgets + 1] = SettingsElements.CreateWidgetRowContainer(generalPanel, generalCheckboxData);

	SettingsElements.CreateCategoryHeader(generalPanel, L.OPTIONS_GENERAL_POPUPS_HEADER);

	local reminderCheckboxData = {
		{
			type = "checkbox",
			label = L.OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE,
			tooltip = L.OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE_DESC,
			get = function()
				return SC.Database:GetGlobalSetting("PreExpirationChecks");
			end,
			set = function(val)
				SC.Database:SetGlobalSetting("PreExpirationChecks", val);
				if val then
					SC.Options.RefreshStackSizes(SC.MSP.IsEnabled() and SC.Database:GetGlobalSetting("MSPStatusCheck"), false, true);
				else
					local reason = SC.Popups.Reason.PRE_EXPIRATION;
					SC.Auras.CancelAllPreExpirationTimers();
					SC.Items.CancelAllItemTimers(reason);
					SC.Popups.HideAllRefreshPopups(reason);
				end
			end,
		},
		{
			type = "slider",
			label = L.OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_LEAD_TIMER,
			tooltip = L.OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_LEAD_TIMER_TEXT,
			buildAdded = "0.6.0|120000",
			min = 1,
			max = 5,
			step = 1,
			disabled = function()
				return not SC.Database:GetGlobalSetting("PreExpirationChecks");
			end,
			get = function()
				return SC.Database:GetGlobalSetting("PreExpirationLeadTimer");
			end,
			set = function(val)
				SC.Database:SetGlobalSetting("PreExpirationLeadTimer", val);
				local reason = SC.Popups.Reason.PRE_EXPIRATION;
				SC.Auras.CancelAllPreExpirationTimers();
				SC.Items.CancelAllItemTimers(reason);
				SC.Popups.HideAllRefreshPopups(reason);
				SC.Options.RefreshStackSizes(SC.MSP.IsEnabled() and SC.Database:GetGlobalSetting("MSPStatusCheck"), false, true);
			end,
		},
		{
			type = "checkbox",
			label = L.OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE,
			tooltip = L.OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE_DESC,
			get = function()
				return SC.Database:GetGlobalSetting("InsufficientReminder");
			end,
			set = function(val)
				SC.Database:SetGlobalSetting("InsufficientReminder", val);
			end,
		},
		{
			type = "checkbox",
			label = L.OPTIONS_GENERAL_POPUPS_TRACK_TOY_ITEM_CD_ENABLE,
			tooltip = L.OPTIONS_GENERAL_POPUPS_TRACK_TOY_ITEM_CD_ENABLE_DESC,
			buildAdded = "0.6.0|120000",
			get = function()
				return SC.Database:GetGlobalSetting("UseToyCooldown");
			end,
			set = function(val)
				SC.Database:SetGlobalSetting("UseToyCooldown", val);
			end,
		},
		{
			type = "button",
			label = L.OPTIONS_GENERAL_POPUPS_IGNORES,
			tooltip = L.OPTIONS_GENERAL_POPUPS_IGNORES_TEXT,
			disabled = function()
				return SC.Popups.IsEmpty();
			end,
			func = function()
				SC.Popups.ResetIgnored();
			end,
		},
	};

	self.allWidgets[#self.allWidgets + 1] = SettingsElements.CreateWidgetRowContainer(generalPanel, reminderCheckboxData);

	local positionWidgetData = {
		{
			type = "dropdown",
			label = L.OPTIONS_GENERAL_POPUPS_POSITION_NAME,
			tooltip = L.OPTIONS_GENERAL_POPUPS_POSITION_DESC,
			values = {
				["TOP"] = L.OPTIONS_GENERAL_POPUPS_POSITION_TOP,
				["CENTER"] = L.OPTIONS_GENERAL_POPUPS_POSITION_CENTER,
				["BOTTOM"] = L.OPTIONS_GENERAL_POPUPS_POSITION_BOTTOM,
			},
			sorting = {
				"TOP",
				"CENTER",
				"BOTTOM",
			},
			get = function()
				return SC.Database:GetGlobalSetting("PopupPosition");
			end,
			set = function(val)
				SC.Database:SetGlobalSetting("PopupPosition", val);
			end,
		},
	};

	self.allWidgets[#self.allWidgets + 1] = SettingsElements.CreateWidgetRowContainer(generalPanel, positionWidgetData);

	local alertWidgetData = {
		{
			type = "checkbox",
			label = BINDING_NAME_TOGGLESOUND,
			tooltip = L.OPTIONS_GENERAL_POPUPS_SOUND_ENABLE_DESC,
			get = function()
				return SC.Database:GetGlobalSetting("AlertSound");
			end,
			set = function(val)
				SC.Database:SetGlobalSetting("AlertSound", val);
			end,
		},
		{
			type = "dropdown",
			label = SOUND,
			tooltip = L.OPTIONS_GENERAL_POPUPS_ALERT_SOUND_DESC,
			align = "right",
			values = soundList,
			disabled = function()
				return not SC.Database:GetGlobalSetting("AlertSound");
			end,
			get = function()
				return SC.Database:GetGlobalSetting("AlertSoundID");
			end,
			set = function(val)
				local soundPath = SharedMedia:Fetch("sound", val);
				if soundPath then
					PlaySoundFile(soundPath, "Master");
					SC.Database:SetGlobalSetting("AlertSoundID", val);
				end
			end,
		},
		{
			type = "checkbox",
			label = L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE,
			tooltip = L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE_DESC,
			get = function()
				return SC.Database:GetGlobalSetting("FlashTaskbar");
			end,
			set = function(val)
				SC.Database:SetGlobalSetting("FlashTaskbar", val);
			end,
		},
	};

	self.allWidgets[#self.allWidgets + 1] = SettingsElements.CreateWidgetRowContainer(generalPanel, alertWidgetData);

	SettingsElements.CreateCategoryHeader(generalPanel, L.OPTIONS_GENERAL_ADDONINTEGRATIONS_HEADER);

	local integrationsWidgetData = {
		{
			type = "checkbox",
			label = L.OPTIONS_GENERAL_MSP_STATUSCHECK_ENABLE,
			tooltip = L.OPTIONS_GENERAL_MSP_STATUSCHECK_DESC,
			disabled = function()
				return not SC.MSP.IsEnabled();
			end,
			get = function()
				return SC.Database:GetGlobalSetting("MSPStatusCheck");
			end,
			set = function(val)
				SC.Database:SetGlobalSetting("MSPStatusCheck", val);
				SC.MSP.CheckRPStatus();
				if val then
					SC.Options.RefreshStackSizes(val);
				else
					SC.Popups.HideAllRefreshPopups();
				end
			end,
		},
	};

	self.allWidgets[#self.allWidgets + 1] = SettingsElements.CreateWidgetRowContainer(generalPanel, integrationsWidgetData);

	local insetData = {
		{
			type = "logo",
		},
		{
			type = "title",
			text = SC.Globals.addon_title,
		},
		{
			type = "version",
			text = SC.Globals.addon_version,
		},
		{
			type = "build",
			text = L.OPTIONS_GENERAL_ADDONINFO_BUILD:format(SC.Utils.GetBuildString(true)),
			tooltip = function()
				if SC.Utils.ValidateLatestBuild() then
					return L.OPTIONS_GENERAL_ADDONINFO_BUILD_CURRENT;
				else
					return L.OPTIONS_GENERAL_ADDONINFO_BUILD_OUTDATED;
				end
			end,
		},
		{
			type = "author",
			text = SC.Globals.author,
		},
		{
			type = "bsky",
			text = "Bluesky",
			tooltip = L.OPTIONS_GENERAL_BLUESKY_SHILL_DESC,
		},
	};

	self.allWidgets[#self.allWidgets + 1] = SettingsElements.CreateInset(generalPanel, insetData);

	for _, category in ipairs(categories) do
		local categoryName = string.upper(category);
		local categoryPanel = self.PanelsByName[categoryName];

		local title = L["OPTIONS_TAB_" .. categoryName .. "_TITLE"] or categoryName;
		local instruction = L["OPTIONS_TAB_" .. categoryName .. "_INSTRUCTION"] or "";
		SettingsElements.CreateTitleWithDescription(categoryPanel, title, instruction, true);

		local categoryConsumablesData = {};

		for _, optionData in ipairs(SC.Options.Data) do
			if optionData.category == categoryName and optionData.type == SC.Options.Type.CONSUMABLE then
				local consumableAura = optionData.auraID;
				local consumableName = optionData.name;
				local consumableID = optionData.itemID;
				local consumableIcon = optionData.icon;
				local consumableType = optionData.type;

				local checkboxProfileKey = consumableAura;

				categoryConsumablesData[#categoryConsumablesData + 1] = {
					dataType = consumableType,
					type = "checkbox",
					label = consumableName,
					icon = consumableIcon,
					style = "option",
					itemID = consumableID,
					preExpiration = optionData.preExpiration,
					unrefreshable = optionData.unrefreshable,
					nonAura = optionData.itemTrackable or optionData.spellTrackable,
					cooldownMismatch = optionData.cooldownMismatch,
					stacks = optionData.stacks,
					buildAdded = optionData.buildAdded,
					get = function()
						return SC.Database:GetProfileSetting(checkboxProfileKey, "enable");
					end,
					set = function(val)
						SC.Database:SetProfileSetting(checkboxProfileKey, "enable", val);
						SC.Popups.Toggle(consumableName, consumableAura, val);
					end,
				};

				-- Slider: Desired stacks (if applicable)
				if optionData.stacks then
					local sliderProfileKey = consumableAura;

					categoryConsumablesData[#categoryConsumablesData + 1] = {
						dataType = consumableType,
						type = "slider",
						label = L.OPTIONS_DESIRED_STACKS,
						tooltip = L.OPTIONS_SLIDER_TEXT and L.OPTIONS_SLIDER_TEXT:format(consumableName) or nil,
						min = 1,
						max = optionData.maxStacks,
						step = 1,
						disabled = function()
							return not SC.Database:GetProfileSetting(sliderProfileKey, "enable");
						end,
						get = function()
							return SC.Database:GetProfileSetting(sliderProfileKey, "desiredStacks");
						end,
						set = function(val)
							SC.Database:SetProfileSetting(sliderProfileKey, "desiredStacks", val);
							local profileOptionData = SC.Database:GetOption(sliderProfileKey);
							if profileOptionData.enable then
								SC.Popups.Toggle(consumableName, consumableAura, true);
							end
						end
					};
				end
			end
		end

		if categoryName == "PRISM" then
			SettingsElements.CreateCategoryHeader(categoryPanel, SETTINGS);

			local prismWidgetData = {
				{
					type = "slider",
					label = L.OPTIONS_TAB_PRISM_TIMER:format(SC.Options.ByItemID[193031].name),
					tooltip = L.OPTIONS_TAB_PRISM_TIMER_TEXT:format(5, 5),
					buildAdded = "0.7.0|120001",
					min = 1,
					max = 7,
					step = 1,
					height = 35,
					disabled = function()
						return not SC.Database:GetGlobalSetting("ProjectionPrismPreExpirationLeadTimer");
					end,
					get = function()
						return SC.Database:GetGlobalSetting("ProjectionPrismPreExpirationLeadTimer");
					end,
					set = function(val)
						SC.Database:SetGlobalSetting("ProjectionPrismPreExpirationLeadTimer", val);
						local reason = SC.Popups.Reason.PRE_EXPIRATION;
						SC.Auras.CancelAllPreExpirationTimers();
						SC.Items.CancelAllItemTimers(reason);
						SC.Popups.HideAllRefreshPopups(reason);
						SC.Options.RefreshStackSizes(SC.MSP.IsEnabled() and SC.Database:GetGlobalSetting("MSPStatusCheck"), false, true);
					end,
				},
				{
					type = "slider",
					label = L.OPTIONS_TAB_PRISM_TIMER:format(SC.Options.ByItemID[112384].name),
					tooltip = L.OPTIONS_TAB_PRISM_TIMER_TEXT:format(3, 3),
					buildAdded = "0.7.0|120001",
					min = 1,
					max = 5,
					step = 1,
					height = 35,
					disabled = function()
						return not SC.Database:GetGlobalSetting("ReflectingPrismPreExpirationLeadTimer");
					end,
					get = function()
						return SC.Database:GetGlobalSetting("ReflectingPrismPreExpirationLeadTimer");
					end,
					set = function(val)
						SC.Database:SetGlobalSetting("ReflectingPrismPreExpirationLeadTimer", val);
						local reason = SC.Popups.Reason.PRE_EXPIRATION;
						SC.Auras.CancelAllPreExpirationTimers();
						SC.Items.CancelAllItemTimers(reason);
						SC.Popups.HideAllRefreshPopups(reason);
						SC.Options.RefreshStackSizes(SC.MSP.IsEnabled() and SC.Database:GetGlobalSetting("MSPStatusCheck"), false, true);
					end,
				},
			}

			local widgets = SettingsElements.CreateWidgetRowContainer(categoryPanel, prismWidgetData, 2, 40, 20, true);

			self.profileWidgets[#self.profileWidgets + 1] = widgets;
			self.allWidgets[#self.allWidgets + 1] = widgets;
		end

		if #categoryConsumablesData > 0 then
			SettingsElements.CreateCategoryHeader(categoryPanel, BAG_FILTER_CONSUMABLES);

			local widgets = SettingsElements.CreateWidgetRowContainer(categoryPanel, categoryConsumablesData, 2, 40, 20, true);

			self.profileWidgets[#self.profileWidgets + 1] = widgets;
			self.allWidgets[#self.allWidgets + 1] = widgets;
		end

		local categoryToysData = {};

		for _, optionData in ipairs(SC.Options.Data) do
			if optionData.category == categoryName and optionData.type == SC.Options.Type.TOY then
				local toyAura = optionData.auraID;
				local toyName = optionData.name;
				local toyID = optionData.itemID;
				local toyIcon = optionData.icon;
				local toyType = optionData.type;

				local checkboxProfileKey = toyAura;

				categoryToysData[#categoryToysData + 1] = {
					dataType = toyType,
					type = "checkbox",
					label = toyName,
					icon = toyIcon,
					style = "option",
					itemID = toyID,
					preExpiration = optionData.preExpiration,
					unrefreshable = optionData.unrefreshable,
					nonAura = optionData.itemTrackable or optionData.spellTrackable,
					cooldownMismatch = optionData.cooldownMismatch,
					stacks = optionData.stacks,
					buildAdded = optionData.buildAdded,
					disabled = function()
						return IsToyDisabled(toyID);
					end,
					get = function()
						return SC.Database:GetProfileSetting(checkboxProfileKey, "enable");
					end,
					set = function(val)
						SC.Database:SetProfileSetting(checkboxProfileKey, "enable", val);
						SC.Popups.Toggle(toyName, toyAura, val);
					end,
				};

				-- Slider: Desired stacks (if applicable)
				if optionData.stacks then
					local sliderProfileKey = toyAura;

					categoryToysData[#categoryToysData + 1] = {
						type = "slider",
						label = L.OPTIONS_DESIRED_STACKS,
						tooltip = L.OPTIONS_SLIDER_TEXT and L.OPTIONS_SLIDER_TEXT:format(toyName) or nil,
						min = 1,
						max = optionData.maxStacks,
						step = 1,
						disabled = function()
							return not SC.Database:GetProfileSetting(sliderProfileKey, "enable");
						end,
						get = function()
							return SC.Database:GetProfileSetting(sliderProfileKey, "desiredStacks");
						end,
						set = function(val)
							SC.Database:SetProfileSetting(sliderProfileKey, "desiredStacks", val);
							local profileOptionData = SC.Database:GetOption(sliderProfileKey);
							if profileOptionData.enable then
								SC.Popups.Toggle(toyName, toyAura, true);
							end
						end
					};
				end
			end
		end

		if #categoryToysData > 0 then
			SettingsElements.CreateCategoryHeader(categoryPanel, TOY_BOX);

			local widgets = SettingsElements.CreateWidgetRowContainer(categoryPanel, categoryToysData, 2, 40, 20, true);

			self.profileWidgets[#self.profileWidgets + 1] = widgets;
			self.allWidgets[#self.allWidgets + 1] = widgets;
		end

		-- Optional if references are ever required:
		-- self.tabs[categoryName] = categoryTab;
		-- self.panels[categoryName] = categoryPanel;
	end

	SettingsElements.CreateTitleWithDescription(profilesPanel, L.OPTIONS_PROFILES_HEADER, L.OPTIONS_PROFILES_INSTRUCTION);

	local profilesData = {
		{
			type = "description",
			name = function()
				return L.OPTIONS_PROFILES_CURRENTPROFILE:format("|cnNORMAL_FONT_COLOR:" .. SC.Database:GetProfileName() .. "|r");
			end,
		},
		{
			type = "dropdown",
			label = L.OPTIONS_PROFILES_EXISTINGPROFILES_NAME,
			tooltip = L.OPTIONS_PROFILES_EXISTINGPROFILES_DESC,
			style = "radio",
			gearButton = true,
			buildAdded = "0.7.5|120001",
			values = function()
				return SC.Database:GetAllProfiles();
			end,
			get = function()
				return SC.Database:GetProfileName();
			end,
			set = function(val)
				SC.Database:SetProfile(val);
			end,
		},
		{
			type = "blank",
		},
		{
			type = "editbox",
			label = L.OPTIONS_PROFILES_NEWPROFILE_NAME,
			tooltip = L.OPTIONS_PROFILES_NEWPROFILE_DESC,
			maxChars = 32,
			get = function() end,
			set = function(val)
				SC.ConfirmDialog:Show(L.OPTIONS_PROFILES_NEWPROFILE_CONFIRM:format(val), function()
					SC.Database:CreateProfile(val);
				end);
			end,
		},
		{
			type = "dropdown",
			label = L.OPTIONS_PROFILES_COPYFROM_NAME,
			tooltip = L.OPTIONS_PROFILES_COPYFROM_DESC,
			style = "button",
			values = function()
				return SC.Database:GetAllProfiles(true, false);
			end,
			get = function() end,
			set = function(val)
				SC.ConfirmDialog:Show(L.OPTIONS_PROFILES_COPYFROM_CONFIRM:format(val), function()
					SC.Database:CopyProfile(val);
				end);
			end,
		},
		{
			type = "blank",
		},
		{
			type = "button",
			label = L.OPTIONS_PROFILES_RESETBUTTON_NAME,
			tooltip = L.OPTIONS_PROFILES_RESETBUTTON_DESC,
			func = function()
				SC.ConfirmDialog:Show(L.OPTIONS_PROFILES_RESETBUTTON_CONFIRM, function()
					SC.Database:ResetProfile();
				end);
			end,
		},
		{
			type = "dropdown",
			label = L.OPTIONS_PROFILES_DELETEPROFILE_NAME,
			tooltip = L.OPTIONS_PROFILES_DELETEPROFILE_DESC,
			style = "button",
			values = function()
				return SC.Database:GetAllProfiles(true, true);
			end,
			get = function() end,
			set = function(val)
				SC.ConfirmDialog:Show(L.OPTIONS_PROFILES_DELETEPROFILE_CONFIRM:format(val), function()
					SC.Database:DeleteProfile(val);
				end);
			end,
		},
	};

	self.allWidgets[#self.allWidgets + 1] = SettingsElements.CreateWidgetRowContainer(profilesPanel, profilesData, 3, 40);

	SC.ElvUI.RegisterSkinnableElement(self, "frame");
end

---OnDragStart begins moving the config frame.
function SippyCup_SettingsMixin:OnDragStart()
	self:StartMoving();
	self:SetUserPlaced(false);
end

---OnDragStop stops moving the config frame.
function SippyCup_SettingsMixin:OnDragStop()
	self:StopMovingOrSizing();
	self:SetUserPlaced(false);
end

---OnShow refreshes all widget states and applies ElvUI skinning when the frame is shown.
function SippyCup_SettingsMixin:OnShow()
	local totalWidth = 0;
	for _, tab in ipairs(self.Tabs) do
		PanelTemplates_TabResize(tab, 15, nil, 65);
		PanelTemplates_DeselectTab(tab);
		totalWidth = totalWidth + tab:GetWidth() + 5; -- 5px spacing between tabs
	end
	self:SetWidth(totalWidth + 0); -- padding

	self:RefreshWidgets();
	SC.ElvUI.SkinRegisteredElements();
	local tabToShow = lastSelectedTab or 1;
	self:SetTab(tabToShow);
end

-- ============================================================
-- Settings module
-- ============================================================

---ShowSettings Toggles the main config frame and optionally switches to a specified tab.
---@param view number? Optional tab index, defaults to 1.
function Settings:ShowSettings(view)
	if not SC.SettingsFrame then
		SC.Settings:Init();
	end

	SC.SettingsFrame:SetShown(not SC.SettingsFrame:IsShown());
	SC.SettingsFrame:Raise();

	if view then
		SC.SettingsFrame:SetTab(view);
	end
end

---TryCreateConfigFrame creates the config menu frame if it does not already exist.
---@return nil
function Settings:Init()
	local frame = CreateFrame("Frame", "SippyCup_Settings", UIParent, "SippyCup_SettingsMenuTemplate");
	SC.SettingsFrame = frame;
end

SC.Settings = Settings;
