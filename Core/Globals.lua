-- Copyright The Sippy Cup Authors
-- Inspired by Eavesdropper
-- SPDX-License-Identifier: Apache-2.0

---@class SippyCupStateFlags
---@field addonReady boolean
---@field firstRun boolean
---@field optionsLoaded boolean
---@field databaseLoaded boolean
---@field hasSeenFullUpdate boolean
---@field loadingScreen boolean
---@field playerLoggedIn boolean
---@field pvpMatch boolean
---@field requiresReinit boolean

---@class SippyCupGlobals
---@field IS_DEV_BUILD boolean
---@field addon_title string
---@field addon_version string
---@field addon_icon_texture string
---@field addon_build string
---@field addon_notes string
---@field author string
---@field empty table
---@field addon table?
---@field States SippyCupStateFlags
SC.Globals = {
	--@debug@
	IS_DEV_BUILD = true,
	--@end-debug@

	--[===[@non-debug@
	DEBUG_MODE = false,
	--@end-non-debug@]===]

	addon_title = C_AddOns.GetAddOnMetadata("SippyCup", "Title"),
	addon_version = C_AddOns.GetAddOnMetadata("SippyCup", "Version"),
	addon_icon_texture = C_AddOns.GetAddOnMetadata("SippyCup", "IconTexture"),
	addon_build = C_AddOns.GetAddOnMetadata("SippyCup", "X-Build"),
	addon_notes = C_AddOns.GetAddOnMetadata("SippyCup", "Notes"),
	author = C_AddOns.GetAddOnMetadata("SippyCup", "Author"),

	States = {
		addonReady = false,
		firstRun = true,
		optionsLoaded = false,
		databaseLoaded = false,
		hasSeenFullUpdate = false,
		loadingScreen = true,
		playerLoggedIn = false,
		pvpMatch = false,
		requiresReinit = false,
	},

	empty = {},
};

local emptyMeta = {
	__newindex = function(_, _, _) end,
};
setmetatable(SC.Globals.empty, emptyMeta);

SC.Globals.addon = SC_Addon;
