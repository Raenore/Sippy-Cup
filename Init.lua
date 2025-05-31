-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

---@class SIPPYCUP
local _, SIPPYCUP = ...;

_G.SIPPYCUP_Addon = LibStub("AceAddon-3.0"):NewAddon("SippyCup", "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0");

SIPPYCUP_Addon:SetDefaultModuleLibraries("AceEvent-3.0");

SIPPYCUP.AddonMetadata = {
	addonBuild = C_AddOns.GetAddOnMetadata("SippyCup", "X-Build"),
	author = C_AddOns.GetAddOnMetadata("SippyCup", "Author"),
	iconTexture = C_AddOns.GetAddOnMetadata("SippyCup", "IconTexture"),
	notes = C_AddOns.GetAddOnMetadata("SippyCup", "Notes"),
	title = C_AddOns.GetAddOnMetadata("SippyCup", "Title"),
    version = C_AddOns.GetAddOnMetadata("SippyCup", "Version"),
}

--@debug@
-- Debug mode is enable when the add-on has not been packaged by Curse
SIPPYCUP.IS_DEV_BUILD = true;
--@end-debug@

--[===[@non-debug@
-- Debug mode is disabled when the add-on has been packaged by Curse
SIPPYCUP.IS_DEV_BUILD = false;
--@end-non-debug@]===]

---@type SIPPYCUP
_G.SIPPYCUP = SIPPYCUP;
