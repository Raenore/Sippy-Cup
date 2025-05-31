-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local L = SIPPYCUP.L;
SIPPYCUP.Minimap = {};

local LibDataBroker = LibStub:GetLibrary("LibDataBroker-1.1");
local LibDBCompartment = LibStub:GetLibrary("LibDBCompartment-1.0");
local LibDBIcon = LibStub:GetLibrary("LibDBIcon-1.0");

local function OnClick(self, button)
	if button == "LeftButton" then
		if InterfaceOptionsFrame_OpenToCategory then
			InterfaceOptionsFrame_OpenToCategory(SIPPYCUP.AddonMetadata.title);
		else
			Settings.OpenToCategory(SIPPYCUP.AddonMetadata.title);
		end
	elseif button == "RightButton" then
		if InterfaceOptionsFrame_OpenToCategory then
			InterfaceOptionsFrame_OpenToCategory(SIPPYCUP.ProfilesFrame);
		else
			Settings.OpenToCategory(SIPPYCUP.ProfilesFrameID);
		end
	end
end

local function OnTooltipShow(tooltip)
	tooltip:AddDoubleLine(SIPPYCUP.AddonMetadata.title, SIPPYCUP.AddonMetadata.version, nil, nil, nil, 1, 1, 1);
	tooltip:AddLine(L.ADDON_COMPARTMENT_DESC);
end

---SetupMinimapButtons initializes and registers the addon’s minimap and compartment buttons.
---@return nil
function SIPPYCUP.Minimap:SetupMinimapButtons()
	local ldb = LibDataBroker:NewDataObject(SIPPYCUP.AddonMetadata.title, {
		type = "launcher",
		icon = SIPPYCUP.AddonMetadata.iconTexture,
		tocname = SIPPYCUP.AddonMetadata.title,
		OnClick = OnClick,
		OnTooltipShow = OnTooltipShow,
	});

	LibDBIcon:Register(SIPPYCUP.AddonMetadata.title, ldb, SIPPYCUP.db.global.MinimapButton);
	LibDBCompartment:Register(SIPPYCUP.AddonMetadata.title, ldb);

	self:UpdateMinimapButtons();
end

---UpdateMinimapButtons toggles visibility of minimap-related buttons based on addon settings.
---@return nil
function SIPPYCUP.Minimap:UpdateMinimapButtons()
	if SIPPYCUP.db.global.MinimapButton then
		LibDBCompartment:SetShown(SIPPYCUP.AddonMetadata.title, SIPPYCUP.db.global.MinimapButton.ShowAddonCompartmentButton);
		LibDBIcon:Refresh(SIPPYCUP.AddonMetadata.title);
	else
		LibDBCompartment:Hide(SIPPYCUP.AddonMetadata.title);
		LibDBIcon:Hide(SIPPYCUP.AddonMetadata.title);
	end
end
