-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.ElvUI = {};

local skinnableElements = {};

-- Cache ElvUI main object and modules when available to reduce repeated lookups
local ElvUI_E = nil;   -- ElvUI[1]
local SkinsModule = nil;
local TooltipModule = nil;

-- Utility to update caches safely
local function UpdateElvUICaches()
    ElvUI_E = ElvUI and ElvUI[1] or nil;
    SkinsModule = ElvUI_E and ElvUI_E:GetModule("Skins") or nil;
    TooltipModule = ElvUI_E and ElvUI_E:GetModule("Tooltip") or nil;
end

-- Initial cache update
UpdateElvUICaches();

---RegisterSkinnableElement adds a UI element to the skinning queue.
---@param element table UI frame or widget to skin.
---@param skinType string Type of UI element (e.g., "button", "checkbox").
---@param applyImmediately boolean If true, skinning is triggered immediately.
function SIPPYCUP.ElvUI.RegisterSkinnableElement(element, skinType, applyImmediately)
    table.insert(skinnableElements, { element = element, type = skinType });
    if applyImmediately then
        SIPPYCUP.ElvUI.SkinRegisteredElements();
    end
end

---SkinRegisteredElements applies ElvUI skins to all registered UI elements.
---It safely checks for ElvUI's presence and required modules.
---After applying skins, it clears the queue to prevent duplicate skinning.
---@return nil
function SIPPYCUP.ElvUI.SkinRegisteredElements()
    -- Update cache every time to handle dynamic loading/unloading of ElvUI
    UpdateElvUICaches();
    if not ElvUI_E or not SkinsModule then
        return;
    end

    for _, item in ipairs(skinnableElements) do
        local element, skinType = item.element, item.type;
        if element then
            if skinType == "button" and SkinsModule.HandleButton then
                SkinsModule:HandleButton(element);
            elseif skinType == "checkbox" and SkinsModule.HandleCheckBox then
                SkinsModule:HandleCheckBox(element);
            elseif skinType == "dropdown" and SkinsModule.HandleDropDownBox then
                SkinsModule:HandleDropDownBox(element);
            elseif skinType == "editbox" and SkinsModule.HandleEditBox then
                SkinsModule:HandleEditBox(element);
            elseif skinType == "frame" and SkinsModule.HandleFrame then
                SkinsModule:HandleFrame(element);
                -- Skin any child buttons inside the frame
                for _, child in ipairs({ element:GetChildren() }) do
                    if child:IsObjectType("Button") then
                        SkinsModule:HandleButton(child);
                    end
                end
                if element.ItemIcon and SkinsModule.HandleIcon then
                    SkinsModule:HandleIcon(element.ItemIcon);
                end
            elseif skinType == "icon" and SkinsModule.HandleIcon then
                SkinsModule:HandleIcon(element);
            elseif skinType == "inset" and SkinsModule.HandleInsetFrame then
                if element.NineSlice and element.NineSlice.SetTemplate then
                    -- Safer check to avoid errors if SetTemplate doesn't exist
                    element.NineSlice:SetTemplate("Transparent");
                else
                    SkinsModule:HandleInsetFrame(element);
                end
            elseif skinType == "scrollbar" and SkinsModule.HandleScrollBar then
                SkinsModule:HandleScrollBar(element);
            elseif skinType == "slider" and SkinsModule.HandleStepSlider then
                SkinsModule:HandleStepSlider(element);
            elseif skinType == "toptapbutton" and SkinsModule.HandleTab then
                SkinsModule:HandleTab(element);
            end
        end
    end

    table.wipe(skinnableElements); -- Clear the queue after skinning
end

---SkinTooltip applies ElvUI's tooltip styling to the given tooltip frame.
---@param tooltip table Tooltip frame to style.
function SIPPYCUP.ElvUI.SkinTooltip(tooltip)
    UpdateElvUICaches();
    if not ElvUI_E or not TooltipModule then
        return;
    end

    TooltipModule:SetStyle(tooltip);
end
