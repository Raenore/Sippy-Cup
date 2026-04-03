-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

---@class SippyCupMinimap
local Minimap = {};

local L = SC.Localization;

local LibDataBroker = LibStub:GetLibrary("LibDataBroker-1.1");
local LibDBCompartment = LibStub:GetLibrary("LibDBCompartment-1.0");
local LibDBIcon = LibStub:GetLibrary("LibDBIcon-1.0");

local function OnClick(self, button)
	if button == "LeftButton" then
		SC.Settings:ShowSettings();
	elseif button == "RightButton" then
		SC.Settings:ShowSettings(8);
	end
end

local function OnTooltipShow(tooltip)
	tooltip:AddDoubleLine(SC.Globals.addon_title, SC.Globals.addon_version, nil, nil, nil, 1, 1, 1);
	tooltip:AddLine(L.ADDON_COMPARTMENT_DESC);
end

---SetupMinimapButtons initializes and registers the addon's minimap and compartment buttons.
---@return nil
function Minimap:SetupMinimapButtons()
	local ldb = LibDataBroker:NewDataObject(SC.Globals.addon_title, {
		type = "launcher",
		icon = SC.Globals.addon_icon_texture,
		tocname = SC.Globals.addon_title,
		OnClick = OnClick,
		OnTooltipShow = OnTooltipShow,
	});

	local minimapSettings = SC.Database:GetGlobalSetting("MinimapButton");
	LibDBIcon:Register(SC.Globals.addon_title, ldb, minimapSettings);
	LibDBCompartment:Register(SC.Globals.addon_title, ldb);

	self:UpdateMinimapButtons();
end

---UpdateMinimapButtons toggles visibility of minimap-related buttons based on addon settings.
---@return nil
function Minimap:UpdateMinimapButtons()
	local minimapSettings = SC.Database:GetGlobalSetting("MinimapButton");
	if minimapSettings and not minimapSettings.Hide then
		LibDBCompartment:SetShown(SC.Globals.addon_title, minimapSettings.ShowAddonCompartmentButton);
		LibDBIcon:Refresh(SC.Globals.addon_title);
	else
		LibDBCompartment:Hide(SC.Globals.addon_title);
		LibDBIcon:Hide(SC.Globals.addon_title);
	end
end

SC.Minimap = Minimap;
