-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local _, SIPPYCUP = ...;
local L = SIPPYCUP.L;

---NewConsumable creates a new consumable object with the specified parameters.
---Initializes the consumable with properties like ID, item ID, location, category, profile, icon, stacks, and max stacks.
---@param params table A table containing parameters for the new consumable.
---@param params.auraID number The consumable's aura ID.
---@param params.itemID number The consumable's item ID.
---@param params.loc string The consumable's localization key.
---@param params.category string The consumable's category (e.g., potion, food).
---@param params.profile table The consumable's associated DB profile.
---@param params.icon string The consumable's icon texture name.
---@param params.stacks boolean|number? Whether the consumable is capable of having stacks (optional, defaults to `false`).
---@param params.maxStacks number? The consumable's max stack amount it can achieve (optional, defaults to `1`).
---@return table consumable The created consumable object.
local function NewConsumable(params)
	return {
		auraID = params.auraID,
		itemID = params.itemID,
		loc = params.loc,
		category = params.category,
		profile = params.profile,
		icon = params.icon,
		stacks = params.stacks or false,
		maxStacks = params.maxStacks or 1,
	}
end

SIPPYCUP.Consumables = {};
SIPPYCUP.Consumables.ByAuraID = {};
SIPPYCUP.Consumables.ByName = {};

SIPPYCUP.Consumables.Data = {
	NewConsumable{ auraID = 1213428, itemID = 234526, loc = "ARCHIVISTS_CODEX", category = "EFFECT", profile = "archivistsCodex", icon = "inv_7xp_inscription_talenttome02" },
	NewConsumable{ auraID = 357489, itemID = 187421, loc = "ASHEN_LINIMENT", category = "EFFECT", profile = "ashenLiniment", icon = "inv_misc_food_legion_goooil_bottle" },
	NewConsumable{ auraID = 185562, itemID = 124671, loc = "DARKMOON_FIREWATER", category = "SIZE", profile = "darkmoonFirewater", icon = "inv_misc_flaskofvolatility" },
	NewConsumable{ auraID = 8212, itemID = 6662, loc = "ELIXIR_OF_GIANT_GROWTH", category = "SIZE", profile = "elixirOfGiantGrowth", icon = "inv_potion_10" },
	NewConsumable{ auraID = 2336, itemID = 2460, loc = "ELIXIR_OF_TONGUES", category = "EFFECT", profile = "elixirOfTongues", icon = "inv_potion_12" },
	NewConsumable{ auraID = 398458, itemID = 202290, loc = "FIREWATER_SORBET", category = "SIZE", profile = "firewaterSorbet", icon = "inv_cooking_100_firewatersorbet" },
	NewConsumable{ auraID = 454799, itemID = 225253, loc = "FLICKERING_FLAME_HOLDER", category = "EFFECT", profile = "flickeringFlameHolder", icon = "trade_archaeology_draenei candelabra" },
	NewConsumable{ auraID = 58468, itemID = 43478, loc = "GIGANTIC_FEAST", category = "SIZE", profile = "giganticFeast", icon = "ability_hunter_pet_boar" },
	NewConsumable{ auraID = 185394, itemID = 124640, loc = "INKY_BLACK_POTION", category = "EFFECT", profile = "inkyBlackPotion", icon = "inv_potion_132" },
	NewConsumable{ auraID = 1218300, itemID = 235703, loc = "NOGGENFOGGER_SELECT_DOWN", category = "SIZE", profile = "noggenfoggerSelectDOWN", icon = "inv_potion_140", stacks = true, maxStacks = 10 },
	NewConsumable{ auraID = 1218297, itemID = 235704, loc = "NOGGENFOGGER_SELECT_UP", category = "SIZE", profile = "noggenfoggerSelectUP", icon = "inv_potion_141", stacks = true, maxStacks = 10 },
	NewConsumable{ auraID = 368038, itemID = 190739, loc = "PROVIS_WAX", category = "EFFECT", profile = "provisWax", icon = "inv_misc_food_legion_flaked sea salt" },
	NewConsumable{ auraID = 53805, itemID = 40195, loc = "PYGMY_OIL", category = "SIZE", profile = "pygmyOil", icon = "inv_potion_07", stacks = true, maxStacks = 10 },
	NewConsumable{ auraID = 1213974, itemID = 234287, loc = "RADIANT_FOCUS", category = "EFFECT", profile = "radiantFocus", icon = "inv_radiant_remnant" },
	NewConsumable{ auraID = 1214287, itemID = 234527, loc = "SACREDITES_LEDGER", category = "EFFECT", profile = "sacreditesLedger", icon = "inv_offhand_1h_priest_c_01" },
	NewConsumable{ auraID = 58479, itemID = 43480, loc = "SMALL_FEAST", category = "SIZE", profile = "smallFeast", icon = "ability_hunter_pet_boar" },
	NewConsumable{ auraID = 442106, itemID = 218107, loc = "SPARKBUG_JAR", category = "EFFECT", profile = "sparkbugJar", icon = "inv_first_aid_70_ jar" },
	NewConsumable{ auraID = 404840, itemID = 204370, loc = "STINKY_BRIGHT_POTION", category = "EFFECT", profile = "stinkyBrightPotion", icon = "inv_trade_alchemy_dpotion_c1a" },
	NewConsumable{ auraID = 254544, itemID = 153192, loc = "SUNGLOW", category = "EFFECT", profile = "sunglow", icon = "inv_drink_29_sunkissedwine" },
	NewConsumable{ auraID = 1213975, itemID = 234466, loc = "TATTERED_ARATHI_PRAYER_SCROLL", category = "EFFECT", profile = "tatteredArathiPrayerScroll", icon = "inv_10_inscription2_scroll3_color3" },
	NewConsumable{ auraID = 17038, itemID = 12820, loc = "WINTERFALL_FIREWATER", category = "SIZE", profile = "winterfallFirewater", icon = "inv_potion_92" },
}

-- Add loc data and create ByAuraID consumable option.
for _, consumable in ipairs(SIPPYCUP.Consumables.Data) do
	consumable.name = L[consumable.loc];
	SIPPYCUP.Consumables.ByAuraID[consumable.auraID] = consumable;
	SIPPYCUP.Consumables.ByName[consumable.name] = consumable;
end


local function normalize(str)
	return str
		:gsub("á", "a"):gsub("à", "a"):gsub("ã", "a"):gsub("ä", "a"):gsub("â", "a")
		:gsub("é", "e"):gsub("è", "e"):gsub("ê", "e"):gsub("ë", "e")
		:gsub("í", "i"):gsub("ì", "i"):gsub("î", "i"):gsub("ï", "i")
		:gsub("ó", "o"):gsub("ò", "o"):gsub("õ", "o"):gsub("ö", "o"):gsub("ô", "o")
		:gsub("ú", "u"):gsub("ù", "u"):gsub("û", "u"):gsub("ü", "u")
		:gsub("ç", "c"):gsub("ñ", "n")
		:gsub("Á", "A"):gsub("À", "A"):gsub("Ã", "A"):gsub("Ä", "A"):gsub("Â", "A")
		:gsub("É", "E"):gsub("È", "E"):gsub("Ê", "E"):gsub("Ë", "E")
		:gsub("Í", "I"):gsub("Ì", "I"):gsub("Î", "I"):gsub("Ï", "I")
		:gsub("Ó", "O"):gsub("Ò", "O"):gsub("Õ", "O"):gsub("Ö", "O"):gsub("Ô", "O")
		:gsub("Ú", "U"):gsub("Ù", "U"):gsub("Û", "U"):gsub("Ü", "U")
		:gsub("Ç", "C"):gsub("Ñ", "N");
end

table.sort(SIPPYCUP.Consumables.Data, function(a, b)
	return normalize(a.name:lower()) < normalize(b.name:lower());
end)
