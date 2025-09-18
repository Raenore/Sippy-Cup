-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Options = {};
SIPPYCUP.Options.ByAuraID = {};
SIPPYCUP.Options.ByItemID = {};
SIPPYCUP.Options.ByName = {};

---NewOption creates a new object with the specified parameters.
---@param params table A table containing parameters for the new option.
---@param params.auraID number The option's aura ID.
---@param params.itemID number The option's item ID.
---@param params.loc string The option's localization key.
---@param params.category string The option's category (e.g., potion, food).
---@param params.icon string The option's icon texture name.
---@param params.stacks boolean|number? Whether the option is capable of having stacks (optional, defaults to `false`).
---@param params.maxStacks number? The option's max stack amount it can achieve (optional, defaults to `1`).
---@param params.preExpiration number? The option's pre-expiration settings.
---@param params.profile table The option's associated DB profile (automatically generated).
---@param params.name string The option's name (automatically generated).
---@param params.refreshable boolean Whether the option is can be refreshed, on false it means you lose the stack with no effect.
---@param params.delayedAura boolean Whether the option is applied after a delay (e.g. food buff), on false a buff is applied instantly.
---@param params.cooldownMismatch boolean Whether the option has a mismatch in cooldowns (cd longer than buff lasts), on false there is no mismatch.
---@return table option The created option object.
local function NewOption(params)
	return {
		type  = params.type or 0,
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
	};
end

--[[
Pre-Expiration:
0 = Cannot show pre-expire (multi-stack options).
1 = Can pre-expire (resets to initial max).
]]

SIPPYCUP.Options.Data = {
	-- CONSUMABLES
	NewOption{ auraID = 1213428, itemID = 234526, category = "HANDHELD", preExpiration = true }, -- ARCHIVISTS_CODEX
	NewOption{ auraID = 357489, itemID = 187421, category = "EFFECT", preExpiration = true }, -- ASHEN_LINIMENT
	NewOption{ auraID = 382761, itemID = 197767, category = "APPEARANCE", preExpiration = true }, -- BLUBBERY_MUFFIN
	NewOption{ auraID = 1222839, itemID = 237335, category = "HANDHELD", preExpiration = true }, -- COLLECTIBLE_PINEAPPLETINI_MUG
	NewOption{ auraID = 185562, itemID = 124671, category = "SIZE", unrefreshable = true }, -- DARKMOON_FIREWATER
	NewOption{ auraID = 1213663, itemID = 234282, category = "PLACEMENT", itemTrackable = true }, -- DECORATIVE_YARD_FLAMINGO
	NewOption{ auraID = 1222835, itemID = 237330, category = "HANDHELD", preExpiration = true }, -- DISPOSABLE_HAMBURGER
	NewOption{ auraID = 1222833, itemID = 237331, category = "HANDHELD", preExpiration = true }, -- DISPOSABLE_HOTDOG
	NewOption{ auraID = 8212, itemID = 6662, category = "SIZE", preExpiration = true }, -- ELIXIR_OF_GIANT_GROWTH
	NewOption{ auraID = 2336, itemID = 2460, category = "EFFECT", preExpiration = true }, -- ELIXIR_OF_TONGUES
	NewOption{ auraID = 162906, itemID = 112321, category = "EFFECT", preExpiration = true }, -- ENCHANTED_DUST
	NewOption{ auraID = 398458, itemID = 202290, category = "SIZE", preExpiration = true, delayedAura = true }, -- FIREWATER_SORBET
	NewOption{ auraID = 393977, itemID = 201427, category = "EFFECT" }, -- FLEETING_SANDS
	NewOption{ auraID = 454799, itemID = 225253, category = "HANDHELD", preExpiration = true }, -- FLICKERING_FLAME_HOLDER
	NewOption{ auraID = 58468, itemID = 43478, category = "SIZE", preExpiration = true, delayedAura = true }, -- GIGANTIC_FEAST
	NewOption{ auraID = 244014, itemID = 151257, category = "HANDHELD", preExpiration = true }, -- GREEN_DANCE_STICK
	NewOption{ auraID = 1222840, itemID = 237334, category = "HANDHELD", preExpiration = true }, -- HALF_EATEN_TAKEOUT
	NewOption{ auraID = 443688, itemID = 216708, category = "PLACEMENT", spellTrackable = true }, -- HOLY_CANDLE
	NewOption{ auraID = 185394, itemID = 124640, category = "EFFECT", preExpiration = true }, -- INKY_BLACK_POTION
	NewOption{ auraID = 1218300, itemID = 235703, category = "SIZE", stacks = true, maxStacks = 10, preExpiration = true }, -- NOGGENFOGGER_SELECT_DOWN
	NewOption{ auraID = 1218297, itemID = 235704, category = "SIZE", stacks = true, maxStacks = 10, preExpiration = true }, -- NOGGENFOGGER_SELECT_UP
	NewOption{ auraID = 374957, itemID = 193029, category = "PRISM", preExpiration = true }, -- PROJECTION_PRISM
	NewOption{ auraID = 368038, itemID = 190739, category = "EFFECT", preExpiration = true }, -- PROVIS_WAX
	NewOption{ auraID = 244015, itemID = 151256, category = "HANDHELD", preExpiration = true }, -- PURPLE_DANCE_STICK
	NewOption{ auraID = 53805, itemID = 40195, category = "SIZE", stacks = true, maxStacks = 10 }, -- PYGMY_OIL
	NewOption{ auraID = 393979, itemID = 201428, category = "EFFECT" }, -- QUICKSILVER_SANDS
	NewOption{ auraID = 1213974, itemID = 234287, category = "EFFECT", preExpiration = true }, -- RADIANT_FOCUS
	NewOption{ auraID = 1214287, itemID = 234527, category = "HANDHELD", preExpiration = true }, -- SACREDITES_LEDGER
	NewOption{ auraID = 163219, itemID = 112384, category = "PRISM", preExpiration = true }, -- REFLECTING_PRISM
	NewOption{ auraID = 279742, itemID = 163695, category = "EFFECT" }, -- SCROLL_OF_INNER_TRUTH
	NewOption{ auraID = 1222834, itemID = 237332, category = "PLACEMENT", spellTrackable = true }, -- SINGLE_USE_GRILL
	NewOption{ auraID = 58479, itemID = 43480, category = "SIZE", preExpiration = true, delayedAura = true }, -- SMALL_FEAST
	NewOption{ auraID = 382729, itemID = 197766, category = "HANDHELD", preExpiration = true }, -- SNOW_IN_A_CONE
	NewOption{ auraID = 442106, itemID = 218107, category = "HANDHELD", preExpiration = true }, -- SPARKBUG_JAR
	NewOption{ auraID = 404840, itemID = 204370, category = "EFFECT", preExpiration = true }, -- STINKY_BRIGHT_POTION
	NewOption{ auraID = 254544, itemID = 153192, category = "EFFECT", unrefreshable = true }, -- SUNGLOW
	NewOption{ auraID = 1213975, itemID = 234466, category = "EFFECT", preExpiration = true }, -- TATTERED_ARATHI_PRAYER_SCROLL
	NewOption{ auraID = 393989, itemID = 201436, category = "EFFECT", preExpiration = true }, -- TEMPORALLY_LOCKED_SANDS
	NewOption{ auraID = 393994, itemID = 201438, category = "EFFECT", preExpiration = true }, -- WEARY_SANDS
	NewOption{ auraID = 17038, itemID = 12820, category = "SIZE", preExpiration = true }, -- WINTERFALL_FIREWATER
	-- TOYS
	NewOption{ type = 1, auraID = 393985, itemID = 201435, category = "EFFECT", cooldownMismatch = true }, -- Shuffling Sands
	NewOption{ type = 1, auraID = 427782, itemID = 210975, category = "EFFECT" }, -- Date Simulation Modulator
	NewOption{ type = 1, auraID = 385792, itemID = 198264, category = "EFFECT" }, -- Centralized Precipitation Emitter
	NewOption{ type = 1, auraID = 385085, itemID = 198206, category = "EFFECT" }, -- Environmental Emulator
	NewOption{ type = 1, auraID = 314988, itemID = 173984, category = "EFFECT", cooldownMismatch = true }, -- Scroll of Aeons
	NewOption{ type = 1, auraID = 279997, itemID = 163742, category = "EFFECT", preExpiration = true }, -- Heartsbane Grimoire
	NewOption{ type = 1, auraID = 409891, itemID = 205418, category = "EFFECT", cooldownMismatch = true }, -- Blazing Shadowflame Cinder

	NewOption{ type = 1, auraID = 453163, itemID = 224552, category = "HANDHELD" }, -- Cave Spelunker's Torch
	NewOption{ type = 1, auraID = 203533, itemID = 133997, category = "HANDHELD" }, -- Black Ice
	NewOption{ type = 1, auraID = 203820, itemID = 134007, category = "HANDHELD" }, -- Eternal Black Diamond Ring
	NewOption{ type = 1, auraID = 203657, itemID = 134004, category = "HANDHELD" }, -- Noble's Eternal Elementium Signet
	NewOption{ type = 1, auraID = 465642, itemID = 228789, category = "HANDHELD" }, -- Coldflame Ring
	NewOption{ type = 1, auraID = 1215495, itemID = 235041, category = "HANDHELD" }, -- Cyrce's Circlet
	NewOption{ type = 1, auraID = 1232024, itemID = 242323, category = "HANDHELD", preExpiration = true }, -- Chowdar's Favorite Ribbon
	NewOption{ type = 1, auraID = 341678, itemID = 182694, category = "HANDHELD", preExpiration = true }, -- Stylish Black Parasol
	NewOption{ type = 1, auraID = 341682, itemID = 182695, category = "HANDHELD", preExpiration = true }, -- Weathered Purple Parasol
	NewOption{ type = 1, auraID = 341624, itemID = 182696, category = "HANDHELD", preExpiration = true }, -- The Countess's Parasol
	NewOption{ type = 1, auraID = 431949, itemID = 212500, category = "HANDHELD", preExpiration = true }, -- Delicate Silk Parasol
	NewOption{ type = 1, auraID = 432001, itemID = 212525, category = "HANDHELD", preExpiration = true }, -- Delicate Ebony Parasol
	NewOption{ type = 1, auraID = 431998, itemID = 212524, category = "HANDHELD", preExpiration = true }, -- Delicate Crimson Parasol
	NewOption{ type = 1, auraID = 431994, itemID = 212523, category = "HANDHELD", preExpiration = true }, -- Delicate Jade Parasol
	NewOption{ type = 1, auraID = 196067, itemID = 130251, category = "HANDHELD" }, -- JewelCraft
	NewOption{ type = 1, auraID = 200015, itemID = 132518, category = "HANDHELD" }, -- Blingtron's Circuit Design Tutorial

	NewOption{ type = 1, auraID = 279076, itemID = 163211, category = "PLACEMENT", spellTrackable = true }, -- Akunda's Firesticks
	NewOption{ type = 1, auraID = 401672, itemID = 203757, category = "PLACEMENT", spellTrackable = true }, -- Brazier of Madness
	NewOption{ type = 1, auraID = 254240, itemID = 153039, category = "PLACEMENT", spellTrackable = true }, -- Crystalline Campfire
	NewOption{ type = 1, auraID = 171549, itemID = 116435, category = "PLACEMENT", spellTrackable = true, cooldownMismatch = true }, -- Cozy Bonfire
	NewOption{ type = 1, auraID = 148553, itemID = 104309, category = "PLACEMENT", spellTrackable = true, cooldownMismatch = true }, -- Eternal Kiln
	NewOption{ type = 1, auraID = 188401, itemID = 127652, category = "PLACEMENT", spellTrackable = true }, -- Felflame Campfire
	NewOption{ type = 1, auraID = 93636, itemID = 67097, category = "PLACEMENT", spellTrackable = true }, -- Grim Campfire
	NewOption{ type = 1, auraID = 223297, itemID = 128536, category = "PLACEMENT", spellTrackable = true }, -- Leylight Brazier
	NewOption{ type = 1, auraID = 172809, itemID = 117573, category = "PLACEMENT", spellTrackable = true, cooldownMismatch = true }, -- Wayfarer's Bonfire
	NewOption{ type = 1, auraID = 383081, itemID = 198402, category = "PLACEMENT", spellTrackable = true }, -- Maruuk Cooking Pot
	NewOption{ type = 1, auraID = 340241, itemID = 182780, category = "PLACEMENT", spellTrackable = true }, -- Muckpool Cookpot
	NewOption{ type = 1, auraID = 171760, itemID = 116757, category = "PLACEMENT", spellTrackable = true }, -- Steamworks Sausage Grill
	NewOption{ type = 1, auraID = 453265, itemID = 219403, category = "PLACEMENT", spellTrackable = true }, -- Stonebound Lantern
	NewOption{ type = 1, auraID = 388258, itemID = 199892, category = "PLACEMENT", spellTrackable = true }, -- Tuskarr Traveling Soup Pot
	NewOption{ type = 1, auraID = 345745, itemID = 184404, category = "PLACEMENT", spellTrackable = true }, -- Ever-Abundant Hearth
	NewOption{ type = 1, auraID = 468291, itemID = 234473, category = "PLACEMENT", preExpiration = true }, -- Soweezi's Comfy Lawn Chair

	NewOption{ type = 1, auraID = 383268, itemID = 198428, category = "EFFECT", preExpiration = true }, -- Tuskarr Dinghy
	NewOption{ type = 1, auraID = 124036, itemID = 85500, category = "EFFECT", preExpiration = true }, -- Anglers Fishing Raft
	NewOption{ type = 1, auraID = 344646, itemID = 183989, category = "EFFECT", itemTrackable = true }, -- Dredger Barrow Racer

	NewOption{ type = 1, auraID = 455494, itemID = 225659, category = "PLACEMENT" }, -- Arathi Book Collection
	NewOption{ type = 1, auraID = 1214519, itemID = 235050, category = "PLACEMENT" }, -- Desk-in-a-Box

	NewOption{ type = 1, auraID = 143034, itemID = 97994, category = "SIZE", preExpiration = true }, -- Darkmoon Seesaw / Childlike Wonder

	NewOption{ type = 1, auraID = 392700, itemID = 200960, category = "APPEARANCE", preExpiration = true }, -- Seed of Renewed Souls

	NewOption{ type = 1, auraID = 451985, itemID = 224192, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Practice Ravager
	NewOption{ type = 1, auraID = 462934, itemID = 228705, category = "APPEARANCE", spellTrackable = true, cooldownMismatch = true }, -- Arachnoserum
	NewOption{ type = 1, auraID = 462683, itemID = 228698, category = "APPEARANCE", spellTrackable = true }, -- Candleflexer's Dumbbell
	NewOption{ type = 1, auraID = 455426, itemID = 225641, category = "APPEARANCE", spellTrackable = true, cooldownMismatch = true }, -- Illusive Kobyss Lure
	NewOption{ type = 1, auraID = 371470, itemID = 191891, category = "APPEARANCE", spellTrackable = true, cooldownMismatch = true }, -- Professor Chirpsnide's Im-PECK-able Harpy Disguise

	NewOption{ type = 1, auraID = 474100, itemID = 233486, category = "HANDHELD", preExpiration = true }, -- Hallowfall Supply Cache
	NewOption{ type = 1, auraID = 1215461, itemID = 235015, category = "HANDHELD", preExpiration = true }, -- Awakened Supply Crate

	NewOption{ type = 1, auraID = 160688, itemID = 108743, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Deceptia's Smoldering Boots
	NewOption{ type = 1, auraID = 277572, itemID = 159749, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Haw'li's Hot & Spicy Chili
	NewOption{ type = 1, auraID = 415089, itemID = 206993, category = "EFFECT", preExpiration = true }, -- Investi-gator's Pocketwatch
	NewOption{ type = 1, auraID = 462145, itemID = 228413, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Lampyridae Lure
	NewOption{ type = 1, auraID = 170869, itemID = 116115, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Blazing Wings
	NewOption{ type = 1, auraID = 45418, itemID = 188701, category = "EFFECT", spellTrackable = true }, -- Fire Festival Batons

	NewOption{ type = 1, auraID = 45416, itemID = 188699, category = "EFFECT" }, -- Insulated Dancing Insoles
	NewOption{ type = 1, auraID = 222206, itemID = 141649, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Set of Matches

	NewOption{ type = 1, auraID = 222907, itemID = 140231, category = "APPEARANCE", spellTrackable = true }, -- Narcissa's Mirror
	NewOption{ type = 1, auraID = 187356, itemID = 127696, category = "APPEARANCE", spellTrackable = true, cooldownMismatch = true }, -- Magic Pet Mirror

	NewOption{ type = 1, auraID = 465887, itemID = 238850, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Arathi Entertainer's Flame
	NewOption{ type = 1, auraID = 162402, itemID = 108739, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Pretty Draenor Pearl
	NewOption{ type = 1, auraID = 166592, itemID = 113375, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Vindicator's Armor Polish Kit

	NewOption{ type = 1, auraID = 192930, itemID = 129055, category = "EFFECT" }, -- Shoe Shine Kit

	NewOption{ type = 1, auraID = 290280, itemID = 166790, category = "APPEARANCE", spellTrackable = true, cooldownMismatch = true }, -- Highborne Memento

	NewOption{ type = 1, auraID = 1215373, itemID = 234951, category = "HANDHELD", preExpiration = true }, -- Uncracked Cold Ones / Kaja'Cola Enthusiast

	NewOption{ type = 1, auraID = 373351, itemID = 192495, category = "EFFECT", preExpiration = true }, -- Malfunctioning Stealthman 54

	NewOption{ type = 1, auraID = 1237584, itemID = 244470, category = "EFFECT", spellTrackable = true, cooldownMismatch = true }, -- Etheric Victory
	NewOption{ type = 1, auraID = 1244178, itemID = 246903, category = "EFFECT", preExpiration = true }, -- Guise of the Phase Diver

	NewOption{ type = 1, auraID = 47770, itemID = 36863, category = "EFFECT", itemTrackable = true }, -- Decahedral Dwarven Dice
};

local function NormalizeLocName(name)
	return name:upper():gsub("[^%w]+", "_");
end

function SIPPYCUP.Options.Setup()
	local remaining = {};
	for _, option in ipairs(SIPPYCUP.Options.Data) do
		remaining[option.itemID] = true;

		SIPPYCUP.Options.ByAuraID[option.auraID] = option;
		SIPPYCUP.Options.ByItemID[option.itemID] = option;
	end

	for _, option in ipairs(SIPPYCUP.Options.Data) do
		local item = Item:CreateFromItemID(option.itemID);
		item:ContinueOnItemLoad(function()
			option.name = item:GetItemName();

			-- `loc` from name, e.g. "Noggenfogger Select UP" -> "NOGGENFOGGER_SELECT_UP" and "Half-Eaten Takeout" -> "HALF_EATEN_TAKEOUT"
			option.loc = NormalizeLocName(option.name);

			-- `profile` from loc, e.g. "PYGMY_OIL" -> "pygmyOil"
			option.profile = string.gsub(string.lower(option.loc), "_(%a)", function(c)
				return c:upper();
			end);

			option.icon = item:GetItemIcon();

			remaining[option.itemID] = nil;
			SIPPYCUP.Options.ByName[option.name] = option;

			if next(remaining) == nil then
				-- All options loaded — safe to proceed
				table.sort(SIPPYCUP.Options.Data, function(a, b)
					return SIPPYCUP_TEXT.Normalize(a.name:lower()) < SIPPYCUP_TEXT.Normalize(b.name:lower());
				end);

				SIPPYCUP.Callbacks:TriggerEvent(SIPPYCUP.Events.OPTIONS_LOADED);
			end
		end);
	end
end

---RefreshStackSizes iterates over all enabled Sippy Cup options to set the correct stack sizes (startup / profile change / etc).
---@param checkAll boolean? If true, it will also check the inactive enabled ones.
---@param reset boolean? If true, all popups will be reset. Defaults to true
---@param preExpireOnly boolean? If true, only handles pre-expirations. Defaults to false
---@return nil
function SIPPYCUP.Options.RefreshStackSizes(checkAll, reset, preExpireOnly)
	reset = (reset ~= false);
	preExpireOnly = preExpireOnly or false;

	-- Helper to check cooldown startTime for item or spell trackable
	local function GetCooldownStartTime(option)
		local trackBySpell = false;
		local trackByItem = false;

		if option.type == 0 then
			trackBySpell = option.spellTrackable;
			trackByItem = option.itemTrackable;
		elseif option.type == 1 then
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
			if profileOptionData.noAuraTrackable then
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
					SIPPYCUP.Popups.QueuePopupAction(data, "RefreshStackSizes - checkAll");
				end
			end
		end
	end
end
