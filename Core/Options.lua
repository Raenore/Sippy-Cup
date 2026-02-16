-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Options = {};
---@type table<number, SIPPYCUPOption>
SIPPYCUP.Options.ByAuraID = {};
---@type table<number, SIPPYCUPOption>
SIPPYCUP.Options.ByItemID = {};
---@type table<string, SIPPYCUPOption>
SIPPYCUP.Options.ByName = {};

SIPPYCUP.Options.Type = {
	CONSUMABLE = 0,
	TOY = 1,
};

---@class SIPPYCUPOption: table
---@field type string Whether this option is a consumable (0) or toy (1).
---@field auraID number The option's aura ID.
---@field itemID number The option's item ID.
---@field loc string The option's localization key (auto-gen).
---@field category string The option's category (e.g., potion, food).
---@field profile table The option's associated DB profile (auto-gen).
---@field icon string The option's icon texture name.
---@field stacks boolean Whether the option is capable of having stacks, defaults to `false`.
---@field maxStacks number The option's max stack amount it can achieve, defaults to `1`.
---@field preExpiration boolean The option's pre-expiration settings, defaults to `false`.
---@field unrefreshable boolean Whether the option is can be refreshed, on false it means you lose the stack with no effect.
---@field itemTrackable boolean Whether the option can only be tracked through the item itself (cooldowns, etc.).
---@field spellTrackable boolean Whether the option can only be tracked through the spell itself (cooldowns, etc.).
---@field delayedAura boolean Whether the option is applied after a delay (e.g. food buff), on false a buff is applied instantly.
---@field cooldownMismatch boolean Whether the option has a mismatch in cooldowns (cd longer than buff lasts), on false there is no mismatch.


---NewOption creates a new object with the specified parameters.
---@param params SIPPYCUPOption A table containing parameters for the new option.
---@return SIPPYCUPOption
local function NewOption(params)
	return {
		type  = params.type or SIPPYCUP.Options.Type.CONSUMABLE,
		auraID = params.auraID,
		itemID = params.itemID,
		loc = params.loc,
		category = params.category,
		profile = params.profile,
		icon = params.icon,
		stacks = params.stacks or false,
		maxStacks = params.maxStacks or 1,
		preExpiration = params.preExpiration or false,
		unrefreshable = params.unrefreshable or false,
		itemTrackable = params.itemTrackable or false,
		spellTrackable = params.spellTrackable or false,
		delayedAura = params.delayedAura or false,
		cooldownMismatch = params.cooldownMismatch or false,
		buildAdded = params.buildAdded or nil,
	};
end

--[[
Pre-Expiration:
0 = Cannot show pre-expire (multi-stack options).
1 = Can pre-expire (resets to initial max).
]]

SIPPYCUP.Options.Data = {
	-- CONSUMABLES
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 1213428, itemID = 234526, category = "HANDHELD", preExpiration = true }, -- ARCHIVISTS_CODEX
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 357489, itemID = 187421, category = "EFFECT", preExpiration = true }, -- ASHEN_LINIMENT
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 382761, itemID = 197767, category = "APPEARANCE", preExpiration = true }, -- BLUBBERY_MUFFIN
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 1222839, itemID = 237335, category = "HANDHELD", preExpiration = true }, -- COLLECTIBLE_PINEAPPLETINI_MUG
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 185562, itemID = 124671, category = "SIZE", unrefreshable = true }, -- DARKMOON_FIREWATER
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 1213663, itemID = 234282, category = "PLACEMENT", itemTrackable = true }, -- DECORATIVE_YARD_FLAMINGO
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 1222835, itemID = 237330, category = "HANDHELD", preExpiration = true }, -- DISPOSABLE_HAMBURGER
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 1222833, itemID = 237331, category = "HANDHELD", preExpiration = true }, -- DISPOSABLE_HOTDOG
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 8212, itemID = 6662, category = "SIZE", preExpiration = true }, -- ELIXIR_OF_GIANT_GROWTH
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 2336, itemID = 2460, category = "EFFECT", preExpiration = true }, -- ELIXIR_OF_TONGUES
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 162906, itemID = 112321, category = "EFFECT", preExpiration = true }, -- ENCHANTED_DUST
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 398458, itemID = 202290, category = "SIZE", preExpiration = true, delayedAura = true }, -- FIREWATER_SORBET
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 393977, itemID = 201427, category = "EFFECT" }, -- FLEETING_SANDS
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 454799, itemID = 225253, category = "HANDHELD", preExpiration = true }, -- FLICKERING_FLAME_HOLDER
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 58468, itemID = 43478, category = "SIZE", preExpiration = true, delayedAura = true }, -- GIGANTIC_FEAST
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 244014, itemID = 151257, category = "HANDHELD", preExpiration = true }, -- GREEN_DANCE_STICK
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 1222840, itemID = 237334, category = "HANDHELD", preExpiration = true }, -- HALF_EATEN_TAKEOUT
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 443688, itemID = 216708, category = "PLACEMENT", spellTrackable = true }, -- HOLY_CANDLE
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 185394, itemID = 124640, category = "EFFECT", preExpiration = true }, -- INKY_BLACK_POTION
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 1218300, itemID = 235703, category = "SIZE", stacks = true, maxStacks = 10, preExpiration = true }, -- NOGGENFOGGER_SELECT_DOWN
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 1218297, itemID = 235704, category = "SIZE", stacks = true, maxStacks = 10, preExpiration = true }, -- NOGGENFOGGER_SELECT_UP
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 374957, itemID = 193029, category = "PRISM", preExpiration = true }, -- PROJECTION_PRISM
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 368038, itemID = 190739, category = "EFFECT", preExpiration = true }, -- PROVIS_WAX
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 244015, itemID = 151256, category = "HANDHELD", preExpiration = true }, -- PURPLE_DANCE_STICK
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 53805, itemID = 40195, category = "SIZE", stacks = true, maxStacks = 10 }, -- PYGMY_OIL
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 393979, itemID = 201428, category = "EFFECT" }, -- QUICKSILVER_SANDS
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 1213974, itemID = 234287, category = "EFFECT", preExpiration = true }, -- RADIANT_FOCUS
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 1214287, itemID = 234527, category = "HANDHELD", preExpiration = true }, -- SACREDITES_LEDGER
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 163219, itemID = 112384, category = "PRISM", preExpiration = true }, -- REFLECTING_PRISM
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 279742, itemID = 163695, category = "EFFECT" }, -- SCROLL_OF_INNER_TRUTH
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 1222834, itemID = 237332, category = "PLACEMENT", spellTrackable = true }, -- SINGLE_USE_GRILL
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 58479, itemID = 43480, category = "SIZE", preExpiration = true, delayedAura = true }, -- SMALL_FEAST
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 382729, itemID = 197766, category = "HANDHELD", preExpiration = true }, -- SNOW_IN_A_CONE
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 442106, itemID = 218107, category = "HANDHELD", preExpiration = true }, -- SPARKBUG_JAR
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 404840, itemID = 204370, category = "EFFECT", preExpiration = true }, -- STINKY_BRIGHT_POTION
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 254544, itemID = 153192, category = "EFFECT", unrefreshable = true }, -- SUNGLOW
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 1213975, itemID = 234466, category = "EFFECT", preExpiration = true }, -- TATTERED_ARATHI_PRAYER_SCROLL
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 393989, itemID = 201436, category = "EFFECT", preExpiration = true }, -- TEMPORALLY_LOCKED_SANDS
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 393994, itemID = 201438, category = "EFFECT", preExpiration = true }, -- WEARY_SANDS
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 17038, itemID = 12820, category = "SIZE", preExpiration = true }, -- WINTERFALL_FIREWATER
	-- TOYS
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 393985, itemID = 201435, category = "EFFECT", cooldownMismatch = true }, -- Shuffling Sands
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 427782, itemID = 210975, category = "EFFECT" }, -- Date Simulation Modulator
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 385792, itemID = 198264, category = "EFFECT" }, -- Centralized Precipitation Emitter
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 385085, itemID = 198206, category = "EFFECT" }, -- Environmental Emulator
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 314988, itemID = 173984, category = "EFFECT", cooldownMismatch = true }, -- Scroll of Aeons
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 279997, itemID = 163742, category = "EFFECT", preExpiration = true }, -- Heartsbane Grimoire
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 409891, itemID = 205418, category = "EFFECT", cooldownMismatch = true }, -- Blazing Shadowflame Cinder

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 453163, itemID = 224552, category = "HANDHELD" }, -- Cave Spelunker's Torch
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 203533, itemID = 133997, category = "HANDHELD" }, -- Black Ice
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 203820, itemID = 134007, category = "HANDHELD" }, -- Eternal Black Diamond Ring
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 203657, itemID = 134004, category = "HANDHELD" }, -- Noble's Eternal Elementium Signet
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 465642, itemID = 228789, category = "HANDHELD" }, -- Coldflame Ring
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 1215495, itemID = 235041, category = "HANDHELD" }, -- Cyrce's Circlet
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 1232024, itemID = 242323, category = "HANDHELD", preExpiration = true }, -- Chowdar's Favorite Ribbon
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 341678, itemID = 182694, category = "HANDHELD", preExpiration = true }, -- Stylish Black Parasol
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 341682, itemID = 182695, category = "HANDHELD", preExpiration = true }, -- Weathered Purple Parasol
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 341624, itemID = 182696, category = "HANDHELD", preExpiration = true }, -- The Countess's Parasol
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 431949, itemID = 212500, category = "HANDHELD", preExpiration = true }, -- Delicate Silk Parasol
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 432001, itemID = 212525, category = "HANDHELD", preExpiration = true }, -- Delicate Ebony Parasol
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 431998, itemID = 212524, category = "HANDHELD", preExpiration = true }, -- Delicate Crimson Parasol
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 431994, itemID = 212523, category = "HANDHELD", preExpiration = true }, -- Delicate Jade Parasol
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 196067, itemID = 130251, category = "HANDHELD" }, -- JewelCraft
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 200015, itemID = 132518, category = "HANDHELD" }, -- Blingtron's Circuit Design Tutorial

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 279076, itemID = 163211, category = "PLACEMENT", spellTrackable = true }, -- Akunda's Firesticks
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 401672, itemID = 203757, category = "PLACEMENT", spellTrackable = true }, -- Brazier of Madness
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 254240, itemID = 153039, category = "PLACEMENT", spellTrackable = true }, -- Crystalline Campfire
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 171549, itemID = 116435, category = "PLACEMENT", spellTrackable = true, cooldownMismatch = true }, -- Cozy Bonfire
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 148553, itemID = 104309, category = "PLACEMENT", spellTrackable = true, cooldownMismatch = true }, -- Eternal Kiln
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 188401, itemID = 127652, category = "PLACEMENT", spellTrackable = true }, -- Felflame Campfire
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 93636, itemID = 67097, category = "PLACEMENT", spellTrackable = true }, -- Grim Campfire
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 223297, itemID = 128536, category = "PLACEMENT", spellTrackable = true }, -- Leylight Brazier
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 172809, itemID = 117573, category = "PLACEMENT", spellTrackable = true, cooldownMismatch = true }, -- Wayfarer's Bonfire
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 383081, itemID = 198402, category = "PLACEMENT", spellTrackable = true }, -- Maruuk Cooking Pot
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 340241, itemID = 182780, category = "PLACEMENT", spellTrackable = true }, -- Muckpool Cookpot
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 171760, itemID = 116757, category = "PLACEMENT", spellTrackable = true }, -- Steamworks Sausage Grill
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 453265, itemID = 219403, category = "PLACEMENT", spellTrackable = true }, -- Stonebound Lantern
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 388258, itemID = 199892, category = "PLACEMENT", spellTrackable = true }, -- Tuskarr Traveling Soup Pot
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 345745, itemID = 184404, category = "PLACEMENT", spellTrackable = true }, -- Ever-Abundant Hearth
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 468291, itemID = 234473, category = "PLACEMENT", preExpiration = true }, -- Soweezi's Comfy Lawn Chair

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 383268, itemID = 198428, category = "EFFECT", preExpiration = true }, -- Tuskarr Dinghy
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 124036, itemID = 85500, category = "EFFECT", preExpiration = true }, -- Anglers Fishing Raft
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 344646, itemID = 183989, category = "EFFECT", itemTrackable = true }, -- Dredger Barrow Racer

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 455494, itemID = 225659, category = "PLACEMENT" }, -- Arathi Book Collection
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 1214519, itemID = 235050, category = "PLACEMENT" }, -- Desk-in-a-Box

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 143034, itemID = 97994, category = "SIZE", preExpiration = true }, -- Darkmoon Seesaw / Childlike Wonder

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 392700, itemID = 200960, category = "APPEARANCE", preExpiration = true }, -- Seed of Renewed Souls

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 451985, itemID = 224192, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Practice Ravager
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 462934, itemID = 228705, category = "APPEARANCE", spellTrackable = true, cooldownMismatch = true }, -- Arachnoserum
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 462683, itemID = 228698, category = "APPEARANCE", spellTrackable = true }, -- Candleflexer's Dumbbell
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 455426, itemID = 225641, category = "APPEARANCE", spellTrackable = true, cooldownMismatch = true }, -- Illusive Kobyss Lure
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 371470, itemID = 191891, category = "APPEARANCE", spellTrackable = true, cooldownMismatch = true }, -- Professor Chirpsnide's Im-PECK-able Harpy Disguise

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 474100, itemID = 233486, category = "HANDHELD", preExpiration = true }, -- Hallowfall Supply Cache
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 1215461, itemID = 235015, category = "HANDHELD", preExpiration = true }, -- Awakened Supply Crate

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 160688, itemID = 108743, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Deceptia's Smoldering Boots
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 277572, itemID = 159749, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Haw'li's Hot & Spicy Chili
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 415089, itemID = 206993, category = "EFFECT", preExpiration = true }, -- Investi-gator's Pocketwatch
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 462145, itemID = 228413, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Lampyridae Lure
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 170869, itemID = 116115, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Blazing Wings
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 45418, itemID = 188701, category = "EFFECT", spellTrackable = true }, -- Fire Festival Batons

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 45416, itemID = 188699, category = "EFFECT" }, -- Insulated Dancing Insoles
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 222206, itemID = 141649, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Set of Matches

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 222907, itemID = 140231, category = "APPEARANCE", spellTrackable = true }, -- Narcissa's Mirror
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 187356, itemID = 127696, category = "APPEARANCE", spellTrackable = true, cooldownMismatch = true }, -- Magic Pet Mirror

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 465887, itemID = 238850, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Arathi Entertainer's Flame
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 162402, itemID = 108739, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Pretty Draenor Pearl
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 166592, itemID = 113375, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Vindicator's Armor Polish Kit

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 192930, itemID = 129055, category = "EFFECT" }, -- Shoe Shine Kit

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 290280, itemID = 166790, category = "APPEARANCE", spellTrackable = true, cooldownMismatch = true }, -- Highborne Memento

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 1215373, itemID = 234951, category = "HANDHELD", preExpiration = true }, -- Uncracked Cold Ones / Kaja'Cola Enthusiast

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 373351, itemID = 192495, category = "EFFECT", preExpiration = true }, -- Malfunctioning Stealthman 54

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 1237584, itemID = 244470, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Etheric Victory
	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 1244178, itemID = 246903, category = "EFFECT", preExpiration = true }, -- Guise of the Phase Diver

	NewOption{ type = SIPPYCUP.Options.Type.TOY, auraID = 47770, itemID = 36863, category = "EFFECT", itemTrackable = true }, -- Decahedral Dwarven Dice

	-- Midnight
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 1250761, itemID = 250325, category = "EFFECT", preExpiration = true, buildAdded = "0.6.0|120000" }, -- Night's Embrace

	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 1281702, itemID = 268115, category = "HANDHELD", preExpiration = true, buildAdded = "0.6.1|120000" }, -- Overbaked Donut
	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 1280627, itemID = 267486, category = "HANDHELD", preExpiration = true, buildAdded = "0.6.1|120000" }, -- Simple Cup

	NewOption{ type = SIPPYCUP.Options.Type.CONSUMABLE, auraID = 987654321, itemID = 987654321, category = "EFFECT", preExpiration = true }, -- Does not exist, test
};

local function NormalizeLocName(name)
	return name:upper():gsub("[^%w]+", "_");
end

function SIPPYCUP.Options.Setup()
	local data = SIPPYCUP.Options.Data;
	local remaining = {};

	-- Build lookups
	for _, option in ipairs(data) do
		remaining[option.itemID] = true;
		SIPPYCUP.Options.ByAuraID[option.auraID] = option;
		SIPPYCUP.Options.ByItemID[option.itemID] = option;
	end

	-- Fast prune: remove invalid items before async loads
	for i = #data, 1, -1 do
		local option = data[i];

		if C_Item.GetItemInfoInstant(option.itemID) == nil then
			SIPPYCUP.Options.ByAuraID[option.auraID] = nil;
			SIPPYCUP.Options.ByItemID[option.itemID] = nil;

			table.remove(data, i);
			remaining[option.itemID] = nil;
		end
	end

	-- Early complete if nothing left
	if next(remaining) == nil then
		table.sort(data, function(a, b)
			return SIPPYCUP_TEXT.Normalize(a.name:lower()) < SIPPYCUP_TEXT.Normalize(b.name:lower());
		end);
		SIPPYCUP.Callbacks:TriggerEvent(SIPPYCUP.Events.OPTIONS_LOADED);
		return;
	end

	-- Finalize when no entries remain
	local function Finalize()
		if next(remaining) ~= nil then return end;

		table.sort(data, function(a, b)
			return SIPPYCUP_TEXT.Normalize(a.name:lower()) < SIPPYCUP_TEXT.Normalize(b.name:lower());
		end);

		SIPPYCUP.Callbacks:TriggerEvent(SIPPYCUP.Events.OPTIONS_LOADED);
	end

	-- Async load for all valid items
	for _, option in ipairs(data) do
		local item = Item:CreateFromItemID(option.itemID);

		item:ContinueOnItemLoad(function()
			-- Skip if removed by earlier pruning
			if not remaining[option.itemID] then return end;

			local name = item:GetItemName();

			option.name = name;
			option.loc = NormalizeLocName(name);

			option.profile = string.gsub(string.lower(option.loc), "_(%a)", function(c)
				return c:upper();
			end);

			option.icon = item:GetItemIcon();
			SIPPYCUP.Options.ByName[name] = option;

			remaining[option.itemID] = nil;
			Finalize();
		end);
	end
end

---RefreshStackSizes iterates over all enabled Sippy Cup options to set the correct stack sizes (startup / profile change / etc).
---@param checkAll boolean? If true, it will also check the inactive enabled ones.
---@param reset boolean? If true, all popups will be reset. Defaults to true
---@param preExpireOnly boolean? If true, only handles pre-expirations. Defaults to false
---@return nil
function SIPPYCUP.Options.RefreshStackSizes(checkAll, reset, preExpireOnly)
	-- Bail out entirely when in PvP Matches, we do not support those.
	if SIPPYCUP.States.pvpMatch then
		return;
	end

	reset = (reset ~= false);
	preExpireOnly = preExpireOnly or false;

	-- Helper to check cooldown startTime for item or spell trackable
	local function GetCooldownStartTime(option)
		local trackBySpell = false;
		local trackByItem = false;

		if option.type == SIPPYCUP.Options.Type.CONSUMABLE then
			trackBySpell = option.spellTrackable;
			trackByItem = option.itemTrackable;
		elseif option.type == SIPPYCUP.Options.Type.TOY then
			-- Always track by item if itemTrackable
			if option.itemTrackable then
				trackByItem = true;
			end

			if option.spellTrackable then
				if SIPPYCUP.global.UseToyCooldown then
					trackByItem = true;
				else
					trackBySpell = true;
				end
			end
		end

		if trackByItem then
			local startTime = C_Item.GetItemCooldown(option.itemID);
			if startTime and startTime > 0 then
				return startTime;
			end
		elseif trackBySpell then
			local spellCooldown = C_Spell.GetSpellCooldown(option.auraID);
			local startTime = spellCooldown and spellCooldown.startTime;
			if startTime and startTime > 0 then
				return startTime;
			end
		end
		return nil;
	end

	-- Reset timers and popups
	SIPPYCUP.Auras.CancelAllPreExpirationTimers();
	SIPPYCUP.Items.CancelAllItemTimers();
	if reset then
		SIPPYCUP.Popups.HideAllRefreshPopups();
	end

	-- Rebuild the aura map from the latest database data that we have.
	SIPPYCUP.Database.RebuildAuraMap();

	local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID;
	local auraToProfile = SIPPYCUP.Database.auraToProfile;
	local ByAuraID = SIPPYCUP.Options.ByAuraID;

	-- auraToProfile will iterate over all the enabled (not active!) options.
	for _, profileOptionData in pairs(auraToProfile) do
		local auraID = profileOptionData.aura;
		local auraInfo = GetPlayerAuraBySpellID(auraID);
		local optionData = ByAuraID[auraID];
		local startTime = GetCooldownStartTime(optionData);
		local active = startTime ~= nil;

		if not SIPPYCUP.States.loadingScreen then
			local preExpireFired;
			if profileOptionData.untrackableByAura then
				preExpireFired = SIPPYCUP.Items.CheckNoAuraSingleOption(profileOptionData, auraID, nil, startTime);
			else
				preExpireFired = SIPPYCUP.Auras.CheckPreExpirationForSingleOption(profileOptionData, nil);
			end

			if not preExpireFired and not preExpireOnly then
				local data = {
					active = auraInfo and true or active,
					auraID = auraID,
					auraInfo = auraInfo,
					optionData = optionData,
					profileOptionData = profileOptionData,
				};
				if auraInfo or active then
					data.reason = SIPPYCUP.Popups.Reason.ADDITION;
					SIPPYCUP.Popups.QueuePopupAction(data, "RefreshStackSizes - active");
				elseif checkAll then
					data.reason = SIPPYCUP.Popups.Reason.REMOVAL;
					SIPPYCUP.Popups.QueuePopupAction(data, "RefreshStackSizes - checkAll (inactive)");
				end
			end
		end
	end
end
