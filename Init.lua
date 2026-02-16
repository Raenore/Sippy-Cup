-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

---@class SIPPYCUP
local _, SIPPYCUP = ...;

-- Create a single event dispatcher frame for all addon events
local SIPPYCUP_Addon = CreateFrame("Frame", "SIPPYCUP_EventFrame");

-- Set up event handler to call methods on SIPPYCUP_Addon by event name
SIPPYCUP_Addon:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		self[event](self, event, ...);
	end
end);

-- Register initial events needed on addon load and login
SIPPYCUP_Addon:RegisterEvent("ADDON_LOADED");
SIPPYCUP_Addon:RegisterEvent("PLAYER_LOGIN");

local CallbackHandler = LibStub("CallbackHandler-1.0");

SIPPYCUP.Callbacks = {};

SIPPYCUP.Callbacks.callbacks = CallbackHandler:New(SIPPYCUP.Callbacks);

function SIPPYCUP.Callbacks:TriggerEvent(eventTable, ...)
	self.callbacks:Fire(eventTable, ...);
end

SIPPYCUP.Events = {
	-- Startup
	OPTIONS_LOADED = "OPTIONS_LOADED",
	DATABASE_LOADED = "DATABASE_LOADED",
	ADDON_IS_READY = "ADDON_IS_READY",

	-- Loading Screens
	LOADING_SCREEN_STARTED = "LOADING_SCREEN_STARTED",
	LOADING_SCREEN_ENDED = "LOADING_SCREEN_ENDED",
};

SIPPYCUP.States = {
	addonReady = false,
	optionsLoaded = false,
	databaseLoaded = false,
	hasSeenFullUpdate = false,
	loadingScreen = true,
	playerLoggedIn = false,
	restricted = false,
};

SIPPYCUP.AddonMetadata = {
	addonBuild = C_AddOns.GetAddOnMetadata("SippyCup", "X-Build"),
	author = C_AddOns.GetAddOnMetadata("SippyCup", "Author"),
	iconTexture = C_AddOns.GetAddOnMetadata("SippyCup", "IconTexture"),
	notes = C_AddOns.GetAddOnMetadata("SippyCup", "Notes"),
	title = C_AddOns.GetAddOnMetadata("SippyCup", "Title"),
	version = C_AddOns.GetAddOnMetadata("SippyCup", "Version"),
};

--@debug@
-- Debug mode is enable when the add-on has not been packaged by Curse
SIPPYCUP.IS_DEV_BUILD = true;
--@end-debug@

--[===[@non-debug@
-- Debug mode is disabled when the add-on has been packaged by Curse
SIPPYCUP.IS_DEV_BUILD = false;
--@end-non-debug@]===]

_G.SIPPYCUP_Addon = SIPPYCUP_Addon;
_G.SIPPYCUP = SIPPYCUP;
