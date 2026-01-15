-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local L = SIPPYCUP.L;

if not C_AddOns.IsAddOnLoaded('totalRP3') then
	return;
end

local function onStart()
	TRP3_API.RegisterCallback(TRP3_Addon, TRP3_Addon.Events.WORKFLOW_ON_LOADED, function()
        if not TRP3_API.toolbar then
            return;
        end

		TRP3_API.toolbar.toolbarAddButton{
			id = "trp3_sippy_cup",
			icon = SIPPYCUP.AddonMetadata.iconTexture,
			configText = SIPPYCUP.AddonMetadata.title,
            tooltip = SIPPYCUP.AddonMetadata.title,
			tooltipSub = L.ADDON_COMPARTMENT_DESC,
			onClick = function(_, _, button)
				if button == "LeftButton" then
					SIPPYCUP_Addon:OpenSettings();
				elseif button == "RightButton" then
					SIPPYCUP_Addon:OpenSettings(8);
				end
			end,
		}
	end)
end

-- Module Registration
TRP3_API.module.registerModule({
    ["name"] = "Sippy Cup",
    ["description"] = "Adds a toolbar button to open Sippy Cup easily.",
    ["version"] = SIPPYCUP.AddonMetadata.version,
    ["id"] = "trp_sippy_cup",
    ["onStart"] = onStart,
    ["minVersion"] = 3,
})
