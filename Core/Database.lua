-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local L = SIPPYCUP.L;
SIPPYCUP.Database = {};
---@type table<number, SIPPYCUPProfileOption>
SIPPYCUP.Profile = {};

---Copies keys from source to target only if target key is nil (recursive).
---@param source table Source table to copy defaults from.
---@param target table Target table to copy defaults into.
---@return nil
local function DeepCopyDefaults(source, target)
	for k, v in pairs(source) do
		local tgt = target[k];
		if type(v) == "table" then
			if not tgt then
				tgt = {};
				target[k] = tgt;
			end
			DeepCopyDefaults(v, tgt);
		elseif tgt == nil then
			target[k] = v;
		end
	end
end

---Copies keys from source to target, overwriting target keys (recursive).
---@param source table Source table.
---@param target table Target table to merge into.
---@return nil
local function DeepMerge(source, target)
	for k, v in pairs(source) do
		local tgt = target[k];
		if type(v) == "table" then
			if not tgt then
				tgt = {};
				target[k] = tgt;
			end
			DeepMerge(v, tgt);
		else
			target[k] = v;
		end
	end
end

---Returns a minimal table containing only values from current that differ from default.
---@param current table The table with current values.
---@param default table? Optional default table to compare against.
---@return table minimal The minimal table with only differing values.
local function GetMinimalTable(current, default)
	local minimal;
	for k, v in pairs(current) do
		local defVal = default and default[k];
		if type(v) == "table" and type(defVal) == "table" then
			local nested = GetMinimalTable(v, defVal);
			-- Only include nested tables if they have keys (non-empty)
			if next(nested) then
				minimal = minimal or {};
				minimal[k] = nested;
			end
		elseif v ~= defVal then
			minimal = minimal or {};
			minimal[k] = v;
		end
	end
	return minimal or {};
end

---Default saved variable structure for the SippyCup addon.
---Contains both global options and profile-specific option settings.
---@class SIPPYCUPDefaults
---@field global SIPPYCUPGlobalSettings Global settings shared across all profiles.
---@field profiles table<string, table<string, SIPPYCUPProfileOption>> Table of profiles, each mapping to a table of profile keys.

---Global addon settings shared across all user profiles.
---@class SIPPYCUPGlobalSettings
---@field AlertSound boolean Whether alert sound is enabled.
---@field AlertSoundID string The sound ID to play for alerts.
---@field FlashTaskbar boolean Whether to flash the taskbar on alerts.
---@field Flyway SIPPYCUPFlyway Database patch versioning and migration tracking.
---@field InsufficientReminder boolean Whether to show a reminder if not enough consumables are found.
---@field MinimapButton SIPPYCUPMinimapSettings Configuration for the minimap button.
---@field MSPStatusCheck boolean Whether to check MSP OOC status before alerting.
---@field NewFeatureNotification boolean Whether to show the new feature notification in the options.
---@field PopupPosition string Position of the popup ("TOP", "BOTTOM", etc.).
---@field PreExpirationChecks boolean Whether to perform checks shortly before aura expiration.
---@field PreExpirationLeadTimer number Time (in minutes) before a pre-expiration reminder should fire.
---@field ProjectionPrismPreExpirationLeadTimer number Time (in minutes) before a projection prism pre-expiration reminder should fire.
---@field ReflectingPrismPreExpirationLeadTimer number Time (in minutes) before a reflecting prism pre-expiration reminder should fire.
---@field UseToyCooldown boolean Whether to use toy cooldowns for popups instead.
---@field WelcomeMessage boolean Whether to display a welcome message on login.

---Minimap button configuration options.
---@class SIPPYCUPMinimapSettings
---@field Hide boolean If true, the minimap button is hidden.
---@field ShowAddonCompartmentButton boolean Whether to show the button in the addon compartment menu.

---Flyway patching/tracking information for database upgrades.
---@class SIPPYCUPFlyway
---@field CurrentBuild integer The last applied database patch version. Starts at 0.
---@field Log string A text log of the last patch operation, or "" if none.

---@type SIPPYCUPDefaults
SIPPYCUP.Database.defaults = {
	global = {
		AlertSound = true,
		AlertSoundID = "fx_ship_bell_chime_02",
		DebugOutput = false,
		FlashTaskbar = true,
		Flyway = {
			CurrentBuild = 0,
			Log = "",
		},
		InsufficientReminder = false,
		MinimapButton = {
			Hide = false,
			ShowAddonCompartmentButton = true,
		},
		MSPStatusCheck = true,
		NewFeatureNotification = true,
		PopupPosition = "TOP",
		PreExpirationChecks = true,
		PreExpirationLeadTimer = 1,
		ProjectionPrismPreExpirationLeadTimer = 5,
		ReflectingPrismPreExpirationLeadTimer = 3,
		UseToyCooldown = true,
		WelcomeMessage = true,
	},
	profiles = {
		Default = {},  -- will hold all options per profile
	},
};

local defaults = SIPPYCUP.Database.defaults;

---PersistCurrentProfile saves the current runtime profile as minimal differences to saved variables.
---@return nil
local function PersistCurrentProfile()
	local currentProfileName = SIPPYCUP.Database.GetCurrentProfileName();
	if not currentProfileName or not SIPPYCUP.Profile then return; end

	local defaultProfile = defaults.profiles.Default or {};
	local minimal = GetMinimalTable(SIPPYCUP.Profile, defaultProfile);
	SIPPYCUP.db.profiles[currentProfileName] = minimal;
end

---Represents a single option's tracking settings within a user profile.
---@class SIPPYCUPProfileOption: table
---@field enable boolean Whether the option is enabled for tracking.
---@field desiredStacks number Number of stacks the user wants to maintain.
---@field currentInstanceID number? Aura instance ID currently being tracked (if any).
---@field currentStacks number Current number of detected stacks.
---@field aura number The associated aura ID for this option.
---@field castAura number The associated cast aura ID, if none is set then use aura ID.
---@field untrackableByAura boolean Whether this option can be tracked via its aura or not.
---@field type string Whether this option is a consumable (0) or toy (1).
---@field isPrism boolean Whether this option is considered a prism.
---@field instantUpdate boolean Whether the instant UNIT_AURA update has already happened right after the addition (prisms).
---@field usesCharges boolean Whether this option uses charges (generally reflecting prism).

---Populate the default option's table keyed by aura ID, with all known entries from SIPPYCUP.Options.Data.
---This defines initial tracking settings for each option by its aura ID key.
---@return nil
local function PopulateDefaultOptions()
	local optionsData = SIPPYCUP.Options.Data;
	local defaultsProfile = defaults.profiles.Default;
	for i = 1, #optionsData do
		local option = optionsData[i];
		local spellID = option.auraID;
		local castSpellID = option.castAuraID;
		local untrackableByAura = option.itemTrackable or option.spellTrackable;
		local optionType = option.type;
		local isPrism = (option.category == "PRISM") or false;
		local instantUpdate = not isPrism;
		local usesCharges = option.charges;

		if spellID then
			-- Use auraID as the key, not profileKey
			defaultsProfile[spellID] = {
				enable = false,
				desiredStacks = 1,
				currentInstanceID = nil,
				currentStacks = 0,
				aura = spellID,
				castAura = castSpellID,
				untrackableByAura = untrackableByAura,
				type = optionType,
				isPrism = isPrism,
				instantUpdate = instantUpdate,
				usesCharges = usesCharges,
			};
		end
	end
end

PopulateDefaultOptions();

---@type table<number, SIPPYCUPProfileOption>
SIPPYCUP.Database.auraToProfile = {}; -- auraID --> profile data
---@type table<number, SIPPYCUPProfileOption>
SIPPYCUP.Database.instanceToProfile = {}; -- instanceID --> profile data
---@type table<number, SIPPYCUPProfileOption>
SIPPYCUP.Database.untrackableByAuraProfile = {}; -- itemID --> profile data (only if no aura)
---@type table<number, SIPPYCUPProfileOption>
SIPPYCUP.Database.castAuraToProfile = {}; -- castAuraID (if different) / auraID --> profile data


---RebuildAuraMap rebuilds internal lookup tables for aura and instance-based option tracking.
---@return nil
function SIPPYCUP.Database.RebuildAuraMap()
	-- Reset fast lookup tables
	local db = SIPPYCUP.Database;
	wipe(db.auraToProfile);
	wipe(db.instanceToProfile);
	wipe(db.untrackableByAuraProfile);
	wipe(db.castAuraToProfile);

	for _, profileOptionData in pairs(SIPPYCUP.Profile) do
		if profileOptionData.enable and profileOptionData.aura then
			local auraID = profileOptionData.aura;
			db.auraToProfile[auraID] = profileOptionData;
			local castAuraID = profileOptionData.castAura;
			db.castAuraToProfile[castAuraID] = profileOptionData;

			-- Update instance ID if aura is currently active
			local auraInfo;
			if canaccessvalue == nil or canaccessvalue(auraID) then
				auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(auraID);
			end
			local instanceID = auraInfo and auraInfo.auraInstanceID;
			profileOptionData.currentInstanceID = instanceID;
			if instanceID then
				db.instanceToProfile[instanceID] = profileOptionData;
			end

			-- Handle options that are trackable without auras (via itemID)
			if profileOptionData.untrackableByAura then
				local optionData = SIPPYCUP.Options.ByAuraID[auraID];
				if optionData and optionData.itemID then
					db.untrackableByAuraProfile[optionData.itemID] = profileOptionData;
				end
			end
		end
	end
end

---UpdateAuraMapForOption updates or removes a single profile's entries in the aura, instance, and noAura mappings.
---@param profileOptionData SIPPYCUPProfileOption The profile data to update.
---@param enabled boolean Whether the profile is enabled or disabled.
---@return nil
function SIPPYCUP.Database.UpdateAuraMapForOption(profileOptionData, enabled)
	if not profileOptionData or not profileOptionData.aura then
		return;
	end

	local db = SIPPYCUP.Database;
	local auraID = profileOptionData.aura;
	local optionData = SIPPYCUP.Options.ByAuraID[auraID];

	if enabled then
		-- Add/update auraToProfile
		db.auraToProfile[auraID] = profileOptionData;

		-- Update instanceToProfile if aura is currently active
		local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(auraID);
		local instanceID = auraInfo and auraInfo.auraInstanceID;
		profileOptionData.currentInstanceID = instanceID;
		if instanceID then
			db.instanceToProfile[instanceID] = profileOptionData;
		end

		-- Update untrackableByAuraProfile if applicable
		if profileOptionData.untrackableByAura and optionData and optionData.itemID then
			db.untrackableByAuraProfile[optionData.itemID] = profileOptionData;
		end
	else
		-- Remove from auraToProfile
		db.auraToProfile[auraID] = nil;

		-- Remove from instanceToProfile if currentInstanceID is set
		local instanceID = profileOptionData.currentInstanceID;
		if instanceID then
			db.instanceToProfile[instanceID] = nil;
			profileOptionData.currentInstanceID = nil;
		end

		-- Remove from untrackableByAuraProfile if applicable
		if profileOptionData.untrackableByAura and optionData and optionData.itemID then
			db.untrackableByAuraProfile[optionData.itemID] = nil;
		end
	end
end

---Returns profile data matching spell ID, aura instance ID, or item ID.
---@param spellId number? Spell ID to match `auraToProfile`.
---@param instanceID number? Aura instance ID to match `instanceToProfile`.
---@param itemID number? Item ID to match `untrackableByAuraProfile`.
---@return SIPPYCUPProfileOption? profileOptionData
function SIPPYCUP.Database.FindMatchingProfile(spellId, instanceID, itemID)
	local db = SIPPYCUP.Database;

	if canaccessvalue == nil or canaccessvalue(spellId) then
		if spellId ~= nil then
			return db.auraToProfile[spellId];
		end
	end

	if instanceID ~= nil then
		return db.instanceToProfile[instanceID];
	elseif itemID ~= nil then
		return db.untrackableByAuraProfile[itemID];
	end

	return nil;
end

local categories = { "Appearance", "Effect", "Handheld", "Placement", "Prism", "Size" };

-- Sort `categories` in-place by their localized title:
table.sort(categories, function(a, b)
	local locA = L["OPTIONS_TAB_" .. string.upper(a) .. "_TITLE"];
	local locB = L["OPTIONS_TAB_" .. string.upper(b) .. "_TITLE"];
	return SIPPYCUP_TEXT.Normalize(locA:lower()) < SIPPYCUP_TEXT.Normalize(locB:lower());
end);

---Gets a value from the current profile, falling back to defaults.
---@param key string
---@return any
function SIPPYCUP.Database.GetSetting(key)
	local profile = SIPPYCUP.Profile;
	local defaultsProfile = SIPPYCUP.Database.defaults.profiles.Default;

	if not defaultsProfile then return nil; end
	if not profile then return defaultsProfile[key]; end

	local value = profile[key];
	if value == nil then
		local def = defaultsProfile[key];
		if type(def) == "table" then
			profile[key] = {};
			for k, v in pairs(def) do
				profile[key][k] = v;
			end
			value = profile[key];
		else
			value = def;
		end
	end

	return value;
end

---Sets a value in the current profile.
---@param key string
---@param value any
function SIPPYCUP.Database.SetSetting(key, value)
	local profile = SIPPYCUP.Profile;
	if not profile then return; end

	local defaultsProfile = SIPPYCUP.Database.defaults.profiles.Default;
	local def = defaultsProfile and defaultsProfile[key];

	if type(value) == "table" then
		profile[key] = profile[key] or {};
		for k, v in pairs(value) do
			profile[key][k] = v;
		end
	elseif value == def then
		profile[key] = nil;
	else
		profile[key] = value;
	end

	-- Persist to saved variables
	local profileName = SIPPYCUP.Database.GetCurrentProfileName();
	if profileName then
		local defaultProfile = SIPPYCUP.Database.defaults.profiles.Default or {};
		local minimal = GetMinimalTable(profile, defaultProfile);
		SIPPYCUP.db.profiles[profileName] = minimal;
	end
end

---Gets a value from the global database, falling back to defaults.
---@param key string
---@return any
function SIPPYCUP.Database.GetGlobalSetting(key)
	local global = SIPPYCUP.global;
	local def = SIPPYCUP.Database.defaults.global[key];

	if global[key] == nil then
		if type(def) == "table" then
			global[key] = {};
			local t = global[key];
			for k, v in pairs(def) do
				t[k] = t[k] or v;
			end
		else
			global[key] = def;
		end
	end

	return global[key];
end

---Sets a value in the global database.
---@param key string
---@param value any
function SIPPYCUP.Database.SetGlobalSetting(key, value)
	local global = SIPPYCUP.global;

	if type(value) == "table" then
		global[key] = global[key] or {};
		for k, v in pairs(value) do
			global[key][k] = v;
		end
	else
		global[key] = value;
	end

	-- Persist to saved variables
	if SIPPYCUP.db then
		SIPPYCUP.db.global = SIPPYCUP.db.global or {};
		SIPPYCUP.db.global[key] = value;
	end
end

---RefreshUI refreshes the configuration menu by updating widgets and syncing profile values.
---It only runs if the config menu frame and its refresh method are available.
---@return nil
function SIPPYCUP.Database.RefreshUI()
	if SIPPYCUP.configFrame then
		SIPPYCUP_ConfigMenuFrame:RefreshWidgets();
		SIPPYCUP_ConfigMenuFrame:SwitchProfileValues();
	end
end

---GetUnitName Returns the player's full name with realm if available.
---Retrieves the player's unmodified name and normalized realm.
---Returns nil if player name is invalid or realm is missing.
---@return string? fullName Full player name in "Name - Realm" format or nil if unavailable.
function SIPPYCUP.Database.GetUnitName()
	local playerName, realm = UnitNameUnmodified("player");
	if not playerName or playerName == UNKNOWNOBJECT or playerName:len() == 0 then
		return nil;
	end

	if not realm or realm:len() == 0 then
		realm = GetRealmName();
	end

	if realm and realm:len() > 0 then
		return playerName .. " - " .. realm;
	end

	return nil;
end

---Setup initializes the database, registers callbacks, and configures options tables for the addon.
---@return nil
function SIPPYCUP.Database.Setup()
	local db = SIPPYCUP.db;

	-- Ensure required top-level tables exist
	db.global = db.global or {};
	db.profiles = db.profiles or {};
	db.profileKeys = db.profileKeys or {};

	-- Fill in missing global keys from defaults (preserves saved overrides)
	DeepCopyDefaults(defaults.global, db.global);

	-- Use the saved table directly for runtime global
	SIPPYCUP.global = db.global;

	-- Get current character identifier
	local charKey = SIPPYCUP.Database.GetUnitName() or "Unknown";
	local profileName = db.profileKeys[charKey] or "Default";
	db.profileKeys[charKey] = profileName;

	-- Ensure the named profile exists
	db.profiles[profileName] = db.profiles[profileName] or {};

	-- Start from a clean copy of the default profile
	local defaultProfile = defaults.profiles.Default or {};
	local workingProfile = {};
	DeepCopyDefaults(defaultProfile, workingProfile);

	-- Merge minimal saved data into working profile
	DeepMerge(db.profiles[profileName], workingProfile);

	-- Save minimal differences back to saved variables
	db.profiles[profileName] = GetMinimalTable(workingProfile, defaultProfile);

	-- Set runtime profile
	SIPPYCUP.Profile = workingProfile;

	SIPPYCUP.States.databaseLoaded = true;
end

---GetAllProfiles returns a table of profile names keyed by name.
---@param excludeCurrent boolean? If true, excludes the current active profile. Defaults to false.
---@param excludeDefault boolean? If true, excludes the "Default" profile. Defaults to false.
---@return table<string, string> A table of profile names keyed by profile name.
function SIPPYCUP.Database.GetAllProfiles(excludeCurrent, excludeDefault)
	local results = {};
	local key = SIPPYCUP.Database.GetUnitName();
	local currentProfile = key and SIPPYCUP.db.profileKeys and SIPPYCUP.db.profileKeys[key];

	local profiles = SIPPYCUP.db.profiles or {};
	for profileName in pairs(profiles) do
		if not ((excludeCurrent and profileName == currentProfile) or
				(excludeDefault and profileName == "Default")) then
			results[profileName] = profileName;
		end
	end

	return results;
end

---GetCurrentProfileName returns the profile name associated with the current character.
---@return string? #The current profile name, or nil if not found.
function SIPPYCUP.Database.GetCurrentProfileName()
	if not SIPPYCUP.db or not SIPPYCUP.db.profileKeys then
		SIPPYCUP.Database.Setup();
	end

	local key = SIPPYCUP.Database.GetUnitName();
	return SIPPYCUP.db and SIPPYCUP.db.profileKeys and SIPPYCUP.db.profileKeys[key] or nil;
end

---GetCurrentProfile returns the current profile name and its associated data table.
---@return string? name The profile name.
---@return table? data The resolved profile data table.
function SIPPYCUP.Database.GetCurrentProfile()
	if not SIPPYCUP.db or not SIPPYCUP.db.profileKeys or not SIPPYCUP.db.profiles then
		return nil, nil;
	end

	local key = SIPPYCUP.Database.GetUnitName();
	local profileName = SIPPYCUP.db.profileKeys[key] or "Default";
	local minimalProfile = SIPPYCUP.db.profiles[profileName] or {};

	local defaultProfile = defaults.profiles.Default or {};
	local resolvedProfile = {};
	DeepCopyDefaults(defaultProfile, resolvedProfile);
	DeepMerge(minimalProfile, resolvedProfile);

	return profileName, resolvedProfile;
end

---SetProfile sets the active profile for the current character (creates it if missing).
---@param profileName string The name of the profile to activate.
---@return boolean success, string? errorMessage
function SIPPYCUP.Database.SetProfile(profileName)
	if not SIPPYCUP.db or not SIPPYCUP.db.profiles or not profileName then
		return false, "Database not initialized or invalid profile name";
	end

	local db = SIPPYCUP.db;
	local defaultProfile = defaults.profiles.Default or {};

	-- Persist current runtime profile before switching
	PersistCurrentProfile();

	-- Create target profile if it does not exist
	if not db.profiles[profileName] then
		db.profiles[profileName] = {};
	end

	-- Resolve full profile (defaults + minimal overrides)
	local minimalProfile = db.profiles[profileName];
	local resolvedProfile = {};
	DeepCopyDefaults(defaultProfile, resolvedProfile);
	DeepMerge(minimalProfile, resolvedProfile);

	-- Update keys and runtime profile
	local charKey = SIPPYCUP.Database.GetUnitName();
	db.profileKeys = db.profileKeys or {};
	db.profileKeys[charKey] = profileName;

	-- Set runtime profile
	SIPPYCUP.Profile = resolvedProfile;

	-- Refresh UI
	SIPPYCUP.Database.RefreshUI();

	return true;
end

---CreateProfile creates a new profile and switches to it.
---@param profileName string The name of the new profile to create.
---@return boolean success, string? errorMessage
function SIPPYCUP.Database.CreateProfile(profileName)
	if not SIPPYCUP.db or not SIPPYCUP.db.profiles then
		return false, "Database not initialized";
	end
	if not profileName or profileName:trim() == "" then
		return false, "Invalid profile name";
	end
	if SIPPYCUP.db.profiles[profileName] then
		return false, "Profile already exists";
	end

	local db = SIPPYCUP.db;
	local defaultProfile = defaults.profiles.Default or {};

	-- Persist current runtime profile before switching
	PersistCurrentProfile();

	-- Create an empty minimal profile (no overrides)
	db.profiles[profileName] = {};

	-- Assign new profile to current character
	local key = SIPPYCUP.Database.GetUnitName();
	db.profileKeys = db.profileKeys or {};
	db.profileKeys[key] = profileName;

	-- Set runtime profile to defaults (since minimal is empty)
	SIPPYCUP.Profile = {};
	DeepCopyDefaults(defaultProfile, SIPPYCUP.Profile);

	SIPPYCUP.Database.RefreshUI();

	return true;
end

---ResetProfile resets the specified profile to default by clearing overrides.
---@param profileName string? The profile name to reset. Defaults to current profile.
---@return boolean success, string? errorMessage
function SIPPYCUP.Database.ResetProfile(profileName)
	if not SIPPYCUP.db or not SIPPYCUP.db.profiles then
		return false, "Database not initialized";
	end

	profileName = profileName or SIPPYCUP.Database.GetCurrentProfileName();
	if not profileName or not SIPPYCUP.db.profiles[profileName] then
		return false, "Profile does not exist";
	end

	-- Reset profile minimal data to empty (no user overrides)
	SIPPYCUP.db.profiles[profileName] = {};

	-- If resetting current profile, update runtime resolved profile and UI
	local currentProfileName = SIPPYCUP.Database.GetCurrentProfileName();
	if profileName == currentProfileName then
		local defaultProfile = defaults.profiles.Default or {};

		SIPPYCUP.Profile = {};
		DeepCopyDefaults(defaultProfile, SIPPYCUP.Profile);
		-- No minimal overrides after reset

		SIPPYCUP.Database.RefreshUI();
	end

	return true;
end

---CopyProfile copies settings from a source profile to the current profile.
---@param sourceProfileName string The name of the profile to copy from.
---@return boolean success, string? errorMessage
function SIPPYCUP.Database.CopyProfile(sourceProfileName)
	if not SIPPYCUP.db or not SIPPYCUP.db.profiles then
		return false, "Database not initialized";
	end
	if not sourceProfileName or not SIPPYCUP.db.profiles[sourceProfileName] then
		return false, "Source profile does not exist";
	end

	local currentProfileName = SIPPYCUP.Database.GetCurrentProfileName();
	if not currentProfileName or not SIPPYCUP.db.profiles[currentProfileName] then
		return false, "Current profile does not exist";
	end
	if sourceProfileName == currentProfileName then
		return false, "Source and current profile are the same";
	end

	local defaultProfile = defaults.profiles.Default or {};

	-- Resolve full source profile data by merging saved minimal data on top of defaults
	local sourceFull = {};
	DeepCopyDefaults(defaultProfile, sourceFull);
	DeepMerge(SIPPYCUP.db.profiles[sourceProfileName], sourceFull);

	-- Save only minimal differences from defaults into current profile
	local minimalCopy = GetMinimalTable(sourceFull, defaultProfile);
	SIPPYCUP.db.profiles[currentProfileName] = minimalCopy;

	-- Update runtime shortcut for current profile
	SIPPYCUP.Profile = {};
	DeepCopyDefaults(defaultProfile, SIPPYCUP.Profile);
	DeepMerge(minimalCopy, SIPPYCUP.Profile);

	SIPPYCUP.Database.RefreshUI();

	return true;
end

---DeleteProfile deletes a profile and reassigns characters using it to Default.
---@param profileName string The name of the profile to delete.
---@return boolean success, string? errorMessage
function SIPPYCUP.Database.DeleteProfile(profileName)
	if not SIPPYCUP.db or not SIPPYCUP.db.profiles then
		return false, "Database not initialized";
	end
	if not profileName or not SIPPYCUP.db.profiles[profileName] then
		return false, "Profile does not exist";
	end

	if profileName == "Default" then
		return false, "Default profile cannot be deleted";
	end

	-- Delete the profile minimal data
	SIPPYCUP.db.profiles[profileName] = nil;

	-- Check current profile via profileKeys mapping for current character
	local charKey = SIPPYCUP.Database.GetUnitName();
	local currentProfile = SIPPYCUP.db.profileKeys[charKey] or "Default";

	-- Remove any profileKeys that point to this profile
	if SIPPYCUP.db.profileKeys then
		for key, profName in pairs(SIPPYCUP.db.profileKeys) do
			if profName == profileName then
				SIPPYCUP.db.profileKeys[key] = "Default";
			end
		end
	end

	if profileName == currentProfile then
		-- Switch character's profile to Default
		SIPPYCUP.db.profileKeys[charKey] = "Default";

		-- Ensure Default profile exists minimally
		if not SIPPYCUP.db.profiles["Default"] then
			SIPPYCUP.db.profiles["Default"] = {};
			DeepCopyDefaults(defaults.profiles.Default, SIPPYCUP.db.profiles["Default"]);
		end

		-- Update runtime shortcut with full Default profile data
		SIPPYCUP.Profile = {};
		DeepCopyDefaults(defaults.profiles.Default, SIPPYCUP.Profile);
		DeepMerge(SIPPYCUP.db.profiles["Default"], SIPPYCUP.Profile);

		SIPPYCUP.Database.RefreshUI();
	end

	return true;
end
