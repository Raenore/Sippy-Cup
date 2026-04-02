-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

---@class SippyCupDatabase
---@field currentProfile SippyCupProfile?
---@field defaults SippyCupProfile
---@field globalDefaults SippyCupGlobal
local Database = {};

---Global addon settings shared across all user profiles.
---@class SippyCupGlobal
---@field AlertSound boolean Whether alert sound is enabled.
---@field AlertSoundID string The sound ID to play for alerts.
---@field DebugLevel integer Level of debug output.
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

---Default saved variable structure for the SippyCup addon.
---Contains both global options and profile-specific option settings.
---@class SIPPYCUPDefaults
---@field global SippyCupGlobal Global settings shared across all profiles.

---@type SippyCupGlobal
local GLOBAL_DEFAULTS = {
	AlertSound = true,
	AlertSoundID = "fx_ship_bell_chime_02",
	DebugLevel = SC.Globals.LogLevels.INFO,
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
};

---Represents a single option's tracking settings within a user profile.
---@class SippyCupProfileSettings
---@field enable boolean Whether the option is enabled for tracking.
---@field desiredStacks integer Number of stacks the user wants to maintain.
---@field aura number The associated aura ID for this option.
---@field castAura number? The associated cast aura ID. If none is set, aura ID is used.
---@field untrackableByAura boolean Whether this option can be tracked via its aura or not.
---@field type integer Whether this option is a consumable (0) or toy (1).
---@field isPrism boolean Whether this option is considered a prism.
---@field instantUpdate boolean Whether the instant UNIT_AURA update has already happened right after the addition (prisms).
---@field usesCharges boolean? Whether this option uses charges (generally reflecting prism).

---Default profile options keyed by aura ID
---@type table<number, SippyCupProfileSettings>
local DEFAULT_PROFILE = {};

---Populate the default option's table keyed by aura ID, with all known entries from SIPPYCUP.Options.Data.
---This defines initial tracking settings for each option by its aura ID key.
---@return nil
local function PopulateDefaultProfileOptions()
	local optionsData = SC.Options.Data;
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
			DEFAULT_PROFILE[spellID] = {
				enable = false,
				desiredStacks = 1,
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

---@class SippyCupCharSettings
---@field currentInstanceID number? Aura instance ID currently being tracked (if any).
---@field currentStacks integer Current number of detected stacks.
---@field currentItemID number? The item ID currently being used for this option.
---@field lastItemCount integer Last known item count for this option.

---Default character settings keyed by aura ID
---@type table<number, SippyCupCharSettings>
local DEFAULT_CHAR = {};

---Initializes DEFAULT_CHAR entries for all aura-based options.
---@return nil
local function PopulateDefaultCharOptions()
	local optionsData = SC.Options.Data;
	for i = 1, #optionsData do
		local option = optionsData[i];
		local spellID = option.auraID;

		if spellID then
			-- Use auraID as the key, not profileKey
			DEFAULT_CHAR[spellID] = {
				currentInstanceID = nil,
				currentStacks = 0,
				currentItemID = nil,
				lastItemCount = 0,
			};
		end
	end
end

---@class SippyCupProfile : SippyCupProfileSettings, SippyCupCharSettings

Database.currentProfile = nil;
Database.globalDefaults = SC.Utils.DeepCopy(GLOBAL_DEFAULTS);

---Returns a new table containing all keys from `base`, with keys from `override` applied on top.
---@param base table
---@param override table
---@return SippyCupProfile
local function mergeTables(base, override)
	-- start with defaults
	local result =  SC.Utils.ShallowCopy(base);
	-- apply profile overrides (including keys not in defaults)
	for k, v in pairs(override) do
		result[k] = v;
	end
	return result;
end

---Returns a pruned copy of `value` containing only keys that differ from `def`.
---Returns nil if no keys differ (signals "same as default, don't store").
---Always returns the table itself if `def` is nil (no defaults to compare against).
---@param value table
---@param def table?
---@return table?
local function pruneToDefaults(value, def)
	local newTable = {};
	-- store only keys that differ from defaults
	for k, v in pairs(value) do
		if not def or def[k] ~= v then
			newTable[k] = v;
		end
	end
	-- store table only if there is at least one diff
	return next(newTable) and newTable or nil;
end

---Removes any stored values from a profile that are identical to their defaults.
---Primitives matching defaults are nilled; table values are pruned key-by-key
---and removed entirely when every key matches the default.
---@param profile table
local function pruneProfile(profile)
	for key, value in pairs(profile) do
		local def = DEFAULT_PROFILE[key];
		if def == nil then -- luacheck: ignore 542 (empty if branch)
			-- No default exists for this key; leave it untouched.
		elseif type(value) == "table" then
			if type(def) == "table" then
				profile[key] = pruneToDefaults(value, def);
			end
		elseif value == def then
			profile[key] = nil;
		end
	end
end

---@type table<number, SippyCupProfile>
Database.auraToProfile = {}; -- auraID --> profile data
---@type table<number, SippyCupProfile>
Database.instanceToProfile = {}; -- instanceID --> profile data
---@type table<number, SippyCupProfile>
Database.untrackableByAuraProfile = {}; -- itemID --> profile data (only if no aura)
---@type table<number, SippyCupProfile>
Database.castAuraToProfile = {}; -- castAuraID (if different) / auraID --> profile data

---RebuildAuraMap rebuilds internal lookup tables for aura and instance-based option tracking.
---@return nil
function Database:RebuildAuraMap()
	-- Reset fast lookup tables
	wipe(self.auraToProfile);
	wipe(self.instanceToProfile);
	wipe(self.untrackableByAuraProfile);
	wipe(self.castAuraToProfile);

	local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID;

	-- Iterate over all defaults to ensure full merged profile
	for auraID, defaultData in pairs(self.defaults or {}) do
		local profileOverride = (self.currentProfile or {})[auraID] or {};
		-- Merge default values with any user overrides
		local profileOptionData = mergeTables(defaultData, profileOverride);

		-- Only track enabled auras
		if profileOptionData.enable and auraID then
			self.auraToProfile[auraID] = profileOptionData;

			local castAuraID = profileOptionData.castAura or auraID;
			self.castAuraToProfile[castAuraID] = profileOptionData;

			-- Apply stored character data so fields like currentItemID and lastItemCount persist after reload.
			-- currentInstanceID and currentStacks will be refreshed by the live checks below.
			local charData = self.currentChar and self.currentChar[auraID];
			if charData then
				for k, v in pairs(charData) do
					profileOptionData[k] = v;
				end
			end

			-- Overwrite instance/stacks with fresh live aura data.
			local auraInfo;
			if profileOptionData.currentInstanceID then
				auraInfo = GetAuraDataByAuraInstanceID("player", profileOptionData.currentInstanceID);
			end
			if not auraInfo then
				auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(auraID);
			end

			profileOptionData.currentInstanceID = auraInfo and auraInfo.auraInstanceID or nil;
			profileOptionData.currentStacks = SC.Auras.CalculateCurrentStacks(
				auraInfo, auraID, SC.Popups.Reason.STARTUP, auraInfo ~= nil
			);

			if profileOptionData.currentInstanceID then
				self.instanceToProfile[profileOptionData.currentInstanceID] = profileOptionData;
			end

			-- Handle options that are trackable without auras (via itemID)
			local optionData = SC.Options.ByAuraID[auraID];

			-- Resolve currentItemID and lastItemCount from live inventory/toy state.
			if optionData and optionData.itemID then
				local isToy = SC.Options.Type and (optionData.type == SC.Options.Type.TOY);
				local itemIDs = type(optionData.itemID) == "table" and optionData.itemID or { optionData.itemID };
				local usableItemID;
				local itemCount = 0;

				for _, id in ipairs(itemIDs) do
					local count = isToy and (PlayerHasToy(id) and 1 or 0) or C_Item.GetItemCount(id);
					if count > 0 then
						usableItemID = usableItemID or id;
						itemCount = itemCount + count;
					end
				end

				profileOptionData.currentItemID = usableItemID or itemIDs[#itemIDs];
				profileOptionData.lastItemCount = itemCount;
			end

			-- Track options that rely on items instead of auras.
			if profileOptionData.untrackableByAura and optionData and optionData.itemID then
				self.untrackableByAuraProfile[optionData.itemID] = profileOptionData;
			end

			self:CommitCharState(auraID, profileOptionData);
		end
	end

	-- Prune char data for options not enabled in the current profile
	if self.currentChar then
		for auraID in pairs(self.currentChar) do
			if not self.auraToProfile[auraID] then
				self.currentChar[auraID] = nil;
			end
		end
	end
end

---UpdateAuraMapForOption updates or removes a profile option from aura/instance/item lookup tables.
---@param profileOptionData SippyCupProfile The profile data to update.
---@param enabled boolean Whether the option is enabled or disabled.
function Database:UpdateAuraMapForOption(profileOptionData, enabled)
	if not profileOptionData or not profileOptionData.aura then return; end;

	local auraID = profileOptionData.aura;
	local castAuraID = profileOptionData.castAura or auraID;
	local optionData = SC.Options.ByAuraID[auraID];

	if enabled then
		self.auraToProfile[auraID] = profileOptionData;
		self.castAuraToProfile[castAuraID] = profileOptionData;

		local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(auraID);
		local instanceID = auraInfo and auraInfo.auraInstanceID;

		profileOptionData.currentInstanceID = instanceID;
		profileOptionData.currentStacks = SC.Auras.CalculateCurrentStacks(
			auraInfo, auraID, SC.Popups.Reason.STARTUP, auraInfo ~= nil
		);

		if instanceID then
			self.instanceToProfile[instanceID] = profileOptionData;
		end

		-- Resolve currentItemID and lastItemCount from the current inventory/toy state.
		if optionData and optionData.itemID then
			local isToy = SC.Options.Type and (optionData.type == SC.Options.Type.TOY);
			local itemIDs = type(optionData.itemID) == "table" and optionData.itemID or { optionData.itemID };
			local usableItemID;
			local itemCount = 0;

			for _, id in ipairs(itemIDs) do
				local count = isToy and (PlayerHasToy(id) and 1 or 0) or C_Item.GetItemCount(id);
				if count > 0 then
					usableItemID = usableItemID or id;
					itemCount = itemCount + count;
				end
			end

			profileOptionData.currentItemID = usableItemID or itemIDs[#itemIDs];
			profileOptionData.lastItemCount = itemCount;
		end

		-- Map itemID for options trackable without an aura
		if profileOptionData.untrackableByAura and optionData and optionData.itemID then
			self.untrackableByAuraProfile[optionData.itemID] = profileOptionData;
		end
	else
		self.auraToProfile[auraID] = nil;
		self.castAuraToProfile[castAuraID] = nil;

		local instanceID = profileOptionData.currentInstanceID;
		if instanceID then
			self.instanceToProfile[instanceID] = nil;
		end

		-- Reset char state; CommitCharState will prune unused values from the char DB.
		profileOptionData.currentInstanceID = nil;
		profileOptionData.currentStacks = 0;
		profileOptionData.currentItemID = nil;
		profileOptionData.lastItemCount = 0;

		if profileOptionData.untrackableByAura and optionData and optionData.itemID then
			self.untrackableByAuraProfile[optionData.itemID] = nil;
		end
	end

	self:CommitCharState(auraID, profileOptionData);
end

---Returns profile data matching spell ID, aura instance ID, or item ID.
---@param spellId number? Spell ID to match `auraToProfile`.
---@param instanceID number? Aura instance ID to match `instanceToProfile`.
---@param itemID number? Item ID to match `untrackableByAuraProfile`.
---@return SippyCupProfile? profileOptionData
function Database:FindMatchingProfile(spellId, instanceID, itemID)
	if canaccessvalue == nil or canaccessvalue(spellId) then
		if spellId ~= nil then
			return self.auraToProfile[spellId];
		end
	end

	if instanceID ~= nil then
		return self.instanceToProfile[instanceID];
	elseif itemID ~= nil then
		return self.untrackableByAuraProfile[itemID];
	end

	return nil;
end

---Setup initializes the database and resolves the active profile.
---@return nil
function Database:Init()
	SippyCupDB = SippyCupDB or {
		global = {},
		profileKeys = {},
		profiles = {},
	};

	local db = SippyCupDB;
	db.global = db.global or {};
	db.profileKeys = db.profileKeys or {};
	db.profiles = db.profiles or {};

	PopulateDefaultProfileOptions();
	PopulateDefaultCharOptions();

	self.defaults =  SC.Utils.DeepCopy(DEFAULT_PROFILE);
	self.charDefaults =  SC.Utils.DeepCopy(DEFAULT_CHAR);

	local playerKey =  SC.Utils.GetUnitName() or "Unknown";
	local profileName = db.profileKeys[playerKey] or "Default";

	db.profiles[profileName] = db.profiles[profileName] or {};
	self.currentProfile = db.profiles[profileName];
	db.profileKeys[playerKey] = profileName;

	---Prune all profiles to remove values that match their defaults.
	for _, profileData in pairs(db.profiles) do
		pruneProfile(profileData);
	end

	if SC.Globals.IS_DEV_BUILD then
		SC.Globals.log_level = SC.Database:GetGlobalSetting("DebugLevel");
	end

	self:InitCharacterDatabase();
	SC.Globals.States.databaseLoaded = true;
end

---Initialises or migrates the character-specific chat database, clearing history on version change.
---@return nil
function Database:InitCharacterDatabase()
	SippyCupCharDB = SippyCupCharDB or {};

	self.currentChar = SippyCupCharDB;
	self:LoadFromSaved();
end

---Normalises SippyCupCharDB against charDefaults before the first RebuildAuraMap.
---Removes orphaned aura entries and unknown keys within entries.
---Missing keys are left untouched; GetCharSetting falls back to defaults.
---@return nil
function Database:LoadFromSaved()
	if not self.currentChar then return; end;

	for auraID, charData in pairs(self.currentChar) do
		local defaults = self.charDefaults[auraID];
		if type(auraID) ~= "number" or not defaults then
			-- Orphaned or non-numeric entry; prune entirely.
			self.currentChar[auraID] = nil;
		else
			-- Strip keys not present in charDefaults.
			for k in pairs(charData) do
				if defaults[k] == nil then
					charData[k] = nil;
				end
			end
		end
	end
end

---Re-resolves and re-points currentProfile based on the current player key.
---@param playerKey string? Optional pre-resolved player key.
---@return nil
function Database:ResolveActiveProfile(playerKey)
	local db = SippyCupDB;
	if not db then return; end;

	playerKey = playerKey or  SC.Utils.GetUnitName() or "Unknown";
	local profileName = db.profileKeys[playerKey] or "Default";

	db.profiles[profileName] = db.profiles[profileName] or {};
	self.currentProfile = db.profiles[profileName];
	db.profileKeys[playerKey] = profileName;
end

---Refreshes the config UI if the configuration frame is loaded.
---@return nil
function Database:refreshUI()
	if SC.configFrame then
		SippyCup_ConfigMenuFrame:RefreshWidgets();
		SippyCup_ConfigMenuFrame:SwitchProfileValues();
	end
end

---applyProfileSwitch resets runtime systems after a profile change.
---@return nil
function Database:applyProfileSwitch()
	SC.Popups.HideAllRefreshPopups();
	SC.Auras.CancelAllPreExpirationTimers();
	SC.Items.CancelAllItemTimers();
	self:RebuildAuraMap();
end

---Checks whether a profile with the given name exists.
---@param profileName string
---@return boolean exists
function Database:ProfileExists(profileName)
	if not SippyCupDB or not SippyCupDB.profiles or not profileName then return false; end
	return SippyCupDB.profiles[profileName] ~= nil;
end

---Returns the current profile table.
---@return SippyCupProfile currentProfile
function Database:GetProfile()
	return self.currentProfile;
end

---Returns the name of the current profile for the current player.
---@return string currentProfile
function Database:GetProfileName()
	if not SippyCupDB then return nil; end
	local playerKey =  SC.Utils.GetUnitName() or "Unknown";
	return SippyCupDB.profileKeys[playerKey];
end

---GetAllProfiles returns a table of profile names keyed by name.
---@param excludeCurrent boolean? If true, excludes the current active profile. Defaults to false.
---@param excludeDefault boolean? If true, excludes the "Default" profile. Defaults to false.
---@return table<string, string> A table of profile names keyed by profile name.
function Database:GetAllProfiles(excludeCurrent, excludeDefault)
	local results = {};
	if not SippyCupDB or not SippyCupDB.profiles then
		return results;
	end

	local currentName = self:GetProfileName();

	for name in pairs(SippyCupDB.profiles) do
		if not ((excludeCurrent and name == currentName) or
				(excludeDefault and name == "Default")) then
			results[name] = name;
		end
	end

	return results;
end

---Switches to a different profile.
---@param profileName string Name of the profile to switch to.
---@return nil
function Database:SetProfile(profileName)
	if not profileName or profileName == "" then return; end
	if profileName == self:GetProfileName() then return; end

	local db = SippyCupDB;
	db.profiles[profileName] = db.profiles[profileName] or {};

	self.currentProfile = db.profiles[profileName];

	local playerKey =  SC.Utils.GetUnitName();
	db.profileKeys[playerKey] = profileName;

	self:applyProfileSwitch();
	self:refreshUI();

	SC.Options.RefreshStackSizes(
		SC.MSP.IsEnabled() and self:GetGlobalSetting("MSPStatusCheck"),
		false
	);
end

---Creates a new profile and switches to it. If the profile already exists, switches to it.
---@param profileName string
---@return boolean success
function Database:CreateProfile(profileName)
	if not profileName or profileName == "" then return false; end
	self:SetProfile(profileName);
	return true;
end

---Renames an existing profile and updates all character bindings that reference it.
---@param oldName string The current name of the profile.
---@param newName string The desired new name.
---@return boolean success
function Database:RenameProfile(oldName, newName)
	if not SippyCupDB or not SippyCupDB.profiles then return false; end
	if not oldName or not SippyCupDB.profiles[oldName] then return false; end
	if oldName == "Default" then return false; end
	if not newName or newName == "" then return false; end
	if self:ProfileExists(newName) then return false; end

	local db = SippyCupDB;

	-- Move profile data from the old key to the new key.
	db.profiles[newName] = db.profiles[oldName];
	db.profiles[oldName] = nil;

	-- Reassign every character binding that pointed at the old name.
	for charKey, profName in pairs(db.profileKeys) do
		if profName == oldName then
			db.profileKeys[charKey] = newName;
		end
	end

	self:refreshUI();

	return true;
end

---Creates a new profile as a copy of an existing one and switches to it.
---@param sourceName string
---@param newName string
---@return boolean success
function Database:CloneProfile(sourceName, newName)
	if not newName or newName == "" then return false; end
	if not SippyCupDB.profiles[sourceName] then return false; end

	self:SetProfile(newName);
	return self:CopyProfile(sourceName);
end

---Copies all settings from a source profile into the current profile, overwriting everything.
---@param sourceName string
---@return boolean success
function Database:CopyProfile(sourceName)
	local current = self.currentProfile;
	local source = SippyCupDB.profiles[sourceName];
	if not current or not source then return false; end

	for k in pairs(current) do
		current[k] = nil;
	end

	local copy =  SC.Utils.DeepCopy(source);
	for k, v in pairs(copy) do
		current[k] = v;
	end

	self:applyProfileSwitch();
	self:refreshUI();

	SC.Options.RefreshStackSizes(
		SC.MSP.IsEnabled() and self:GetGlobalSetting("MSPStatusCheck"),
		false
	);

	return true;
end

---Deletes a profile from saved variables. Prevents deleting the active profile.
---@param profileName string
---@return boolean success
function Database:DeleteProfile(profileName)
	if not profileName or profileName == "" then return false; end
	if profileName == self:GetProfileName() then return false; end
	if not SippyCupDB.profiles[profileName] then return true; end

	SippyCupDB.profiles[profileName] = nil;

	for key, name in pairs(SippyCupDB.profileKeys) do
		if name == profileName then
			SippyCupDB.profileKeys[key] = "Default";
		end
	end

	return true;
end

---Resets the current profile to default values.
---@return boolean success
function Database:ResetProfile()
	local current = self.currentProfile;
	if not current then return false; end

	for k in pairs(current) do
		current[k] = nil;
	end

	self:applyProfileSwitch();
	self:refreshUI();

	return true;
end

---@alias SippyCupProfileSettingKey
---| "enable"
---| "desiredStacks"
---| "aura"
---| "castAura"
---| "untrackableByAura"
---| "type"
---| "isPrism"
---| "instantUpdate"
---| "usesCharges"

---Returns the profile option for a given auraID, merging defaults with stored differences.
---@param auraID number The aura ID to lookup.
---@return SippyCupProfileSettings option The profile option table for this aura.
function Database:GetProfileSettings(auraID)
	local defaults = self.defaults[auraID];
	if not defaults then return nil; end

	local profile = self.currentProfile and self.currentProfile[auraID];
	if profile then
		return mergeTables(defaults, profile);
	end

	-- Return a shallow copy of defaults to prevent accidental mutation
	return  SC.Utils.ShallowCopy(defaults);
end

---@param auraID number
---@param key SippyCupProfileSettingKey
---@return any
function Database:GetProfileSetting(auraID, key)
	local defaults = self.defaults[auraID];
	if not defaults then return nil; end

	local profile = self.currentProfile and self.currentProfile[auraID];
	local defValue = defaults[key];

	if profile and profile[key] ~= nil then
		if type(defValue) == "table" then
			return mergeTables(defValue, profile[key]);
		end
		return profile[key];
	end

	if type(defValue) == "table" then
		return  SC.Utils.ShallowCopy(defValue);
	end

	return defValue;
end

---@param auraID number
---@param key SippyCupProfileSettingKey
---@param value any
function Database:SetProfileSetting(auraID, key, value)
	if not self.currentProfile then return; end
	local defaults = self.defaults[auraID];
	if not defaults then return; end

	self.currentProfile[auraID] = self.currentProfile[auraID] or {};
	local profileEntry = self.currentProfile[auraID];

	local defValue = defaults[key];

	if type(value) == "table" then
		profileEntry[key] = pruneToDefaults(value, defValue);
	elseif value == defValue then
		profileEntry[key] = nil;
	else
		profileEntry[key] = value;
	end

	-- Remove the per-aura table entirely if all keys were pruned to defaults
	if not next(profileEntry) then
		self.currentProfile[auraID] = nil;
	end

	self:refreshUI();
end

---@alias SippyCupCharSettingKey
---| "currentInstanceID"
---| "currentStacks"
---| "currentItemID"
---| "lastItemCount"

---Returns the character settings for a given auraID, merging defaults with stored differences.
---@param auraID number The aura ID to lookup.
---@return SippyCupCharSettings charSettings
function Database:GetCharSettings(auraID)
	local defaults = self.charDefaults[auraID];
	if not defaults then return nil; end

	local charSettings = self.currentChar and self.currentChar[auraID];
	if charSettings then
		return mergeTables(defaults, charSettings);
	end

	-- Return a shallow copy of defaults to prevent accidental mutation
	return  SC.Utils.ShallowCopy(defaults);
end

---Returns a single value from the character settings for a given auraID.
---@param auraID number
---@param key SippyCupCharSettingKey
---@return any
function Database:GetCharSetting(auraID, key)
	local charSettings = self:GetCharSettings(auraID);
	if not charSettings then return nil; end
	return charSettings[key];
end

---Stores a character setting for a given auraID, pruning values equal to their defaults.
---@param auraID number
---@param key SippyCupCharSettingKey
---@param value any
function Database:SetCharSetting(auraID, key, value)
	if type(auraID) ~= "number" then return; end -- ignore non-numeric keys

	if not SippyCupCharDB then SippyCupCharDB = {}; end
	self.currentChar = self.currentChar or SippyCupCharDB;

	local defaults = self.charDefaults[auraID] or {};
	self.currentChar[auraID] = self.currentChar[auraID] or  SC.Utils.DeepCopy(defaults);

	if type(value) == "table" then
		self.currentChar[auraID][key] = pruneToDefaults(value, defaults[key]);
	elseif value == defaults[key] then
		self.currentChar[auraID][key] = nil;
	else
		self.currentChar[auraID][key] = value;
	end

	-- Remove the per-aura table entirely if all keys were pruned to defaults
	if not next(self.currentChar[auraID]) then
		self.currentChar[auraID] = nil;
	end
end

---Commits all four character-specific runtime fields from a profileOptionData working
---copy into SippyCupCharDB via SetCharSetting in a single atomic call.
---@param auraID number
---@param profileOptionData SippyCupProfile
function Database:CommitCharState(auraID, profileOptionData)
	self:SetCharSetting(auraID, "currentInstanceID", profileOptionData.currentInstanceID);
	self:SetCharSetting(auraID, "currentStacks", profileOptionData.currentStacks);
	self:SetCharSetting(auraID, "currentItemID", profileOptionData.currentItemID);
	self:SetCharSetting(auraID, "lastItemCount", profileOptionData.lastItemCount);
end

---Commits a profileOptionData working copy into both the live aura lookup tables and
---SippyCupCharDB. Use only on the fallback path where profileOptionData is a temporary
---GetOption copy and not the live auraToProfile reference.
---Does not perform live aura queries; trusts the values already set on profileOptionData.
---@param auraID number
---@param profileOptionData SippyCupProfile
function Database:CommitFullState(auraID, profileOptionData)
	if not profileOptionData then return; end;

	local castAuraID = profileOptionData.castAura or auraID;
	local optionData = SC.Options.ByAuraID[auraID];

	if profileOptionData.enable then
		self.auraToProfile[auraID] = profileOptionData;
		self.castAuraToProfile[castAuraID] = profileOptionData;

		local instanceID = profileOptionData.currentInstanceID;
		if instanceID then
			self.instanceToProfile[instanceID] = profileOptionData;
		end

		if profileOptionData.untrackableByAura and optionData and optionData.itemID then
			self.untrackableByAuraProfile[optionData.itemID] = profileOptionData;
		end
	else
		self.auraToProfile[auraID] = nil;
		self.castAuraToProfile[castAuraID] = nil;

		local instanceID = profileOptionData.currentInstanceID;
		if instanceID then
			self.instanceToProfile[instanceID] = nil;
		end

		if profileOptionData.untrackableByAura and optionData and optionData.itemID then
			self.untrackableByAuraProfile[optionData.itemID] = nil;
		end
	end

	self:CommitCharState(auraID, profileOptionData);
end

---Defaults are layered with the active profile and char DB overrides.
---The returned table is a copy; changes are not applied automatically.
---@param auraID number The aura ID to look up.
---@return SippyCupProfile? option The merged option, or nil if no defaults exist.
function Database:GetOption(auraID)
	local profileDefaults = self.defaults[auraID];
	if not profileDefaults then return nil; end

	local profileOverride = self.currentProfile and self.currentProfile[auraID];
	local result = mergeTables(profileDefaults, profileOverride or {});

	local charDefaults = self.charDefaults[auraID];
	if charDefaults then
		local charOverride = self.currentChar and self.currentChar[auraID];
		local charMerged = mergeTables(charDefaults, charOverride or {});
		for k, v in pairs(charMerged) do
			result[k] = v;
		end
	end

	return result;
end

---@alias SippyCupGlobalSettingKey
---| "AlertSound"
---| "AlertSoundID"
---| "DebugLevel"
---| "FlashTaskbar"
---| "Flyway"
---| "InsufficientReminder"
---| "MinimapButton"
---| "MSPStatusCheck"
---| "NewFeatureNotification"
---| "PopupPosition"
---| "PreExpirationChecks"
---| "PreExpirationLeadTimer"
---| "ProjectionPrismPreExpirationLeadTimer"
---| "ReflectingPrismPreExpirationLeadTimer"
---| "UseToyCooldown"
---| "WelcomeMessage"

---Returns a global setting, merging defaults with stored values for tables.
---@param key SippyCupGlobalSettingKey
---@return any
function Database:GetGlobalSetting(key)
	if not SippyCupDB then SippyCupDB = {}; end
	if not SippyCupDB.global then SippyCupDB.global = {}; end

	local stored = SippyCupDB.global[key];
	local def = self.globalDefaults[key];

	if type(def) == "table" then
		if stored then
			return mergeTables(def, stored);
		else
			-- Initialize stored table with shallow copy to keep live reference
			local init =  SC.Utils.ShallowCopy(def);
			SippyCupDB.global[key] = init;
			return init;
		end
	end

	-- Return primitive or nil
	if stored ~= nil then return stored; end
	return def;
end

---Stores a global setting. Table values are merged into the existing stored table in place,
---preserving keys written by LibDBIcon (e.g. minimapPos) that are not part of our defaults.
---@param key SippyCupGlobalSettingKey
---@param value any
function Database:SetGlobalSetting(key, value)
	if not SippyCupDB then SippyCupDB = {}; end
	if not SippyCupDB.global then SippyCupDB.global = {}; end

	local def = self.globalDefaults[key];

	if type(value) == "table" then
		-- Merge into the existing table to preserve LibDBIcon-managed keys.
		SippyCupDB.global[key] = SippyCupDB.global[key] or {};
		for k, v in pairs(value) do
			SippyCupDB.global[key][k] = v;
		end
	elseif value == def then
		SippyCupDB.global[key] = nil;
	else
		SippyCupDB.global[key] = value;
	end

	self:refreshUI();
end

SC.Database = Database;
