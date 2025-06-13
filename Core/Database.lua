-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local L = SIPPYCUP.L;
SIPPYCUP.Database = {};
local AceConfigDialog = LibStub("AceConfigDialog-3.0");
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0");

---Default saved variables structure for SIPPYCUP.
---Contains global and profile-level settings used across sessions.
---@class SIPPYCUPDefaults
---@field global SIPPYCUPGlobalSettings Global settings shared across profiles, holds defaults.
---@field profile table<string, SIPPYCUPProfileConsumable>

---Structure of global settings in SIPPYCUP.
---@class SIPPYCUPGlobalSettings
---@field AlertSound boolean Whether the popup alert sound is enabled.
---@field AlertSoundID string The sound ID used for popup alerts.
---@field FlashTaskbar boolean Whether the taskbar should flash on popup alert.
---@field PopupIcon boolean Whether to show an item icon in the popup.
---@field PopupPosition string Position of the popup (e.g., "top", "bottom").
---@field WelcomeMessage boolean Whether to show a welcome message on session startup.
---@field MinimapButton SIPPYCUPMinimapSettings Settings for the minimap button.

---Settings for the minimap button.
---@class SIPPYCUPMinimapSettings
---@field hide boolean Whether the minimap button is hidden completely.
---@field ShowAddonCompartmentButton boolean Whether to show the addon compartment button.

---@type SIPPYCUPDefaults
SIPPYCUP.Database.defaults = {
	global = {
		AlertSound = true,
		AlertSoundID = "fx_ship_bell_chime_02",
		FlashTaskbar = true,
		MSPStatusCheck = false,
		PopupIcon = false,
		PopupPosition = "top",
		PreExpirationChecks = true,
		WelcomeMessage = true,
		MinimapButton = {
			hide = false,
			ShowAddonCompartmentButton = true,
		},
	},
	profile = {}
}

---@class SIPPYCUPProfileConsumable
---@field enable boolean Whether the consumable is enabled for tracking.
---@field desiredStacks number Number of stacks user wants.
---@field currentInstanceID number? Current aura instance ID being tracked.
---@field currentStacks number Current number of stacks.
---@field aura number The aura ID associated with this consumable.
---@field nonTrackable boolean Whether the consumable cannot be tracked (no aura ID).
for _, consumable in ipairs(SIPPYCUP.Consumables.Data) do
	local profileKey = consumable.profile;
	local spellID = consumable.auraID;
	local nonTrackable = consumable.nonTrackable;

	-- sanity: skip any Data entries missing those required fields
	if profileKey and spellID then
		SIPPYCUP.Database.defaults.profile[profileKey] = {
			enable = false,
			desiredStacks = 1,
			currentInstanceID = nil,
			currentStacks = 0,
			aura = spellID,
			nonTrackable = nonTrackable,
		};
	end
end

---Find profile entry by instance ID (linear scan)
---@param auraInstanceID number
---@return table|nil profileData
function SIPPYCUP.Database:FindByInstanceID(auraInstanceID)
	if not auraInstanceID then
		return nil;
	end

	for _, profileConsumableData in pairs(SIPPYCUP.db.profile) do
		if profileConsumableData.currentInstanceID == auraInstanceID then
			return profileConsumableData;
		end
	end

	return nil;
end

SIPPYCUP.Database.auraToProfile = {}; -- auraID --> profile data
SIPPYCUP.Database.instanceToProfile = {}; -- instanceID --> profile data
SIPPYCUP.Database.nonTrackableProfile = {}; -- itemID --> profile data (only if nontrackable)

---RebuildAuraMap scans the current profile and (re)builds the fast lookup tables for enabled consumables.
---@return nil
function SIPPYCUP.Database.RebuildAuraMap()
	-- clear out tables
	wipe(SIPPYCUP.Database.auraToProfile);
	wipe(SIPPYCUP.Database.instanceToProfile);
	wipe(SIPPYCUP.Database.nonTrackableProfile);

	for _, profileConsumableData in pairs(SIPPYCUP.db.profile) do
		if profileConsumableData.enable and profileConsumableData.aura then
			SIPPYCUP.Database.auraToProfile[profileConsumableData.aura] = profileConsumableData;

			-- If we don't have a currentInstanceID, check if the aura is active and if so grab the current instanceID
			if not profileConsumableData.currentInstanceID then
				local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(profileConsumableData.aura);
				if auraInfo then
					profileConsumableData.currentInstanceID = auraInfo.auraInstanceID;
				end
			end

			-- Then we try to map that if it's not nil.
			if profileConsumableData.currentInstanceID then
				-- We make sure to confirm that this data is still correct, if not we kind of have to nil it.
				local auraInfo = C_UnitAuras.GetAuraDataByAuraInstanceID("player", profileConsumableData.currentInstanceID);
				if auraInfo then
					SIPPYCUP.Database.instanceToProfile[profileConsumableData.currentInstanceID] = profileConsumableData;
				else
					profileConsumableData.currentInstanceID = nil;
				end
			end

			-- If the item is nonTrackable, we'll map that too.
			if profileConsumableData.nonTrackable then
				local consumableData = SIPPYCUP.Consumables.ByAuraID[profileConsumableData.aura];
				SIPPYCUP.Database.nonTrackableProfile[consumableData.itemID] = profileConsumableData;
			end
		end
	end
end

---FindMatchingConsumable returns consumable profile data matching a given spell ID or aura instance ID.
---@param spellId number? The spell ID to match against (optional).
---@param instanceID number? The instance ID to match against (optional).
---@param itemID number? The itemID ID to match against (optional).
---@return table|nil profileConsumableData The matching consumable profile data if found, or nil if not.
function SIPPYCUP.Database.FindMatchingConsumable(spellId, instanceID, itemID)
	if spellId then
		return SIPPYCUP.Database.auraToProfile[spellId];
	elseif instanceID then
		return SIPPYCUP.Database.instanceToProfile[instanceID];
	elseif itemID then
		return SIPPYCUP.Database.nonTrackableProfile[itemID];
	end

	return nil;
end

---RefreshConfig updates the options tables and handles checking stacks on enabled and active consumables.
---@return nil
local function RefreshConfig()
	local title = SIPPYCUP.AddonMetadata.title;

	-- Register the options tables anew to update its values after something gets changed profile-wise.
	local categories = { "Appearance", "Effect", "Handheld", "Placement", "Size" };
	for _, cat in ipairs(categories) do
		AceConfigRegistry:RegisterOptionsTable(title.."_"..cat, SIPPYCUP_CONFIG.GenerateCategory(cat));
	end

	-- On profile switch, we do a full stacksize check (which will also rebuild the auramap) on all active (and non-active on MSP true) enabled.
	SIPPYCUP.Consumables.RefreshStackSizes(SIPPYCUP.db.global.MSPStatusCheck);
end


---Setup initializes the database, registers callbacks, and configures options tables for the addon.
---@return nil
function SIPPYCUP.Database.Setup()
	local title = SIPPYCUP.AddonMetadata.title;

	SIPPYCUP.db = LibStub("AceDB-3.0"):New("SippyCupDB", SIPPYCUP.Database.defaults, true);
	SIPPYCUP.db.RegisterCallback(SIPPYCUP, "OnProfileChanged", RefreshConfig);
	SIPPYCUP.db.RegisterCallback(SIPPYCUP, "OnProfileCopied", RefreshConfig);
	SIPPYCUP.db.RegisterCallback(SIPPYCUP, "OnProfileReset", RefreshConfig);

	AceConfigRegistry:RegisterOptionsTable(title, SIPPYCUP_CONFIG.GenerateGeneral());
	AceConfigDialog:AddToBlizOptions(title, title);

	local categories = { "Appearance", "Effect", "Handheld", "Placement", "Size" };
	for _, cat in ipairs(categories) do
		AceConfigRegistry:RegisterOptionsTable(title .. "_" .. cat, SIPPYCUP_CONFIG.GenerateCategory(cat:upper()));
		AceConfigDialog:AddToBlizOptions(title .. "_" .. cat, L["OPTIONS_CONSUMABLE_" .. cat:upper() .. "_TITLE"], title);
	end

	AceConfigRegistry:RegisterOptionsTable(title .. "_Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(SIPPYCUP.db));
	SIPPYCUP.ProfilesFrame, SIPPYCUP.ProfilesFrameID = AceConfigDialog:AddToBlizOptions(title .. "_Profiles", "Profiles", title);
end
