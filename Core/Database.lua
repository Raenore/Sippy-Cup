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
		WelcomeMessage = true,
		MinimapButton = {
			hide = false,
			ShowAddonCompartmentButton = true,
		},
	},
	profile = {}
}

local consumables = {
	archivistsCodex = 1213428,
	ashenLiniment = 357489,
	darkmoonFirewater = 185562,
	elixirOfGiantGrowth = 8212,
	elixirOfTongues = 2336,
	firewaterSorbet = 398458,
	flickeringFlameHolder = 454799,
	giganticFeast = 58468,
	inkyBlackPotion = 185394,
	noggenfoggerSelectDOWN = 1218300,
	noggenfoggerSelectUP = 1218297,
	provisWax = 368038,
	pygmyOil = 53805,
	radiantFocus = 1213974,
	sacreditesLedger = 1214287,
	smallFeast = 58479,
	sparkbugJar = 442106,
	stinkyBrightPotion = 404840,
	sunglow = 254544,
	tatteredArathiPrayerScroll = 1213975,
	winterfallFirewater = 17038,
}

---@class SIPPYCUPProfileConsumable
---@field enable boolean Whether the consumable is enabled for tracking.
---@field desiredStacks number Number of stacks user wants.
---@field currentInstanceID number? Current aura instance ID being tracked.
---@field currentStacks number Current number of stacks.
---@field aura number The aura ID associated with this consumable.
for name, consumableAura in pairs(consumables) do
	SIPPYCUP.Database.defaults.profile[name] = {
		enable = false,
		desiredStacks = 1,
		currentInstanceID = nil,
		currentStacks = 0,
		aura = consumableAura,
	}
end

---RefreshConfig updates the options tables and handles checking stacks on enabled and active consumables.
---@return nil
local function RefreshConfig()
	local title = SIPPYCUP.AddonMetadata.title;

	-- Register the options tables anew to update its values after something gets changed profile-wise.
	AceConfigRegistry:RegisterOptionsTable(title .. "_Effect", SIPPYCUP_CONFIG.GenerateCategory("EFFECT"));
	AceConfigRegistry:RegisterOptionsTable(title .. "_Size", SIPPYCUP_CONFIG.GenerateCategory("SIZE"));

	-- Check if any enabled consumables are active, run the required popup logic.
	SIPPYCUP.Auras.CheckConsumableStackSizes(SIPPYCUP.db.global.MSPStatusCheck);
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
	AceConfigRegistry:RegisterOptionsTable(title .. "_Effect", SIPPYCUP_CONFIG.GenerateCategory("EFFECT"));
	AceConfigRegistry:RegisterOptionsTable(title .. "_Size", SIPPYCUP_CONFIG.GenerateCategory("SIZE"));
	AceConfigRegistry:RegisterOptionsTable(title .. "_Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(SIPPYCUP.db));

	AceConfigDialog:AddToBlizOptions(title, title);
	AceConfigDialog:AddToBlizOptions(title .. "_Effect", L.OPTIONS_CONSUMABLE_EFFECT_TITLE, title);
	AceConfigDialog:AddToBlizOptions(title .. "_Size", L.OPTIONS_CONSUMABLE_SIZE_TITLE, title);
	SIPPYCUP.ProfilesFrame, SIPPYCUP.ProfilesFrameID = AceConfigDialog:AddToBlizOptions(title .. "_Profiles", "Profiles", title);
end
