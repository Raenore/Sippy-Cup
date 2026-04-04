-- Copyright The Sippy Cup Authors
-- Inspired by Eavesdropper
-- SPDX-License-Identifier: Apache-2.0

local L = SC.Localization;

---@class SippyCupSettingsElements
local SettingsElements = {};

local MISMATCH_ICON = "|TInterface\\AddOns\\SippyCup\\Resources\\UI\\ui-icon-mismatch:16:16|t";

-- ============================================================
-- Helper functions
-- ============================================================

---ApplyToFrames applies a given function to a single frame or a list of frames.
---@param frame table|table[] A single frame or a list of frames
---@param func function The function to apply to each frame
local function ApplyToFrames(frame, func)
	if not frame or not func then return; end

	if type(frame) == "table" and not frame.GetObjectType then
		for i = 1, #frame do
			func(frame[i]);
		end
	else
		func(frame);
	end
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

---ApplyDisabledState sets a widget's enabled or disabled state based on a provided function.
---If the widget is a slider, it adjusts the color of the slider's text accordingly.
---@param widget table The widget frame to enable or disable.
---@param disabledFunc function A function that returns true if the widget should be disabled.
---@param isSlider boolean? Whether the widget is a slider requiring text color adjustment. Defaults to false.
local function ApplyDisabledState(widget, disabledFunc, isSlider)
	isSlider = isSlider or false;

	if type(disabledFunc) ~= "function" then
		return;
	end

	local disabled = disabledFunc();

	if disabled then
		widget:Disable();
	else
		widget:Enable();
	end

	local r, g, b = (disabled and GRAY_FONT_COLOR or WHITE_FONT_COLOR):GetRGB();

	if isSlider then
		widget.RightText:SetVertexColor(r, g, b);
		widget.MinText:SetVertexColor(r, g, b);
		widget.MaxText:SetVertexColor(r, g, b);
	end

	-- recolor direct FontString children
	for _, child in ipairs({widget:GetChildren()}) do
		if child:IsObjectType("FontString") then
			child:SetVertexColor(r, g, b);
		end
	end

	-- explicitly recolor a stored label
	if widget.label and widget.label.SetVertexColor then
		widget.label:SetVertexColor(r, g, b);
	end
end

-- ============================================================
-- Tooltip helpers
-- ============================================================

---AttachTooltip adds mouseover tooltips with a title and description to one or multiple frames.
---It sets up OnEnter and OnLeave scripts to show and hide the tooltip anchored as specified.
---@param frames table|table[] The single frame or list of frames to attach the tooltip to.
---@param title string The tooltip title text.
---@param description string The tooltip description text.
---@param style string? Optional style (currently unused).
---@param anchor string? Optional anchor point for tooltip, defaults to "ANCHOR_TOP".
local function AttachTooltip(frames, title, description, style, anchor) -- luacheck: no unused (style)
	if not title or not description then return; end

	local isList = type(frames) == "table" and not frames.GetObjectType;
	local firstFrame = isList and frames[1] or frames;
	if not firstFrame then return; end

	anchor = anchor or "ANCHOR_TOP";

	local function OnEnter(self)
		GameTooltip:SetOwner(firstFrame or frames, anchor);
		GameTooltip:SetText(title, WHITE_FONT_COLOR:GetRGB());
		GameTooltip:AddLine(description, nil, nil, nil, true);
		SC.ElvUI.SkinTooltip(GameTooltip);
		GameTooltip:Show();
	end

	local function OnLeave()
		GameTooltip:Hide();
	end

	ApplyToFrames(frames, function(f)
		f:SetScript("OnEnter", OnEnter);
		f:SetScript("OnLeave", OnLeave);
	end);
end

---AttachItemTooltip adds mouseover tooltips showing item info by itemID to one or multiple frames.
---It sets up OnEnter and OnLeave scripts to show and hide the item tooltip anchored as specified.
---@param frames table|table[] The single frame or list of frames to attach the tooltip to.
---@param itemID number|number[] The item ID(s) to create the tooltip for.
---@param anchor string? Optional anchor point for tooltip, defaults to "ANCHOR_TOP".
local function AttachItemTooltip(frames, itemID, anchor)
	if not itemID then return; end
	anchor = anchor or "ANCHOR_TOP";

	local firstID = GetFirstItemID(itemID);
	if not firstID then return; end

	local isList = type(frames) == "table" and not frames.GetObjectType;
	local firstFrame = isList and frames[1] or frames;
	if not firstFrame then return; end

	local item = Item:CreateFromItemID(firstID);

	item:ContinueOnItemLoad(function()
		local itemLink = item:GetItemLink();

		local function OnEnter()
			GameTooltip:SetOwner(firstFrame or frames, anchor);
			GameTooltip:SetHyperlink(itemLink);
			GameTooltip:Show();
		end

		local function OnLeave()
			GameTooltip:Hide();
		end

		ApplyToFrames(frames, function(f)
			f:SetScript("OnEnter", OnEnter);
			f:SetScript("OnLeave", OnLeave);
		end);
	end);
end

---AttachEditBoxTooltip attaches a tooltip with a title and description to one or more EditBox frames.
---The tooltip will display:
--- - On mouseover
--- - While the edit box is focused (including while typing)
---It will hide when the mouse leaves (unless still focused) or when focus is lost.
---
---@param frames EditBox|EditBox[] Either a single EditBox frame or a list of EditBox frames.
---@param title string The title text for the tooltip.
---@param description string The description text for the tooltip.
---@param style string? Currently unused; reserved for future styling options.
---@param anchor string? Anchor point for the tooltip. Defaults to "ANCHOR_TOP".
---@return nil
local function AttachEditBoxTooltip(frames, title, description, style, anchor) -- luacheck: no unused (style)
	if not title or not description then return; end

	local isList = type(frames) == "table" and not frames.GetObjectType;
	local firstFrame = isList and frames[1] or frames;
	if not firstFrame then return; end

	anchor = anchor or "ANCHOR_TOP";

	local function ShowTooltip()
		GameTooltip:SetOwner(firstFrame or frames, anchor);
		GameTooltip:SetText(title, WHITE_FONT_COLOR:GetRGB());
		GameTooltip:AddLine(description, nil, nil, nil, true);
		SC.ElvUI.SkinTooltip(GameTooltip);
		GameTooltip:Show();
	end

	local function HideTooltip()
		GameTooltip:Hide();
	end

	ApplyToFrames(frames, function(f)
		f:SetScript("OnEscapePressed", function(self)
			self:ClearFocus();
			HideTooltip();
		end)

		f:SetScript("OnEditFocusGained", function(self)
			self:HighlightText();
			ShowTooltip(self);
		end)

		f:SetScript("OnEditFocusLost", function(self)
			if not self:IsMouseOver() then
				HideTooltip();
			end
		end)

		f:SetScript("OnEnter", function(self) ShowTooltip(self) end)
		f:SetScript("OnLeave", function(self)
			if not self:HasFocus() then
				HideTooltip();
			end
		end)

		f:SetScript("OnTextChanged", function(self)
			if self:HasFocus() then
				ShowTooltip(self);
			end
		end);
	end);
end

---ApplyTooltip attaches a tooltip with a label and description to the given widget.
---@param widget table The frame or widget to attach the tooltip to.
---@param label string The title or label of the tooltip.
---@param tooltip string The tooltip description text.
---@param style string? Optional style parameter.
---@param anchor string? Optional tooltip anchor point, defaults to "ANCHOR_TOP".
local function ApplyTooltip(widget, label, tooltip, style, anchor)
	if not tooltip then return; end
	AttachTooltip(widget, label, tooltip, style, anchor);
end

---GetLowestChildBottomIncludingFontStrings finds the lowest vertical position (bottom) among all child frames and font strings/textures of the given frame.
---@param frame table The frame whose children and regions are checked.
---@return number? lowest The lowest bottom coordinate found, or nil if none.
local function GetLowestChildBottomIncludingFontStrings(frame)
	local lowest = nil;

	-- Iterate children without table allocation
	local i = 1;
	while true do
		local child = select(i, frame:GetChildren());
		if not child then break end

		local bottom = child:GetBottom();
		if bottom and (not lowest or bottom < lowest) then
			lowest = bottom;
		end
		i = i + 1;
	end

	-- Iterate regions similarly
	i = 1;
	while true do
		local region = select(i, frame:GetRegions());
		if not region then break end

		if region:IsObjectType("FontString") or region:IsObjectType("Texture") then
			local bottom = region:GetBottom();
			if bottom and (not lowest or bottom < lowest) then
				lowest = bottom;
			end
		end
		i = i + 1;
	end

	return lowest;
end

local function WrapButtonClick(original)
	return function(self, ...)
		original(self, ...);
		if SC.SettingsFrame then
			RunNextFrame(function()
				SC.SettingsFrame:RefreshWidgets();
			end);
		end
	end
end

-- ============================================================
-- Header elements
-- ============================================================

---CreateTitleWithDescription creates title and description font strings under the parent frame.
---If optionsPage is true, it appends extra localized text to the description and adds legenda buttons with tooltips.
---@param parent table The parent frame to attach the texts and buttons to.
---@param titleText string? The text for the title font string.
---@param descText string? The text for the description font string.
---@param optionsPage boolean? Whether to append extra text and create legenda buttons.
---@return FontString title The created title font string.
---@return FontString description The created description font string.
function SettingsElements.CreateTitleWithDescription(parent, titleText, descText, optionsPage)
	local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	title:SetPoint("TOPLEFT", 20, -16);
	title:SetText(titleText or "");

	if optionsPage then
		descText = (descText or "") .. L.OPTIONS_TITLE_EXTRA;
	end

	local realParent = parent;
	if parent.scrollFrame then
		realParent = parent.scrollFrame;
	end

	local description = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8);
	description:SetWidth(realParent:GetWidth() - 32);
	description:SetJustifyH("LEFT");
	description:SetText(descText or "");

	-- Add the legenda
	if optionsPage then
		local function CreateLegendaButton(icon, pointTo, tooltipName, tooltipDesc)
			local btn = CreateFrame("Button", nil, parent, "UIPanelDynamicResizeButtonTemplate");
			if icon:sub(1, 2) == "|T" then
				btn:SetText(icon);
			else
				btn:SetText("|A:" .. icon .. ":16:16|a");
			end
			btn:SetWidth(30);
			btn:SetPoint("TOPLEFT", pointTo, "TOPRIGHT", 5, 0);
			SC.ElvUI.RegisterSkinnableElement(btn, "button");
			AttachTooltip(btn, tooltipName, tooltipDesc);
			return btn;
		end

		local preExpirationButton = CreateFrame("Button", nil, parent, "UIPanelDynamicResizeButtonTemplate");
		preExpirationButton:SetText("|A:uitools-icon-refresh:16:16|a");
		preExpirationButton:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -10);
		preExpirationButton:SetWidth(30);
		SC.ElvUI.RegisterSkinnableElement(preExpirationButton, "button");
		AttachTooltip(preExpirationButton, L.OPTIONS_LEGENDA_PRE_EXPIRATION_NAME, L.OPTIONS_LEGENDA_PRE_EXPIRATION_DESC);

		local nonRefreshableButton = CreateLegendaButton("uitools-icon-close", preExpirationButton, L.OPTIONS_LEGENDA_NON_REFRESHABLE_NAME, L.OPTIONS_LEGENDA_NON_REFRESHABLE_DESC);
		local stacksButton = CreateLegendaButton("uitools-icon-plus", nonRefreshableButton, L.OPTIONS_LEGENDA_STACKS_NAME, L.OPTIONS_LEGENDA_STACKS_DESC);
		local noAuraButton = CreateLegendaButton("uitools-icon-minus", stacksButton, L.OPTIONS_LEGENDA_NO_AURA_NAME, L.OPTIONS_LEGENDA_NO_AURA_DESC);
		local cooldownMismatchButton = CreateLegendaButton(MISMATCH_ICON, noAuraButton, L.OPTIONS_LEGENDA_COOLDOWN_NAME, L.OPTIONS_LEGENDA_COOLDOWN_DESC); -- luacheck: no unused (cooldownButton)
	end

	return title, description;
end

---CreateCategoryHeader adds a centered header with decorative horizontal lines.
---@param parent Frame The parent frame to contain the header.
---@param titleText string The text to display in the header.
---@param topOffset number? Vertical offset from the bottom of the lowest child (default 20).
---@return Frame container The frame holding the header and lines.
function SettingsElements.CreateCategoryHeader(parent, titleText, topOffset)
	local parentTop = parent:GetTop();
	local parentBottom = GetLowestChildBottomIncludingFontStrings(parent);
	local relativeBottom = parentTop - parentBottom;

	topOffset = -(math.abs(topOffset or 10)); -- 10px below last child
	local startY = -relativeBottom + topOffset; -- relative Y from parent's TOP for the new widgets

	local container = CreateFrame("Frame", nil, parent);
	container:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, startY);
	container:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -16, startY);
	container:SetHeight(20);  -- Enough to hold text and lines

	-- Title font string
	local title = container:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	title:SetText(titleText or "");
	title:SetJustifyH("CENTER");
	title:SetPoint("CENTER", container, "CENTER", 0, 0);

	-- Left line
	local leftLine = container:CreateTexture(nil, "ARTWORK");
	leftLine:SetColorTexture(1, 1, 1, 0.3);
	leftLine:SetHeight(1);
	leftLine:SetPoint("LEFT", container, "LEFT", 0, 0);
	leftLine:SetPoint("RIGHT", title, "LEFT", -8, 0);  -- 8px padding from text

	-- Right line
	local rightLine = container:CreateTexture(nil, "ARTWORK");
	rightLine:SetColorTexture(1, 1, 1, 0.3);
	rightLine:SetHeight(1);
	rightLine:SetPoint("LEFT", title, "RIGHT", 8, 0);
	rightLine:SetPoint("RIGHT", container, "RIGHT", 0, 0);

	return container;
end

-- ============================================================
-- Widget constructors
-- ============================================================

---CreateConfigBlank creates an invisible placeholder frame of the same size as the container.
---Used to occupy space without displaying any content.
---@param elementContainer table The parent frame to contain the blank widget.
---@param data table Data associated with the placeholder.
---@return Frame widget The created blank frame widget.
function SettingsElements.CreateConfigBlank(elementContainer, data)
	-- Create an empty frame placeholder to take up space but show nothing
	local width, height = elementContainer:GetWidth(), elementContainer:GetHeight();

	local widget = CreateFrame("Frame", nil, elementContainer);
	widget:SetSize(width, height);
	widget:SetPoint("TOPLEFT", 0, 0);
	widget.data = data;

	-- No need to register or do anything else

	return widget;
end

---CreateConfigButton creates a button filling the element container, with label, disabled state, click handler, and tooltip.
---@param elementContainer table The parent frame to contain the button.
---@param data table Configuration data including label, disabled function, click function, and tooltip.
---@return Button widget The created button widget.
function SettingsElements.CreateConfigButton(elementContainer, data)
	local widget = CreateFrame("Button", nil, elementContainer, "UIPanelButtonTemplate");
	local label = data.label or "Button";

	if #label > 30 then
		label = string.sub(label, 1, 27) .. "...";
	end

	widget:SetText(label);
	widget:SetAllPoints(elementContainer);
	widget.data = data;

	if data.buildAdded and SC.Utils.CheckNewlyAdded(data.buildAdded) then
		local newPip = widget:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
		widget.newPip = newPip;
		newPip:SetPoint("CENTER", widget, "TOPLEFT");
		newPip:SetText("|A:UI-HUD-MicroMenu-Communities-Icon-Notification:21:21|a");
	end

	widget:SetMotionScriptsWhileDisabled(true);

	ApplyDisabledState(widget, data.disabled);

	if type(data.func) == "function" then
		widget:SetScript("OnClick", WrapButtonClick(data.func));
	end

	if data.tooltip then
		ApplyTooltip(widget, data.label, data.tooltip);
	end

	SC.ElvUI.RegisterSkinnableElement(widget, "button");

	return widget;
end

---CreateConfigCheckBox creates a checkbox with optional icon, label, disabled state, and tooltip, inside the given container.
---@param elementContainer table The parent frame to hold the checkbox.
---@param data table Configuration data including label, icon, style, get/set functions, disabled function, tooltip, and flags.
---@return CheckButton widget The created checkbox widget.
function SettingsElements.CreateConfigCheckBox(elementContainer, data)
	local widget = CreateFrame("CheckButton", nil, elementContainer, "SettingsCheckBoxTemplate");
	local size = elementContainer:GetHeight();
	widget:SetSize(size, size);
	widget:SetPoint("LEFT", 0, 0);
	widget.data = data;

	-- Icon and label setup
	local labelText = data.label or "";
	if data.notificationToggle then
		labelText = labelText .. " |A:UI-HUD-MicroMenu-Communities-Icon-Notification:21:21|a";
	elseif #labelText > 30 then
		labelText = string.sub(labelText, 1, 27) .. "...";
	end
	local icon;

	if data.style == "option" then
		icon = elementContainer:CreateTexture(nil, "ARTWORK");
		icon:SetTexture(data.icon);
		icon:SetSize(size, size);
		icon:SetPoint("LEFT", widget, "RIGHT", 5, 0);
		SC.ElvUI.RegisterSkinnableElement(icon, "icon");

		local addition = "";
		if data.preExpiration or data.unrefreshable or data.nonAura or data.stacks or data.cooldownMismatch then
			addition = " (";
			if data.preExpiration then addition = addition .. "|A:uitools-icon-refresh:16:16|a"; end
			if data.unrefreshable then addition = addition .. "|A:uitools-icon-close:16:16|a"; end
			if data.stacks then addition = addition .. "|A:uitools-icon-plus:16:16|a"; end
			if data.nonAura and not data.cooldownMismatch then addition = addition .. "|A:uitools-icon-minus:16:16|a"; end
			if data.cooldownMismatch then addition = addition .. MISMATCH_ICON; end
			addition = addition .. ")";
		end
		labelText = labelText .. addition;
	end

	local label = widget:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	widget.label = label;
	if icon then
		label:SetPoint("LEFT", icon, "RIGHT", 5, 0);
	else
		label:SetPoint("LEFT", widget, "RIGHT", 5, 0);
	end
	label:SetText(labelText);

	if data.buildAdded and SC.Utils.CheckNewlyAdded(data.buildAdded) then
		local newPip = widget:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
		widget.newPip = newPip;
		newPip:SetPoint("CENTER", widget, "TOPLEFT");
		newPip:SetText("|A:UI-HUD-MicroMenu-Communities-Icon-Notification:21:21|a");
	end

	widget:SetMotionScriptsWhileDisabled(true);
	widget:EnableMouse(true);
	elementContainer:EnableMouse(true);
	label:EnableMouse(true);

	ApplyDisabledState(widget, data.disabled);

	local initialValue = false;
	if type(data.get) == "function" then
		initialValue = data.get();
	end
	widget:SetChecked(initialValue);

	local function TriggerCheckboxClick(self)
		if self:IsEnabled() then
			local checked = self:GetChecked();
			if checked ~= data.get() then
				data.set(checked);
				if SC.SettingsFrame then
					SC.SettingsFrame:RefreshWidgets();
				end
			end
		end
	end

	local function OnLabelOrIconClick()
		if widget:IsEnabled() then
			widget:Click();
		end
	end

	if icon then
		icon:SetScript("OnMouseUp", OnLabelOrIconClick);
	end
	label:SetScript("OnMouseUp", OnLabelOrIconClick);
	elementContainer:SetScript("OnMouseUp", OnLabelOrIconClick);
	widget:SetScript("OnClick", TriggerCheckboxClick);

	if data.tooltip or data.style == "option" then
		if data.style == "option" then
			AttachItemTooltip({label, elementContainer, icon, widget}, data.itemID);
		else
			ApplyTooltip({label, elementContainer, widget}, data.label, data.tooltip, data.style);
		end
	end

	SC.ElvUI.RegisterSkinnableElement(widget, "checkbox");

	return widget;
end

---CreateConfigDescription creates a font string within the container, showing static or dynamic text with styling.
---@param elementContainer table The parent frame to hold the description.
---@param data table Configuration data containing the text or a function returning the text.
---@return FontString widget The created font string widget.
function SettingsElements.CreateConfigDescription(elementContainer, data)
	local widget = elementContainer:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
	widget:SetPoint("TOPLEFT", elementContainer, "TOPLEFT", 0, 0);
	widget:SetPoint("BOTTOMRIGHT", elementContainer, "BOTTOMRIGHT", 0, 0);
	widget:SetJustifyV("MIDDLE");
	widget:SetJustifyH("LEFT");
	widget.data = data;

	local text = data.name;
	if type(text) == "function" then
		text = text();
	end
	widget:SetText(text or "");

	SC.ElvUI.RegisterSkinnableElement(widget, "description");

	return widget;
end

---CreateConfigDropdown creates a dropdown widget inside the container with configurable options and behavior.
---@param elementContainer table The parent frame to hold the dropdown.
---@param data table Configuration data including label, values, get/set callbacks, style, tooltip, and sorting.
---@return Frame widget The created dropdown widget.
function SettingsElements.CreateConfigDropdown(elementContainer, data)
	local widget = CreateFrame("DropdownButton", nil, elementContainer, "WowStyle1DropdownTemplate");
	widget:SetPoint("TOPLEFT", elementContainer, "TOPLEFT", 0, 2); -- 2 more height to fit whole container
	widget:SetPoint("BOTTOMRIGHT", elementContainer, "BOTTOMRIGHT", 0, -2); -- 2 more height to fit whole container
	widget.data = data;

	if data.buildAdded and SC.Utils.CheckNewlyAdded(data.buildAdded) then
		local newPip = widget:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
		widget.newPip = newPip;
		newPip:SetPoint("CENTER", widget, "TOPLEFT");
		newPip:SetText("|A:UI-HUD-MicroMenu-Communities-Icon-Notification:21:21|a");
	end

	widget:SetMotionScriptsWhileDisabled(true);

	ApplyDisabledState(widget, data.disabled);

	local labelText = type(data.label) == "function" and data.label() or data.label;

	if (data.style == "button" or data.style == "checkbox") and widget.Text then
		widget.Text:SetText(labelText or "");
	end

	local function IsSelected(index)
		if type(data.get) == "function" then
			return index == data.get();
		end
		return false;
	end

	local function SetSelected(index)
		if type(data.set) == "function" then
			data.set(index);
			if SC.SettingsFrame then
				SC.SettingsFrame:RefreshWidgets();
			end
		end
	end

	widget:SetupMenu(function(_, root)
		local values = type(data.values) == "function" and data.values() or data.values or {};
		local sorting = data.sorting or {};

		root:CreateTitle(labelText);
		root:CreateDivider();

		-- Make the dropdown list have a scrollbar on mainline.
		if root.SetScrollMode then
			local optionHeight = 20; -- 20 is the default height.
			local maxLines = 20;
			local maxScrollExtent = optionHeight * maxLines;
			root:SetScrollMode(maxScrollExtent);
		end

		local entries = {};

		---Unpacks a values entry into (label, desc, getter, setter), supporting string and {label, desc, getter, setter} formats.
		local function unpackValue(v)
			if type(v) == "table" then
				return v[1], v[2], v[3], v[4];
			end
			return v, nil, nil, nil;
		end

		if #sorting > 0 then
			for _, key in ipairs(sorting) do
				if values[key] then
					local label, desc, getter, setter = unpackValue(values[key]);
					table.insert(entries, {label, key, desc, getter, setter});
				end
			end
		else
			local temp = {};
			for key, v in pairs(values) do
				local label, desc, getter, setter = unpackValue(v);
				table.insert(temp, {key = key, label = label, desc = desc, getter = getter, setter = setter});
			end
			table.sort(temp, function(a, b) return a.label < b.label end);
			for _, item in ipairs(temp) do
				table.insert(entries, {item.label, item.key, item.desc, item.getter, item.setter});
			end
		end

		for _, entry in ipairs(entries) do
			local label, value, desc, getter, setter = entry[1], entry[2], entry[3], entry[4], entry[5];
			local dropdownButton;
			if data.style == "button" then
				dropdownButton = root:CreateButton(label, SetSelected, value);
			elseif data.style == "checkbox" then
				dropdownButton = root:CreateCheckbox(label, getter, function() setter(not getter()); end);
			else
				dropdownButton = root:CreateRadio(label, IsSelected, SetSelected, value);
			end

			if desc then
				local function OnTooltipShow(tooltip)
					local tooltipTitle = MenuUtil.GetElementText(dropdownButton);

					GameTooltip_SetTitle(tooltip, tooltipTitle);
					GameTooltip_AddNormalLine(tooltip, desc, true);
				end

				dropdownButton:SetTooltip(OnTooltipShow);
			end

			if data.gearButton and label ~= "Default" then
				dropdownButton:AddInitializer(function(button, description, menu) -- luacheck: no unused (description)
					local gearButton = MenuTemplates.AttachAutoHideGearButton(button);
					gearButton:SetPoint("RIGHT");
					gearButton:SetScript("OnClick", function()
						menu:Close();
						StaticPopupDialogs["SIPPYCUP_RENAME_PROFILE"].text = L.POPUP_RENAME_PROFILE:format(label);
						StaticPopup_Show("SIPPYCUP_RENAME_PROFILE", nil, nil, { oldName = label });
					end);

					MenuUtil.HookTooltipScripts(gearButton, function(tooltip)
						GameTooltip_SetTitle(tooltip, L.OPTIONS_PROFILES_RENAMEPROFILE_NAME);
						GameTooltip_AddNormalLine(tooltip, L.OPTIONS_PROFILES_RENAMEPROFILE_DESC);
					end);

					-- Perhaps one day, this is the Block/Cancel button
					-- local cancelButton = MenuTemplates.AttachAutoHideCancelButton(button);
					-- cancelButton:SetPoint("RIGHT", gearButton, "LEFT", -3, 0);
				end);
			end
		end

		if data.style == "button" or data.style == "checkbox" then
			widget:OverrideText(labelText or "");
		end
	end);

	local fontString = widget.Text or widget:GetFontString();
	if fontString then
		widget.Text:ClearAllPoints();
		widget.Text:SetPoint("TOPLEFT", widget, "TOPLEFT", 8, -2);    -- Horizontal padding = 8, vertical nudge down = -2
		widget.Text:SetPoint("BOTTOMRIGHT", widget, "BOTTOMRIGHT", -24, 2); -- Reserve space on the right for the dropdown arrow
		widget.Text:SetJustifyV("MIDDLE");  -- Center vertically
		widget.Text:SetJustifyH(data.align == "right" and "RIGHT" or data.align == "center" and "CENTER" or "LEFT");
	end

	if data.tooltip then
		ApplyTooltip(widget, labelText, data.tooltip);
	end

	SC.ElvUI.RegisterSkinnableElement(widget, "dropdown");

	return widget;
end

---CreateConfigEditBox creates an edit box widget with optional get/set callbacks and tooltip.
---@param elementContainer table The parent frame to contain the edit box.
---@param data table Configuration including label, get/set functions, and tooltip.
---@return Frame widget The created edit box widget.
function SettingsElements.CreateConfigEditBox(elementContainer, data)
	local widget = CreateFrame("EditBox", nil, elementContainer, "InputBoxTemplate");
	widget:SetAutoFocus(false);
	widget:SetPoint("TOPLEFT", elementContainer, "TOPLEFT", 0, 0);
	widget:SetPoint("BOTTOMRIGHT", elementContainer, "BOTTOMRIGHT", 0, 0);
	widget.data = data;

	if type(data.maxChars) == "number" and data.maxChars > 0 then
		widget:SetMaxLetters(data.maxChars);
	end

	if data.buildAdded and SC.Utils.CheckNewlyAdded(data.buildAdded) then
		local newPip = widget:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
		widget.newPip = newPip;
		newPip:SetPoint("CENTER", widget, "TOPLEFT");
		newPip:SetText("|A:UI-HUD-MicroMenu-Communities-Icon-Notification:21:21|a");
	end

	if type(data.get) == "function" and type(data.set) == "function" then
		widget:SetScript("OnEnterPressed", function(self)
			data.set(self:GetText());
			self:SetText(""); -- Intentionally clear after submission
			self:ClearFocus();
			if SC.SettingsFrame then
				SC.SettingsFrame:RefreshWidgets();
			end
		end);
	end

	if data.tooltip then
		AttachEditBoxTooltip(widget, data.label, data.tooltip);
	end

	SC.ElvUI.RegisterSkinnableElement(widget, "editbox");

	return widget;
end

---CreateConfigSlider creates a slider widget with optional get/set callbacks, step rounding, and tooltip.
---@param elementContainer table The parent frame to contain the slider.
---@param data table Configuration including min, max, step, label, get/set functions, disabled state, and tooltip.
---@return Frame widget The created slider widget.
function SettingsElements.CreateConfigSlider(elementContainer, data)
	local widget = CreateFrame("Slider", nil, elementContainer, "MinimalSliderWithSteppersTemplate");

	local minVal = data.min or 1;
	local maxVal = data.max or 10;
	local stepVal = data.step or 1;

	widget.Slider:SetMinMaxValues(minVal, maxVal);
	widget.Slider:SetValueStep(stepVal);
	widget.Slider:SetValue(minVal);
	widget:SetObeyStepOnDrag(true);

	widget.Back:SetMotionScriptsWhileDisabled(true);
	widget.Forward:SetMotionScriptsWhileDisabled(true);
	widget.data = data;

	local r, g, b = WHITE_FONT_COLOR:GetRGB();

	widget.TopText:SetText(data.label);

	widget.MinText:SetText(minVal);
	widget.MinText:SetVertexColor(r, g, b);

	widget.MaxText:SetText(maxVal);
	widget.MaxText:SetVertexColor(r, g, b);

	widget.RightText:SetVertexColor(r, g, b);

	widget.TopText:Show();
	widget.MinText:Show();
	widget.MaxText:Show();
	widget.RightText:Show();

	widget:SetPoint("LEFT", 0, 0);
	widget:SetWidth(elementContainer:GetWidth() * 0.8);
	widget:SetHeight(data.height or 41);

	if data.buildAdded and SC.Utils.CheckNewlyAdded(data.buildAdded) then
		local newPip = widget:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
		widget.newPip = newPip;
		newPip:SetPoint("CENTER", widget.Back, "TOPLEFT");
		newPip:SetText("|A:UI-HUD-MicroMenu-Communities-Icon-Notification:21:21|a");
	end

	ApplyDisabledState(widget, data.disabled, true);

	local function UpdateTextDisplay(val)
		if widget.RightText then
			widget.RightText:SetText(string.format("%d", val));
		end
	end

	if type(data.get) == "function" and type(data.set) == "function" then
		local function RoundToStep(val)
			return math.floor(val / stepVal + 0.5) * stepVal;
		end

		local initial = RoundToStep(data.get());
		widget.Slider:SetValue(initial);
		UpdateTextDisplay(initial);

		local lastValue = initial;
		widget.Slider:SetScript("OnValueChanged", function(_, val)
			local rounded = RoundToStep(val);
			if rounded ~= lastValue then
				lastValue = rounded;
				data.set(rounded);
				UpdateTextDisplay(rounded);
				if SC.SettingsFrame then
					SC.SettingsFrame:RefreshWidgets();
				end
			end
		end);
	end

	if data.tooltip then
		ApplyTooltip({widget.Slider, widget.Back, widget.Forward, widget, elementContainer}, data.label, data.tooltip);
	end

	SC.ElvUI.RegisterSkinnableElement(widget, "slider");

	return widget;
end

---CreateWidgetRowContainer arranges multiple widgets in rows within a parent frame.
---@param parent Frame The parent frame to hold widgets.
---@param widgetData table List of widget data tables describing each widget.
---@param widgetsPerRow number? Number of widgets per row (default 3).
---@param rowSpacing number? Vertical spacing between rows (default 20).
---@param topOffset number? Vertical offset from bottom of parent's lowest child (default 20).
---@return table widgets List of created widget frames.
function SettingsElements.CreateWidgetRowContainer(parent, widgetData, widgetsPerRow, rowSpacing, topOffset)
	local parentTop = parent:GetTop();
	local parentBottom = GetLowestChildBottomIncludingFontStrings(parent);
	local relativeBottom = parentTop - parentBottom;

	topOffset = -(math.abs(topOffset or 20)); -- 20px below last child
	local startY = -relativeBottom + topOffset; -- relative Y from parent's TOP for the new widgets

	widgetsPerRow = widgetsPerRow or 3;
	rowSpacing = rowSpacing or 20; -- fixed vertical spacing between rows

	local widgetSpacing = 20; -- horizontal spacing between widgets
	local leftPadding, rightPadding = 35, 35;
	if widgetsPerRow > 3 then
		leftPadding, rightPadding = 20, 20;
		widgetSpacing = 10;
	end
	local containerWidth = parent:GetWidth() - leftPadding - rightPadding;
	local widgetWidth = (containerWidth - widgetSpacing * (widgetsPerRow - 1)) / widgetsPerRow;
	local rowHeight = 24;

	local widgets = {};

	for i, data in ipairs(widgetData) do
		local col = (i - 1) % widgetsPerRow;
		local row = math.floor((i - 1) / widgetsPerRow);
		local xOffset = leftPadding + col * (widgetWidth + widgetSpacing);
		local yOffset = startY - row * (rowHeight + rowSpacing);

		local elementContainer = CreateFrame("Frame", nil, parent);
		elementContainer:SetSize(widgetWidth, rowHeight);
		elementContainer:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset);

		local widgetType = data.type or "checkbox";
		local factory = {
			button      = SettingsElements.CreateConfigButton,
			checkbox    = SettingsElements.CreateConfigCheckBox,
			description = SettingsElements.CreateConfigDescription,
			dropdown    = SettingsElements.CreateConfigDropdown,
			editbox     = SettingsElements.CreateConfigEditBox,
			blank       = SettingsElements.CreateConfigBlank,
			slider      = SettingsElements.CreateConfigSlider,
		};

		local createFunc = factory[widgetType];
		if createFunc then
			local widget = createFunc(elementContainer, data);
			widgets[#widgets + 1] = widget;
		end
	end

	return widgets;
end

-- ============================================================
-- Inset / composite elements
-- ============================================================

---CreateInset creates a skinnable inset frame inside the parent with provided widget data.
---Positions the inset relative to the parent's top and optionally offset by topOffset.
---Creates various UI elements (logo, title, version, build, author, bsky) based on insetData entries and attaches tooltips.
---@param parent table The parent frame to attach the inset frame to.
---@param insetData table List of widget data entries describing the inset contents.
---@return Frame infoInset The created inset frame containing the widgets.
function SettingsElements.CreateInset(parent, insetData)
	local infoInset = CreateFrame("Frame", nil, parent, "InsetFrameTemplate");

	-- Distance from bottom
	local bottomOffset = 10;

	infoInset:SetPoint("BOTTOM", parent, "BOTTOM", 0, bottomOffset);

	infoInset:SetPoint("LEFT", parent, "LEFT", 10, 0);
	infoInset:SetPoint("RIGHT", parent, "RIGHT", -10, 0);
	infoInset:SetHeight(75);

	local logo, title, author, version, build, bsky;

	-- Loop through each entry in widgetData to create widgets with labels and optional tooltips
	for _, data in ipairs(insetData) do
		local entryType = data.type or "logo";

		if entryType == "logo" then
			logo = infoInset:CreateTexture(nil, "ARTWORK");
			logo:SetTexture(SC.Globals.addon_icon_texture);
			logo:SetSize(52, 52);
			logo:SetPoint("LEFT", 8, 0);
			SC.ElvUI.RegisterSkinnableElement(logo, "icon");

			AttachTooltip(logo, SC.Globals.addon_title, "Sluuuuuuuurp..");
		elseif entryType == "title" then
			title = infoInset:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge");
			title:SetText(data.text or "");
			title:SetPoint("TOPLEFT", logo, "TOPRIGHT", 10, 0);
		elseif entryType == "version" then
			version = infoInset:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
			version:SetText(data.text or "");
			version:SetPoint("BOTTOMLEFT", title, "BOTTOMRIGHT", 5, 0)
		elseif entryType == "build" then
			build = CreateFrame("Button", nil, infoInset, "UIPanelDynamicResizeButtonTemplate");
			build:SetText(data.text or "");
			DynamicResizeButton_Resize(build);
			build:SetPoint("BOTTOMLEFT", logo, "BOTTOMRIGHT", 8, 0);
			SC.ElvUI.RegisterSkinnableElement(build, "button");

			local tooltipText = type(data.tooltip) == "function" and data.tooltip() or (data.tooltip or "");
			AttachTooltip(build, data.text or "", tooltipText);
		elseif entryType == "author" then
			author = infoInset:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
			author:SetText(data.text or "");
			author:SetPoint("TOPRIGHT", infoInset, "TOPRIGHT", -8, 0);
			author:SetPoint("TOP", logo, "TOP", 0, 0);
		elseif entryType == "bsky" then
			bsky = CreateFrame("Button", nil, infoInset, "UIPanelDynamicResizeButtonTemplate");
			bsky:SetText(data.text or "");
			DynamicResizeButton_Resize(bsky);
			bsky:SetPoint("BOTTOMRIGHT", infoInset, "BOTTOMRIGHT", -8, 0);
			bsky:SetPoint("BOTTOM", logo, "BOTTOM", 0, 0);
			SC.ElvUI.RegisterSkinnableElement(bsky, "button");

			AttachTooltip(bsky, data.text or "", data.tooltip or "");

			bsky:SetScript("OnClick", function()
				SC.LinkDialog.CreateExternalLinkDialog("https://bsky.app/profile/dawnsong.me");
			end);

			if SC.Globals.IS_DEV_BUILD then
				local debugDropDown = CreateFrame("DropdownButton", nil, infoInset, "WowStyle1DropdownTemplate");
				debugDropDown:SetPoint("TOPRIGHT", bsky, "TOPLEFT", -8, 0);
				debugDropDown:SetPoint("BOTTOMLEFT", bsky, "BOTTOMLEFT", -148, 0);

				debugDropDown:SetupMenu(function(_, root)
					root:CreateTitle("Debug Level");
					root:CreateDivider();

					-- Make the dropdown list have a scrollbar on mainline.
					if root.SetScrollMode then
						local optionHeight = 20; -- 20 is the default height.
						local maxLines = 20;
						local maxScrollExtent = optionHeight * maxLines;
						root:SetScrollMode(maxScrollExtent);
					end

					local logOrder = {"TRACE", "DEBUG", "INFO", "WARN", "ERROR"};
					for _, key in ipairs(logOrder) do
						local value = SC.Globals.LogLevels[key];
						root:CreateRadio(key, function() return SC.Globals.log_level == value; end, function()
							SC.Globals.log_level = value;
							SC.Database:SetGlobalSetting("DebugLevel", value);
						end, value);
					end
				end);
			end
		end
	end

	SC.ElvUI.RegisterSkinnableElement(infoInset, "inset");

	return infoInset;
end

SC.SettingsElements = SettingsElements;
