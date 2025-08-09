-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

---@class SIPPYCUP
local _, SIPPYCUP = ...;

local _state = {
	addonLoaded = false,
	consumablesLoaded = false,
	databaseLoaded = false,
	hasSeenFullUpdate = false,
	inLoadingScreen = true,
	startupLoaded = false,
};

-- Table of listeners keyed by state key
local stateListeners = {};

-- Function to register a listener callback for a specific state key
local function State_RegisterListener(key, callback)
	if not stateListeners[key] then
		stateListeners[key] = {};
	end
	table.insert(stateListeners[key], callback);
end

-- Proxy table with metatable to handle listener notification
SIPPYCUP.State = setmetatable({}, {
	__index = function(_, k)
		return _state[k];
	end,
	__newindex = function(_, k, v)
		local oldValue = _state[k];
		if oldValue ~= v then
			_state[k] = v;
			if stateListeners[k] then
				for _, callback in ipairs(stateListeners[k]) do
					callback(v, oldValue);
				end
			end
		end
	end,
});

-- Expose the listener registration function on SIPPYCUP.State
SIPPYCUP.State.RegisterListener = State_RegisterListener;

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
