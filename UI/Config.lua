-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local L = SIPPYCUP.L;
local SharedMedia = LibStub("LibSharedMedia-3.0");
SIPPYCUP.Config = {};

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
}

-- Register default sounds
for _, sound in ipairs(defaultSounds) do
	SharedMedia:Register("sound", sound.key, sound.fid)
end

-- Build soundList with keys = values for quick lookup/use
local soundList = {}
for _, soundName in ipairs(SharedMedia:List("sound")) do
	soundList[soundName] = soundName
end

function SIPPYCUP.Config.TryCreateConfigFrame()
	if not SIPPYCUP.configFrame then
		SIPPYCUP.configFrame = CreateFrame("Frame", "SIPPYCUP_ConfigMenuFrame", UIParent, "SIPPYCUP_ConfigMenuTemplate");
	end
end

---AddTab creates a new tab button under the given parent frame and adds it to the parent's Tabs list.
---It positions the new tab relative to existing tabs, sets up its scripts for show and click events, and registers it for ElvUI skinning.
---@param parent table Frame containing the Tabs table and the SetTab function.
---@return table tab The created tab button frame.
local function AddTab(parent)
	local tabs = parent.Tabs;
	local tab = CreateFrame("Button", nil, parent, "SIPPYCUP_ConfigMenuTabTopTemplate");

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

	local function OnShow(self)
		PanelTemplates_TabResize(self, 15, nil, 65);
		PanelTemplates_DeselectTab(self);
	end

	local function OnClick()
		parent:SetTab(tabIndex);
	end

	tab:SetScript("OnShow", OnShow);
	tab:SetScript("OnClick", OnClick);

	SIPPYCUP.ElvUI.RegisterSkinnableElement(tab, "toptapbutton");

	return tab;
end

---GetScrollableWrapperFrame creates a scrollable content frame within the parent frame.
---It wires mousewheel support and adds a scroll frame with consistent padding and clamped scrolling logic.
---@param parent table The parent frame to contain the scrollable wrapper. Must have a `Views` table.
---@return table contentFrame The scrollable content frame with scrollFrame reference and isScrollable flag.
local function GetWrapperFrame(parent)
	local frame = CreateFrame("Frame", nil, parent);
	frame:SetPoint("TOP", 0, -55);
	frame:SetPoint("LEFT");
	frame:SetPoint("RIGHT");
	frame:SetPoint("BOTTOM");
	frame:Hide();

	frame.isScrollable = false;
	frame.scrollFrame = nil;

	parent.Views[#parent.Views + 1] = frame;

	return frame;
end

---GetScrollableWrapperFrame creates a scrollable content frame within the parent frame.
---It wires mousewheel support and adds a scroll frame with consistent padding and clamped scrolling logic.
---@param parent table The parent frame to contain the scrollable wrapper. Must have a Views table.
---@return table The scrollable content frame, with a reference to its scrollFrame and isScrollable flag.
local function GetScrollableWrapperFrame(parent)
	local paddingLeft, paddingRight, paddingTop, paddingBottom = 0, 25, 55, 16;

	local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate");
	scrollFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", paddingLeft, -paddingTop);
	scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -paddingRight, paddingBottom);
	scrollFrame:EnableMouse(true);
	scrollFrame:EnableMouseWheel(true);
	scrollFrame:Hide();

	local function HandleScroll(self, delta)
		local newScroll = self:GetVerticalScroll() - (delta * 30);
		local minScroll, maxScroll = 0, self:GetVerticalScrollRange();

		-- Use math.min/max for concise clamping.
		self:SetVerticalScroll(math.max(minScroll, math.min(newScroll, maxScroll)));
	end

	scrollFrame:SetScript("OnMouseWheel", HandleScroll);

	local contentFrame = CreateFrame("Frame", nil, scrollFrame);
	contentFrame:SetSize(scrollFrame:GetWidth(), 500);
	contentFrame:SetPoint("TOPLEFT");
	contentFrame:SetPoint("TOPRIGHT");
	contentFrame:EnableMouse(true);
	contentFrame:EnableMouseWheel(true);
	contentFrame:SetScript("OnMouseWheel", function(self, delta)
		HandleScroll(self:GetParent(), delta);
	end);

	scrollFrame:SetScrollChild(contentFrame);
	contentFrame:Hide();

	if scrollFrame.ScrollBar then
		scrollFrame.ScrollBar:Hide();
	end

	contentFrame.scrollFrame = scrollFrame;
	contentFrame.isScrollable = true;

	SIPPYCUP.ElvUI.RegisterSkinnableElement(scrollFrame.ScrollBar, "scrollbar");
	parent.Views[#parent.Views + 1] = contentFrame;

	return contentFrame;
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

---UpdateScrollableContentHeight adjusts the height of the content frame based on its children's lowest point,
---adding padding, and shows/hides the scrollbar accordingly.
---@param contentFrame table The scrollable content frame that contains a reference to its scrollFrame.
local function UpdateScrollableContentHeight(contentFrame)
	local scrollFrame = contentFrame.scrollFrame;
	if not scrollFrame then return; end

	local visibleHeight = scrollFrame:GetHeight();
	local parentTop = contentFrame:GetTop();
	local parentBottom = GetLowestChildBottomIncludingFontStrings(contentFrame);
	if not parentBottom then return; end

	local relativeBottom = parentTop - parentBottom; -- height of content
	local padding = 20; -- extra scroll padding
	local requiredHeight = relativeBottom + padding;

	-- Math.max to prevent zero/negative height.
	contentFrame:SetHeight(math.max(requiredHeight, 1));

	contentFrame:SetHeight(requiredHeight);

	local scrollbar = scrollFrame.ScrollBar;
	if scrollbar then
		local shouldShow = requiredHeight > visibleHeight;
		if scrollbar:IsShown() ~= shouldShow then
			scrollbar:SetShown(shouldShow);
		end
	end
end

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

	local tooltipTitle = title;

	local function OnEnter(self)
		GameTooltip:SetOwner(firstFrame or frames, anchor);
		GameTooltip:SetText(tooltipTitle, WHITE_FONT_COLOR:GetRGB());
		GameTooltip:AddLine(description, nil, nil, nil, true);
		SIPPYCUP.ElvUI.SkinTooltip(GameTooltip);
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
---@param itemID number The item ID to create the tooltip for.
---@param anchor string? Optional anchor point for tooltip, defaults to "ANCHOR_TOP".
local function AttachItemTooltip(frames, itemID, anchor)
	if not itemID then return; end
	anchor = anchor or "ANCHOR_TOP";

	local isList = type(frames) == "table" and not frames.GetObjectType;
	local firstFrame = isList and frames[1] or frames;
	if not firstFrame then return; end

	local item = Item:CreateFromItemID(itemID);

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

local function WrapButtonClick(original)
	return function(self, ...)
		original(self, ...);
		if SIPPYCUP.configFrame then
			RunNextFrame(function()
				SIPPYCUP_ConfigMenuFrame:RefreshWidgets();
			end);
		end
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

	if isSlider then
		local color = disabled and GRAY_FONT_COLOR or WHITE_FONT_COLOR;
		local r, g, b = color:GetRGB();
		widget.RightText:SetVertexColor(r, g, b);
		widget.MinText:SetVertexColor(r, g, b);
		widget.MaxText:SetVertexColor(r, g, b);
	end
end

---CreateTitleWithDescription creates title and description font strings under the parent frame.
---If optionsPage is true, it appends extra localized text to the description and adds legenda buttons with tooltips.
---@param parent table The parent frame to attach the texts and buttons to.
---@param titleText string? The text for the title font string.
---@param descText string? The text for the description font string.
---@param optionsPage boolean? Whether to append extra text and create legenda buttons.
---@return FontString title The created title font string.
---@return FontString description The created description font string.
local function CreateTitleWithDescription(parent, titleText, descText, optionsPage)
	local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
	title:SetPoint("TOPLEFT", 20, -16);
	title:SetText(titleText or "");

	if optionsPage then
		descText = (descText or "") .. L.OPTIONS_TITLE_EXTRA;
	end

	local description = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8);
	description:SetWidth(parent:GetWidth() - 32);
	description:SetJustifyH("LEFT");
	description:SetText(descText or "");

	-- Add the legenda
	if optionsPage then
		local function CreateLegendaButton(icon, pointTo, tooltipName, tooltipDesc)
			local btn = CreateFrame("Button", nil, parent, "UIPanelDynamicResizeButtonTemplate");
			btn:SetText("|A:" .. icon .. ":16:16|a");
			btn:SetWidth(30);
			btn:SetPoint("TOPLEFT", pointTo, "TOPRIGHT", 5, 0);
			SIPPYCUP.ElvUI.RegisterSkinnableElement(btn, "button");
			AttachTooltip(btn, tooltipName, tooltipDesc);
			return btn;
		end

		local preExpirationButton = CreateFrame("Button", nil, parent, "UIPanelDynamicResizeButtonTemplate");
		preExpirationButton:SetText("|A:uitools-icon-refresh:16:16|a");
		preExpirationButton:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -10);
		preExpirationButton:SetWidth(30);
		SIPPYCUP.ElvUI.RegisterSkinnableElement(preExpirationButton, "button");
		AttachTooltip(preExpirationButton, L.OPTIONS_LEGENDA_PRE_EXPIRATION_NAME, L.OPTIONS_LEGENDA_PRE_EXPIRATION_DESC);

		local nonRefreshableButton = CreateLegendaButton("uitools-icon-close", preExpirationButton, L.OPTIONS_LEGENDA_NON_REFRESHABLE_NAME, L.OPTIONS_LEGENDA_NON_REFRESHABLE_DESC);
		local stacksButton = CreateLegendaButton("uitools-icon-plus", nonRefreshableButton, L.OPTIONS_LEGENDA_STACKS_NAME, L.OPTIONS_LEGENDA_STACKS_DESC);
		local noAuraButton = CreateLegendaButton("uitools-icon-minus", stacksButton, L.OPTIONS_LEGENDA_NO_AURA_NAME, L.OPTIONS_LEGENDA_NO_AURA_DESC); -- luacheck: no unused (noAuraButton)
	end

	return title, description;
end

---CreateInset creates a skinnable inset frame inside the parent with provided widget data.
---Positions the inset relative to the parent's top and optionally offset by topOffset.
---Creates various UI elements (logo, title, version, build, author, bsky) based on insetData entries and attaches tooltips.
---@param parent table The parent frame to attach the inset frame to.
---@param insetData table List of widget data entries describing the inset contents.
---@param topOffset number? Optional vertical offset from the parent's top (negative or positive).
---@return Frame infoInset The created inset frame containing the widgets.
local function CreateInset(parent, insetData, topOffset)
	local ElvUI = SIPPYCUP.ElvUI;

	local parentTop = parent:GetTop();
	local parentBottom = GetLowestChildBottomIncludingFontStrings(parent);
	local relativeBottom = parentTop - parentBottom;

	-- Normalize topOffset to negative offset (20px default)
	if not topOffset then
		topOffset = -20;
	elseif topOffset > 0 then
		topOffset = -topOffset;
	end

	local startY = -relativeBottom + topOffset; -- relative Y from parent's TOP for the new widgets

	local infoInset = CreateFrame("Frame", nil, parent, "InsetFrameTemplate");
	ElvUI.RegisterSkinnableElement(infoInset, "inset");

	infoInset:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, startY);
	infoInset:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -20, startY);
	infoInset:SetHeight(75);

	local logo, title, author, version, build, bsky;

	-- Loop through each entry in widgetData to create widgets with labels and optional tooltips
	for _, data in ipairs(insetData) do
		local entryType = data.type or "logo";

		if entryType == "logo" then
			logo = infoInset:CreateTexture(nil, "ARTWORK");
			logo:SetTexture(SIPPYCUP.AddonMetadata.iconTexture);
			logo:SetSize(52, 52);
			logo:SetPoint("LEFT", 8, 0);
			ElvUI.RegisterSkinnableElement(logo, "icon");

			AttachTooltip(logo, SIPPYCUP.AddonMetadata.title, "Sluuuuuuuurp..");
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
			ElvUI.RegisterSkinnableElement(build, "button");

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
			ElvUI.RegisterSkinnableElement(bsky, "button");

			AttachTooltip(bsky, data.text or "", data.tooltip or "");

			bsky:SetScript("OnClick", function()
				SIPPYCUP.LinkDialog.CreateExternalLinkDialog("https://bsky.app/profile/dawnsong.me");
			end);
		end
	end

	return infoInset;
end

---CreateConfigBlank creates an invisible placeholder frame of the same size as the container.
---Used to occupy space without displaying any content.
---@param elementContainer table The parent frame to contain the blank widget.
---@param data table Data associated with the placeholder.
---@return Frame widget The created blank frame widget.
local function CreateConfigBlank(elementContainer, data)
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
local function CreateConfigButton(elementContainer, data)
	local widget = CreateFrame("Button", nil, elementContainer, "UIPanelButtonTemplate");
	local label = data.label or "Button";

	widget:SetText(label);
	widget:SetAllPoints(elementContainer);
	widget.data = data;

	widget:SetMotionScriptsWhileDisabled(true);

	ApplyDisabledState(widget, data.disabled);

	if type(data.func) == "function" then
		widget:SetScript("OnClick", WrapButtonClick(data.func));
	end

	if data.tooltip then
		ApplyTooltip(widget, label, data.tooltip);
	end

	SIPPYCUP.ElvUI.RegisterSkinnableElement(widget, "button");

	return widget;
end

---CreateConfigCheckBox creates a checkbox with optional icon, label, disabled state, and tooltip, inside the given container.
---@param elementContainer table The parent frame to hold the checkbox.
---@param data table Configuration data including label, icon, style, get/set functions, disabled function, tooltip, and flags.
---@return CheckButton widget The created checkbox widget.
local function CreateConfigCheckBox(elementContainer, data)
	local widget = CreateFrame("CheckButton", nil, elementContainer, "SettingsCheckBoxTemplate");
	local size = elementContainer:GetHeight();
	widget:SetSize(size, size);
	widget:SetPoint("LEFT", 0, 0);
	widget.data = data;

	-- Icon and label setup
	local labelText = data.label or "";
	local icon;

	if data.style == "consumable" then
		icon = elementContainer:CreateTexture(nil, "ARTWORK");
		icon:SetTexture(data.icon);
		icon:SetSize(size, size);
		icon:SetPoint("LEFT", widget, "RIGHT", 5, 0);
		SIPPYCUP.ElvUI.RegisterSkinnableElement(icon, "icon");

		local addition = "";
		if data.preExpiration or data.unrefreshable or data.nonAura or data.stacks then
			addition = " (";
			if data.preExpiration then addition = addition .. "|A:uitools-icon-refresh:16:16|a"; end
			if data.unrefreshable then addition = addition .. "|A:uitools-icon-close:16:16|a"; end
			if data.stacks then addition = addition .. "|A:uitools-icon-plus:16:16|a"; end
			if data.nonAura then addition = addition .. "|A:uitools-icon-minus:16:16|a"; end
			addition = addition .. ")";
		end
		labelText = labelText .. addition;
	end

	local label = widget:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	if icon then
		label:SetPoint("LEFT", icon, "RIGHT", 5, 0);
	else
		label:SetPoint("LEFT", widget, "RIGHT", 5, 0);
	end
	label:SetText(labelText);

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
				if SIPPYCUP.configFrame then
					SIPPYCUP_ConfigMenuFrame:RefreshWidgets();
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

	if data.tooltip or data.style == "consumable" then
		if data.style == "consumable" then
			AttachItemTooltip({label, elementContainer, icon, widget}, data.itemID);
		else
			ApplyTooltip({label, elementContainer, widget}, data.label, data.tooltip, data.style);
		end
	end

	SIPPYCUP.ElvUI.RegisterSkinnableElement(widget, "checkbox");

	return widget;
end

---CreateConfigDescription creates a font string within the container, showing static or dynamic text with styling.
---@param elementContainer table The parent frame to hold the description.
---@param data table Configuration data containing the text or a function returning the text.
---@return FontString widget The created font string widget.
local function CreateConfigDescription(elementContainer, data)
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

	SIPPYCUP.ElvUI.RegisterSkinnableElement(widget, "description");

	return widget;
end

---CreateConfigDropdown creates a dropdown widget inside the container with configurable options and behavior.
---@param elementContainer table The parent frame to hold the dropdown.
---@param data table Configuration data including label, values, get/set callbacks, style, tooltip, and sorting.
---@return Frame widget The created dropdown widget.
local function CreateConfigDropdown(elementContainer, data)
	local widget = CreateFrame("DropdownButton", nil, elementContainer, "WowStyle1DropdownTemplate");
	widget:SetPoint("TOPLEFT", elementContainer, "TOPLEFT", 0, 2); -- 2 more height to fit whole container
	widget:SetPoint("BOTTOMRIGHT", elementContainer, "BOTTOMRIGHT", 0, -2); -- 2 more height to fit whole container
	widget.data = data;

	widget:SetMotionScriptsWhileDisabled(true);

	ApplyDisabledState(widget, data.disabled);

	local labelText = type(data.label) == "function" and data.label() or data.label;

	if data.style == "button" and widget.Text then
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
			if SIPPYCUP.configFrame then
				SIPPYCUP_ConfigMenuFrame:RefreshWidgets();
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

		if #sorting > 0 then
			for _, key in ipairs(sorting) do
				if values[key] then
					table.insert(entries, {values[key], key});
				end
			end
		else
			local temp = {};
			for key, label in pairs(values) do
				table.insert(temp, {key = key, label = label});
			end
			table.sort(temp, function(a, b) return a.label < b.label end);
			for _, item in ipairs(temp) do
				table.insert(entries, {item.label, item.key});
			end
		end

		for _, entry in ipairs(entries) do
			local label, value = entry[1], entry[2];
			if data.style == "button" then
				root:CreateButton(label, SetSelected, value);
			else
				root:CreateRadio(label, IsSelected, SetSelected, value);
			end
		end

		if data.style == "button" then
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

	SIPPYCUP.ElvUI.RegisterSkinnableElement(widget, "dropdown");

	return widget;
end

---CreateConfigEditBox creates an edit box widget with optional get/set callbacks and tooltip.
---@param elementContainer table The parent frame to contain the edit box.
---@param data table Configuration including label, get/set functions, and tooltip.
---@return Frame widget The created edit box widget.
local function CreateConfigEditBox(elementContainer, data)
	local widget = CreateFrame("EditBox", nil, elementContainer, "InputBoxTemplate");
	widget:SetAutoFocus(false);
	widget:SetPoint("TOPLEFT", elementContainer, "TOPLEFT", 0, 0);
	widget:SetPoint("BOTTOMRIGHT", elementContainer, "BOTTOMRIGHT", 0, 0);
	widget.data = data;

	if type(data.get) == "function" and type(data.set) == "function" then
		widget:SetScript("OnEnterPressed", function(self)
			data.set(self:GetText());
			self:SetText(""); -- Intentionally clear after submission
			self:ClearFocus();
			if SIPPYCUP.configFrame then
				SIPPYCUP_ConfigMenuFrame:RefreshWidgets();
			end
		end);
	end

	widget:SetScript("OnEscapePressed", function(self)
		self:ClearFocus();
	end);

	widget:SetScript("OnEditFocusGained", function(self)
		self:HighlightText();
	end);

	if data.tooltip then
		ApplyTooltip(widget, data.label, data.tooltip);
	end

	SIPPYCUP.ElvUI.RegisterSkinnableElement(widget, "editbox");

	return widget;
end

---CreateConfigSlider creates a slider widget with optional get/set callbacks, step rounding, and tooltip.
---@param elementContainer table The parent frame to contain the slider.
---@param data table Configuration including min, max, step, label, get/set functions, disabled state, and tooltip.
---@return Frame widget The created slider widget.
local function CreateConfigSlider(elementContainer, data)
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

	widget.MinText:SetText(minVal);
	widget.MinText:SetVertexColor(r, g, b);

	widget.MaxText:SetText(maxVal);
	widget.MaxText:SetVertexColor(r, g, b);

	widget.RightText:SetVertexColor(r, g, b);

	widget.MinText:Show();
	widget.MaxText:Show();
	widget.RightText:Show();

	widget:SetPoint("LEFT", 0, 0);
	widget:SetWidth(elementContainer:GetWidth() * 0.8);
	widget:SetHeight(41);

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
				if SIPPYCUP.configFrame then
					SIPPYCUP_ConfigMenuFrame:RefreshWidgets();
				end
			end
		end);
	end

	if data.tooltip then
		ApplyTooltip({widget.Slider, widget.Back, widget.Forward, widget, elementContainer}, data.label, data.tooltip);
	end

	SIPPYCUP.ElvUI.RegisterSkinnableElement(widget, "slider");

	return widget;
end

---CreateWidgetRowContainer arranges multiple widgets in rows within a parent frame.
---@param parent Frame The parent frame to hold widgets.
---@param widgetData table List of widget data tables describing each widget.
---@param widgetsPerRow number? Number of widgets per row (default 3).
---@param rowSpacing number? Vertical spacing between rows (default 20).
---@param topOffset number? Vertical offset from bottom of parent's lowest child (default 20).
---@return table widgets List of created widget frames.
local function CreateWidgetRowContainer(parent, widgetData, widgetsPerRow, rowSpacing, topOffset)
	local parentTop = parent:GetTop();
	local parentBottom = GetLowestChildBottomIncludingFontStrings(parent);
	local relativeBottom = parentTop - parentBottom;

	topOffset = -(math.abs(topOffset or 20)); -- 20px below last child
	local startY = -relativeBottom + topOffset; -- relative Y from parent's TOP for the new widgets

	widgetsPerRow = widgetsPerRow or 3;
	rowSpacing = rowSpacing or 20; -- fixed vertical spacing between rows

	local widgetSpacing = 20; -- horizontal spacing between widgets
	local leftPadding, rightPadding = 35, 35;
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
			button      = CreateConfigButton,
			checkbox    = CreateConfigCheckBox,
			description = CreateConfigDescription,
			dropdown    = CreateConfigDropdown,
			editbox     = CreateConfigEditBox,
			blank       = CreateConfigBlank,
			slider      = CreateConfigSlider,
		};

		local createFunc = factory[widgetType];
		if createFunc then
			local widget = createFunc(elementContainer, data);
			tinsert(widgets, widget);
		end
	end

	return widgets;
end

---CreateCategoryHeader adds a centered header with decorative horizontal lines.
---@param parent Frame The parent frame to contain the header.
---@param titleText string The text to display in the header.
---@param topOffset number? Vertical offset from the bottom of the lowest child (default 20).
---@return Frame container The frame holding the header and lines.
local function CreateCategoryHeader(parent, titleText, topOffset)
	local parentTop = parent:GetTop();
	local parentBottom = GetLowestChildBottomIncludingFontStrings(parent);
	local relativeBottom = parentTop - parentBottom;

	topOffset = -(math.abs(topOffset or 20)); -- 20px below last child
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

SIPPYCUP_ConfigMixin = {};

---SetTab shows the selected configuration tab and hides others.
---@param index number The index of the tab to activate.
function SIPPYCUP_ConfigMixin:SetTab(index)
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
end

---SwitchProfileValues updates all profile-bound widgets with current values.
---Ensures each widget reflects its getter's value and applies corresponding set or disabled logic.
function SIPPYCUP_ConfigMixin:SwitchProfileValues()
	if not self.profileWidgets then return; end

	local grayR, grayG, grayB = GRAY_FONT_COLOR:GetRGB();
	local whiteR, whiteG, whiteB = WHITE_FONT_COLOR:GetRGB();

	for _, widgetList in ipairs(self.profileWidgets) do
		for _, widget in ipairs(widgetList) do
			local data = widget.data;
			if data and type(data.get) == "function" then
				local value = data.get();
				local hasSet = type(data.set) == "function";

				if widget.SetChecked and widget.GetChecked then
					local oldVal = widget:GetChecked();
					if oldVal ~= value then
						widget:SetChecked(value);
					end
					if hasSet then
						data.set(value);
					end

				elseif widget.SetValue and widget.GetValue then
					local oldVal = widget:GetValue();
					if oldVal ~= value then
						widget:SetValue(value);
						if widget.Text then
							widget.Text:SetText(string.format("%s: %d", data.label or "", math.floor(value + 0.5)));
						end
					end

					if hasSet then
						data.set(value);
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
function SIPPYCUP_ConfigMixin:RefreshWidgets()
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
	local locA = L["OPTIONS_CONSUMABLE_" .. string.upper(a) .. "_TITLE"] or "";
	local locB = L["OPTIONS_CONSUMABLE_" .. string.upper(b) .. "_TITLE"] or "";

	-- Normalize and lowercase for case-insensitive comparison
	return SIPPYCUP_TEXT.Normalize(locA:lower()) < SIPPYCUP_TEXT.Normalize(locB:lower());
end);

function SIPPYCUP_ConfigMixin:OnLoad()
	ButtonFrameTemplate_HidePortrait(self);
	ButtonFrameTemplate_HideButtonBar(self);
	tinsert(UISpecialFrames, self:GetName());

	self.Inset:Hide();

	-- Hide scrollbar if it exists
	if self.ScrollFrame and self.ScrollFrame.ScrollBar then
		self.ScrollFrame.ScrollBar:Hide();
	end

	self:SetTitle(SIPPYCUP.AddonMetadata.title .. " " .. MAIN_MENU);

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

	-- Hide any scrollbar directly attached to self, if exists
	if self.ScrollFrame and self.ScrollFrame.ScrollBar then
		self.ScrollFrame.ScrollBar:Hide();
	elseif self.ScrollBar then
		self.ScrollBar:Hide();
	end

	-- Create tabs and their panels
	local generalTab = AddTab(self);
	generalTab:SetText(L.OPTIONS_GENERAL_HEADER);
	self.TabsByName["GENERAL"] = generalTab;
	local generalPanel = GetWrapperFrame(self);

	for _, category in ipairs(categories) do
		local categoryTab = AddTab(self);
		categoryTab:SetText(category);
		self.TabsByName[string.upper(category)] = categoryTab;
		local categoryPanel = GetScrollableWrapperFrame(self);
		self.PanelsByName[string.upper(category)] = categoryPanel;
	end

	local profilesTab = AddTab(self);
	profilesTab:SetText(L.OPTIONS_PROFILES_HEADER);
	self.TabsByName["PROFILES"] = profilesTab;
	local profilesPanel = GetWrapperFrame(self);

	PanelTemplates_SetNumTabs(self, #self.Tabs);

	-- Test content for General tab
	CreateTitleWithDescription(generalPanel, L.OPTIONS_GENERAL_HEADER, SIPPYCUP.AddonMetadata.notes);

	local generalCheckboxData = {
		{
			type = "checkbox",
			label = L.OPTIONS_GENERAL_WELCOME_NAME,
			tooltip = L.OPTIONS_GENERAL_WELCOME_DESC,
			get = function()
				-- return SIPPYCUP.db.global.WelcomeMessage;
				return SIPPYCUP.Database.GetSetting("global", "WelcomeMessage", nil);
			end,
			set = function(val)
				SIPPYCUP.Database.UpdateSetting("global", "WelcomeMessage", nil, val);
			end,
		},
		{
			type = "checkbox",
			label = L.OPTIONS_GENERAL_MINIMAPBUTTON_NAME,
			tooltip = L.OPTIONS_GENERAL_MINIMAPBUTTON_DESC,
			get = function()
				return not SIPPYCUP.Database.GetSetting("global", "MinimapButton", "Hide");
			end,
			set = function(val)
				-- Update with inversion: save 'Hide' as NOT val
				SIPPYCUP.Database.UpdateSetting("global", "MinimapButton", "Hide", not val);
				SIPPYCUP.Minimap:UpdateMinimapButtons();
			end,
		},
		{
			type = "checkbox",
			label = L.OPTIONS_GENERAL_ADDONCOMPARTMENT_NAME,
			tooltip = L.OPTIONS_GENERAL_ADDONCOMPARTMENT_DESC,
			get = function()
				return SIPPYCUP.Database.GetSetting("global", "MinimapButton", "ShowAddonCompartmentButton") or false;
			end,
			set = function(val)
				SIPPYCUP.Database.UpdateSetting("global", "MinimapButton", "ShowAddonCompartmentButton", val);
				SIPPYCUP.Minimap:UpdateMinimapButtons();
			end,
		},
	};

	-- Initialize an empty table to hold all checkbox lists
	self.allWidgets = self.allWidgets or {};
	self.profileWidgets = self.profileWidgets or {};

	self.allWidgets[#self.allWidgets + 1] = CreateWidgetRowContainer(generalPanel, generalCheckboxData);

	CreateCategoryHeader(generalPanel, L.OPTIONS_GENERAL_POPUPS_HEADER);

	local reminderCheckboxData = {
		{
			type = "checkbox",
			label = L.OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE,
			tooltip = L.OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE_DESC,
			get = function()
				return SIPPYCUP.Database.GetSetting("global", "PreExpirationChecks", nil);
			end,
			set = function(val)
				SIPPYCUP.Database.UpdateSetting("global", "PreExpirationChecks", nil, val);
				if not val then
					SIPPYCUP.Auras.CancelAllPreExpirationTimers();
					SIPPYCUP.Items.CancelAllItemTimers(2);
				end
			end,
		},
		{
			type = "checkbox",
			label = L.OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE,
			tooltip = L.OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE_DESC,
			get = function()
				return SIPPYCUP.Database.GetSetting("global", "InsufficientReminder", nil);
			end,
			set = function(val)
				SIPPYCUP.Database.UpdateSetting("global", "InsufficientReminder", nil, val);
			end,
		},
		{
			type = "button",
			label = L.OPTIONS_GENERAL_POPUPS_IGNORES,
			tooltip = L.OPTIONS_GENERAL_POPUPS_IGNORES_TEXT,
			disabled = function()
				return SIPPYCUP.Popups.IsEmpty();
			end,
			func = function()
				SIPPYCUP.Popups.ResetIgnored();
			end,
		},
	};

	self.allWidgets[#self.allWidgets + 1] = CreateWidgetRowContainer(generalPanel, reminderCheckboxData);

	local positionWidgetData = {
		{
			type = "dropdown",
			label = L.OPTIONS_GENERAL_POPUPS_POSITION_NAME,
			tooltip = L.OPTIONS_GENERAL_POPUPS_POSITION_DESC,
			values = {
				["TOP"] = "Top (Default)",
				["CENTER"] = "Center",
				["BOTTOM"] = "Bottom",
			},
			sorting = {
				"TOP",
				"CENTER",
				"BOTTOM",
			},
			get = function()
				return SIPPYCUP.Database.GetSetting("global", "PopupPosition", nil);
			end,
			set = function(val)
				SIPPYCUP.Database.UpdateSetting("global", "PopupPosition", nil, val);
			end,
		},
	}

	self.allWidgets[#self.allWidgets + 1] = CreateWidgetRowContainer(generalPanel, positionWidgetData);

	local alertWidgetData = {
		{
			type = "checkbox",
			label = BINDING_NAME_TOGGLESOUND,
			tooltip = L.OPTIONS_GENERAL_POPUPS_SOUND_ENABLE_DESC,
			get = function()
				return SIPPYCUP.Database.GetSetting("global", "AlertSound", nil);
			end,
			set = function(val)
				SIPPYCUP.Database.UpdateSetting("global", "AlertSound", nil, val);
			end,
		},
		{
			type = "dropdown",
			label = SOUND,
			tooltip = L.OPTIONS_GENERAL_POPUPS_ALERT_SOUND_DESC,
			align = "right",
			values = soundList,
			disabled = function()
				return not SIPPYCUP.Database.GetSetting("global", "AlertSound", nil);
			end,
			get = function()
				return SIPPYCUP.Database.GetSetting("global", "AlertSoundID", nil);
			end,
			set = function(val)
				local soundPath = SharedMedia:Fetch("sound", val);
				if soundPath then
					PlaySoundFile(soundPath, "Master");
					SIPPYCUP.Database.UpdateSetting("global", "AlertSoundID", nil, val);
				end
			end,
		},
		{
			type = "blank",
		},
		{
			type = "checkbox",
			label = L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE,
			tooltip = L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE_DESC,
			get = function()
				return SIPPYCUP.Database.GetSetting("global", "FlashTaskbar", nil);
			end,
			set = function(val)
				SIPPYCUP.Database.UpdateSetting("global", "FlashTaskbar", nil, val);
			end,
		},
	}

	self.allWidgets[#self.allWidgets + 1] = CreateWidgetRowContainer(generalPanel, alertWidgetData);

	CreateCategoryHeader(generalPanel, L.OPTIONS_GENERAL_ADDONINTEGRATIONS_HEADER);

	local integrationsWidgetData = {
		{
			type = "checkbox",
			label = L.OPTIONS_GENERAL_MSP_STATUSCHECK_ENABLE,
			tooltip = L.OPTIONS_GENERAL_MSP_STATUSCHECK_DESC,
			disabled = function()
				return not SIPPYCUP.MSP.IsEnabled();
			end,
			get = function()
				return SIPPYCUP.Database.GetSetting("global", "MSPStatusCheck", nil);
			end,
			set = function(val)
				SIPPYCUP.Database.UpdateSetting("global", "MSPStatusCheck", nil, val);
				SIPPYCUP.Player.OOC = SIPPYCUP_PLAYER.CheckOOCStatus();
				if val then
					SIPPYCUP.Consumables.RefreshStackSizes(val);
				else
					SIPPYCUP.Popups.HideAllRefreshPopups();
				end
			end,
		},
	}

	self.allWidgets[#self.allWidgets + 1] = CreateWidgetRowContainer(generalPanel, integrationsWidgetData);

	local insetData = {
		{
			type = "logo",
		},
		{
			type = "title",
			text = SIPPYCUP.AddonMetadata.title,
		},
		{
			type = "version",
			text = SIPPYCUP.AddonMetadata.version,
		},
		{
			type = "build",
			text = L.OPTIONS_GENERAL_ADDONINFO_BUILD:format(SIPPYCUP_BUILDINFO.Output(true)),
			tooltip = function()
				if SIPPYCUP_BUILDINFO.ValidateLatestBuild() then
					return L.OPTIONS_GENERAL_ADDONINFO_BUILD_CURRENT;
				else
					return L.OPTIONS_GENERAL_ADDONINFO_BUILD_OUTDATED;
				end
			end,
		},
		{
			type = "author",
			text = SIPPYCUP.AddonMetadata.author,
		},
		{
			type = "bsky",
			text = "Bluesky",
			tooltip = L.OPTIONS_GENERAL_BLUESKY_SHILL_DESC,
		},
	}

	self.allWidgets[#self.allWidgets + 1] = CreateInset(generalPanel, insetData);

	for _, category in ipairs(categories) do
		local categoryName = string.upper(category);
		local categoryPanel = self.PanelsByName[categoryName];

		local title = L["OPTIONS_CONSUMABLE_" .. categoryName .. "_TITLE"] or categoryName;
		local instruction = L["OPTIONS_CONSUMABLE_" .. categoryName .. "_INSTRUCTION"] or "";
		CreateTitleWithDescription(categoryPanel, title, instruction, true);

		local categoryData = {};

		for _, consumableData in ipairs(SIPPYCUP.Consumables.Data) do
			if consumableData.category == categoryName then
				local consumableAura = consumableData.auraID;
				local consumableName = consumableData.name;
				local consumableID = consumableData.itemID;
				local consumableIcon = consumableData.icon;

				local checkboxProfileKey = consumableAura;

				categoryData[#categoryData + 1] = {
					type = "checkbox",
					label = consumableName,
					icon = consumableIcon,
					style = "consumable",
					itemID = consumableID,
					preExpiration = consumableData.preExpiration,
					unrefreshable = consumableData.unrefreshable,
					nonAura = consumableData.itemTrackable or consumableData.spellTrackable,
					stacks = consumableData.stacks,
					get = function()
						return SIPPYCUP.Database.GetSetting("profile", checkboxProfileKey, "enable");
					end,
					set = function(val)
						SIPPYCUP.Database.UpdateSetting("profile", checkboxProfileKey, "enable", val);
						SIPPYCUP.Popups.Toggle(consumableName, consumableAura, val);
					end,
				};

				-- Slider: Desired stacks (if applicable)
				if consumableData.stacks then
					local sliderProfileKey = consumableAura;

					categoryData[#categoryData + 1] = {
						type = "slider",
						label = L.OPTIONS_DESIRED_STACKS,
						tooltip = L.OPTIONS_SLIDER_TEXT and L.OPTIONS_SLIDER_TEXT:format(consumableAura) or nil,
						min = 1,
						max = consumableData.maxStacks,
						step = 1,
						disabled = function()
							return not SIPPYCUP.Database.GetSetting("profile", sliderProfileKey, "enable");
						end,
						get = function()
							return SIPPYCUP.Database.GetSetting("profile", sliderProfileKey, "desiredStacks");
						end,
						set = function(val)
							SIPPYCUP.Database.UpdateSetting("profile", sliderProfileKey, "desiredStacks", val);
							if SIPPYCUP.profile[sliderProfileKey].enable then
								SIPPYCUP.Popups.Toggle(consumableName, consumableAura, true);
							end
						end,
					};
				end
			end
		end



		local widgets = CreateWidgetRowContainer(categoryPanel, categoryData, 2, 40)

		self.profileWidgets[#self.profileWidgets + 1] = widgets;
		self.allWidgets[#self.allWidgets + 1] = widgets;

		-- update scroll content height & scrollbar visibility
		UpdateScrollableContentHeight(categoryPanel);

		-- Optional if references are ever required:
		-- self.tabs[categoryName] = categoryTab;
		-- self.panels[categoryName] = categoryPanel;
	end

	CreateTitleWithDescription(profilesPanel, L.OPTIONS_PROFILES_HEADER, L.OPTIONS_PROFILES_INSTRUCTION);

	local profilesData = {
		{
			type = "description",
			name = function()
				return L.OPTIONS_PROFILES_CURRENTPROFILE:format("|cnNORMAL_FONT_COLOR:" .. SIPPYCUP.Database.GetCurrentProfileName() .. "|r");
			end,
		},
		{
			type = "dropdown",
			label = L.OPTIONS_PROFILES_EXISTINGPROFILES_NAME,
			tooltip = L.OPTIONS_PROFILES_EXISTINGPROFILES_DESC,
			style = "radio",
			values = function()
				return SIPPYCUP.Database.GetAllProfiles();
			end,
			get = function()
				return SIPPYCUP.Database.GetCurrentProfileName();
			end,
			set = function(val)
				SIPPYCUP.Database.SetProfile(val);
			end,
		},
		{
			type = "blank",
		},
		{
			type = "editbox",
			label = L.OPTIONS_PROFILES_NEWPROFILE_NAME,
			tooltip = L.OPTIONS_PROFILES_NEWPROFILE_DESC,
			get = function() end,
			set = function(val) SIPPYCUP.Database.CreateProfile(val) end,
		},
		{
			type = "dropdown",
			label = L.OPTIONS_PROFILES_COPYFROM_NAME,
			tooltip = L.OPTIONS_PROFILES_COPYFROM_DESC,
			style = "button",
			values = function()
				return SIPPYCUP.Database.GetAllProfiles(true, false);
			end,
			get = function() end,
			set = function(val)
				SIPPYCUP.Database.CopyProfile(val);
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
				SIPPYCUP.Database.ResetProfile();
			end,
		},
		{
			type = "dropdown",
			label = L.OPTIONS_PROFILES_DELETEPROFILE_NAME,
			tooltip = L.OPTIONS_PROFILES_DELETEPROFILE_DESC,
			style = "button",
			values = function()
				return SIPPYCUP.Database.GetAllProfiles(true, true);
			end,
			get = function() end,
			set = function(val)
				SIPPYCUP.Database.DeleteProfile(val);
			end,
		},
	};

	self.allWidgets[#self.allWidgets + 1] = CreateWidgetRowContainer(profilesPanel, profilesData, 3, 40);

	SIPPYCUP.ElvUI.RegisterSkinnableElement(self, "frame");
	SIPPYCUP.ElvUI.SkinRegisteredElements();
end

function SIPPYCUP_ConfigMixin:OnDragStart()
	self:StartMoving();
	self:SetUserPlaced(false);
end

function SIPPYCUP_ConfigMixin:OnDragStop()
	self:StopMovingOrSizing();
	self:SetUserPlaced(false);
end

function SIPPYCUP_ConfigMixin:OnShow()
	local totalWidth = 0;
	for _, tab in ipairs(self.Tabs) do
		PanelTemplates_TabResize(tab, 15, nil, 65);
		PanelTemplates_DeselectTab(tab);
		totalWidth = totalWidth + tab:GetWidth() + 5; -- 5px spacing between tabs
	end
	self:SetWidth(totalWidth + 0); -- padding

	self:RefreshWidgets();
	self:SetTab(1);  -- Show first tab by default
end
