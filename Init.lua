-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

---@class SIPPYCUP
local _, SIPPYCUP = ...;

SIPPYCUP.state = {
	addonLoaded = false,
	consumablesLoaded = false,
	databaseLoaded = false,
	hasSeenFullUpdate = false;
	inLoadingScreen = true;
	startupLoaded = false;
};

-- Create a single event dispatcher frame for all addon events
local events = CreateFrame("Frame", "SIPPYCUP_EventFrame");
_G.SIPPYCUP_Addon = events;

-- Set up event handler to call methods on SIPPYCUP_Addon by event name
events:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		self[event](self, event, ...);
	end
end);

-- Register initial events needed on addon load and login
events:RegisterEvent("ADDON_LOADED");
events:RegisterEvent("PLAYER_LOGIN");

-- Expose the event dispatcher frame as SIPPYCUP.Events
SIPPYCUP.Events = events;

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

_G.SIPPYCUP = SIPPYCUP;
