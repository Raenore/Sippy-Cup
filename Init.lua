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

SIPPYCUP.L = LibStub("AceLocale-3.0"):GetLocale("SippyCup", true);

---@type SIPPYCUP
_G.SIPPYCUP = SIPPYCUP;
