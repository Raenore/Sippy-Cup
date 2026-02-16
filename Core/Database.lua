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
		if type(v) == "table" then
			target[k] = target[k] or {};
			DeepCopyDefaults(v, target[k]);
		elseif target[k] == nil then
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
		if type(v) == "table" then
			target[k] = target[k] or {};
			DeepMerge(v, target[k]);
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
	local minimal = {};
	for k, v in pairs(current) do
		local defVal = default and default[k];
		if type(v) == "table" and type(defVal) == "table" then
			local nested = GetMinimalTable(v, defVal);
			-- Only include nested tables if they have keys (non-empty)
			if next(nested) then
				minimal[k] = nested;
			end
		else
			if v ~= defVal then
				minimal[k] = v;
			end
		end
	end
	return minimal;
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
	for i = 1, #optionsData do
		local option = optionsData[i];
		local spellID = option.auraID;
		local castSpellID = option.castAuraID;
		local untrackableByAura = option.itemTrackable or option.spellTrackable;
		local type = option.type;
		local isPrism = (option.category == "PRISM") or false;
		local instantUpdate = not isPrism;
		local usesCharges = option.charges;

		if spellID then
			-- Use auraID as the key, not profileKey
			defaults.profiles.Default[spellID] = {
				enable = false,
				desiredStacks = 1,
				currentInstanceID = nil,
				currentStacks = 0,
				aura = spellID,
				castAura = castSpellID,
				untrackableByAura = untrackableByAura,
				type = type,
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

---UpdateSetting updates a value in the saved minimal table and runtime resolved table.
---If the value matches default, it removes the saved override to keep minimal data clean.
---@param scope string Either "profile" or "global"
---@param key string The setting key to update, e.g. "noggenfoggerSelectDown" or "FlashTaskbar"
---@param subKey string? Optional subkey inside that key, e.g. "enable"
---@param value any The new value to set
---@return boolean success True if update was successful, false if scope invalid or profile missing.
function SIPPYCUP.Database.UpdateSetting(scope, key, subKey, value)
	local db = SIPPYCUP.db;
	local defaultTable, targetMinimal, targetRuntime;

	if scope == "profile" then
		local profileName = SIPPYCUP.Database.GetCurrentProfileName();
		if not profileName then return false; end

		db.profiles = db.profiles or {};
		db.profiles[profileName] = db.profiles[profileName] or {};
		targetMinimal = db.profiles[profileName];

		SIPPYCUP.Profile = SIPPYCUP.Profile or {};
		targetRuntime = SIPPYCUP.Profile;

		defaultTable = defaults.profiles.Default;

	elseif scope == "global" then
		db.global = db.global or {};
		targetMinimal = db.global;

		SIPPYCUP.global = SIPPYCUP.global or {};
		targetRuntime = SIPPYCUP.global;

		defaultTable = defaults.global;

	else
		return false;
	end

	local defaultValue = defaultTable and defaultTable[key];
	if subKey then
		local defaultSubValue = (type(defaultValue) == "table") and defaultValue[subKey];

		-- Save minimal
		if defaultSubValue == value then
			if targetMinimal[key] then
				targetMinimal[key][subKey] = nil;
				if next(targetMinimal[key]) == nil then
					targetMinimal[key] = nil;
				end
			end
		else
			targetMinimal[key] = targetMinimal[key] or {};
			targetMinimal[key][subKey] = value;
		end

		-- Update runtime
		targetRuntime[key] = targetRuntime[key] or {};
		targetRuntime[key][subKey] = value;

	else
		if defaultValue == value then
			targetMinimal[key] = nil;
		else
			targetMinimal[key] = value;
		end

		targetRuntime[key] = value;
	end

	return true;
end

---GetSetting retrieves a value from the runtime profile or global table.
---Falls back to default value if no override is present.
---@param scope "profile" | "global" Scope to fetch the setting from
---@param key string The setting key, e.g. "noggenfoggerSelectDown" or "FlashTaskbar"
---@param subKey string? Optional subkey inside the key
---@return any value The resolved value from runtime or default, or nil if not found
function SIPPYCUP.Database.GetSetting(scope, key, subKey)
	if scope == "profile" then
		local profile = SIPPYCUP.Profile or {};
		if subKey then
			if profile[key] and profile[key][subKey] ~= nil then
				return profile[key][subKey];
			end
			if defaults.profiles.Default and defaults.profiles.Default[key] then
				return defaults.profiles.Default[key][subKey];
			end
			return nil;
		else
			if profile[key] ~= nil then
				return profile[key];
			end
			return defaults.profiles.Default and defaults.profiles.Default[key];
		end

	elseif scope == "global" then
		local global = SIPPYCUP.global or {};
		if subKey then
			if global[key] and global[key][subKey] ~= nil then
				return global[key][subKey];
			end
			if defaults.global and defaults.global[key] then
				return defaults.global[key][subKey];
			end
			return nil;
		else
			if global[key] ~= nil then
				return global[key];
			end
			return defaults.global and defaults.global[key];
		end
	end

	return nil;
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

	-- Create a resolved working copy of global settings for runtime use
	local workingGlobal = {};
	DeepCopyDefaults(defaults.global, workingGlobal);
	DeepMerge(db.global, workingGlobal);  -- saved overrides overwrite defaults

	-- Save runtime global for quick access
	SIPPYCUP.global = workingGlobal;

	-- Get current character identifier
	local charKey = SIPPYCUP.Database.GetUnitName() or "Unknown";

	-- Assign profile key for this character
	local profileName = db.profileKeys[charKey] or "Default";
	db.profileKeys[charKey] = profileName;

	-- Ensure the named profile exists in saved variables
	db.profiles[profileName] = db.profiles[profileName] or {};

	-- Start from a clean copy of the default profile
	local defaultProfile = defaults.profiles.Default or {};
	local workingProfile = {};
	DeepCopyDefaults(defaultProfile, workingProfile);

	-- Merge user's minimal saved data into working profile
	DeepMerge(db.profiles[profileName], workingProfile);

	-- Compute minimal diffs and save back into saved variables
	local minimalProfile = GetMinimalTable(workingProfile, defaultProfile);
	db.profiles[profileName] = minimalProfile;

	-- Set resolved working profile for runtime use
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

	-- Create profile if it doesn't exist
	if not SIPPYCUP.db.profiles[profileName] then
		SIPPYCUP.db.profiles[profileName] = {};
	end

	local defaultProfile = defaults.profiles.Default or {};
	local minimalProfile = SIPPYCUP.db.profiles[profileName];

	-- Resolve full profile with defaults merged
	local resolvedProfile = {};
	DeepCopyDefaults(defaultProfile, resolvedProfile);
	DeepMerge(minimalProfile, resolvedProfile);

	-- Update keys and runtime profile
	local key = SIPPYCUP.Database.GetUnitName();
	SIPPYCUP.db.profileKeys[key] = profileName;

	SIPPYCUP.Profile = resolvedProfile;
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

	-- Create an empty minimal profile (no overrides)
	SIPPYCUP.db.profiles[profileName] = {};

	-- Assign new profile to current character
	local key = SIPPYCUP.Database.GetUnitName();
	SIPPYCUP.db.profileKeys = SIPPYCUP.db.profileKeys or {};
	SIPPYCUP.db.profileKeys[key] = profileName;

	-- Set runtime profile as default profile since minimal is empty
	local defaultProfile = defaults.profiles.Default or {};
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

	-- Clear current profile minimal data table
	SIPPYCUP.db.profiles[currentProfileName] = {};

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

	-- Remove any profileKeys that point to this profile
	if SIPPYCUP.db.profileKeys then
		for charKey, profName in pairs(SIPPYCUP.db.profileKeys) do
			if profName == profileName then
				SIPPYCUP.db.profileKeys[charKey] = "Default";
			end
		end
	else
		SIPPYCUP.db.profileKeys = {};
	end

	-- Check current profile via profileKeys mapping for current character
	local charKey = SIPPYCUP.Database.GetUnitName();
	local currentProfile = SIPPYCUP.db.profileKeys[charKey] or "Default";

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
