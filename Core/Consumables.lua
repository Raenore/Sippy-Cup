-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Consumables = {};
SIPPYCUP.Consumables.ByAuraID = {};
SIPPYCUP.Consumables.ByItemID = {};
SIPPYCUP.Consumables.ByName = {};

---NewConsumable creates a new consumable object with the specified parameters.
---@param params table A table containing parameters for the new consumable.
---@param params.auraID number The consumable's aura ID.
---@param params.itemID number The consumable's item ID.
---@param params.loc string The consumable's localization key.
---@param params.category string The consumable's category (e.g., potion, food).
---@param params.icon string The consumable's icon texture name.
---@param params.stacks boolean|number? Whether the consumable is capable of having stacks (optional, defaults to `false`).
---@param params.maxStacks number? The consumable's max stack amount it can achieve (optional, defaults to `1`).
---@param params.preExpiration number? The consumable's pre-expiration settings.
---@param params.profile table The consumable's associated DB profile (automatically generated).
---@param params.name string The consumable's name (automatically generated).
---@param params.refreshable boolean Whether the consumable is can be refreshed, on false it means you lose the stack with no effect.
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
		preExpiration = params.preExpiration or 0,
		unrefreshable = params.unrefreshable or false,
		itemTrackable = params.itemTrackable or false,
		spellTrackable = params.spellTrackable or false,
	};
end

--[[
Pre-Expiration:
0 = Cannot show pre-expire (multi-stack consumables).
1 = Can pre-expire (resets to initial max).
]]

SIPPYCUP.Consumables.Data = {
	NewConsumable{ auraID = 1213428, itemID = 234526, loc = "ARCHIVISTS_CODEX", category = "HANDHELD", icon = "inv_7xp_inscription_talenttome02", preExpiration = 1 },
	NewConsumable{ auraID = 357489, itemID = 187421, loc = "ASHEN_LINIMENT", category = "EFFECT", icon = "inv_misc_food_legion_goooil_bottle", preExpiration = 1 },
	NewConsumable{ auraID = 382761, itemID = 197767, loc = "BLUBBERY_MUFFIN", category = "APPEARANCE", icon = "inv_misc_food_148_cupcake", preExpiration = 1 },
	NewConsumable{ auraID = 1222839, itemID = 237335, loc = "COLLECTIBLE_PINEAPPLETINI_MUG", category = "HANDHELD", icon = "inv_misc_goblincup01", preExpiration = 1 },
	NewConsumable{ auraID = 185562, itemID = 124671, loc = "DARKMOON_FIREWATER", category = "SIZE", icon = "inv_misc_flaskofvolatility", unrefreshable = true },
	NewConsumable{ auraID = 1213663, itemID = 234282, loc = "DECORATIVE_YARD_FLAMINGO", category = "PLACEMENT", icon = "inv_vulturemount_albatrosspink", itemTrackable = true },
	NewConsumable{ auraID = 1222835, itemID = 237330, loc = "DISPOSABLE_HAMBURGER", category = "HANDHELD", icon = "inv_misc_food_65", preExpiration = 1 },
	NewConsumable{ auraID = 1222833, itemID = 237331, loc = "DISPOSABLE_HOTDOG", category = "HANDHELD", icon = "inv_misc_clefhoofsausages", preExpiration = 1 },
	NewConsumable{ auraID = 8212, itemID = 6662, loc = "ELIXIR_OF_GIANT_GROWTH", category = "SIZE", icon = "inv_potion_10", preExpiration = 1 },
	NewConsumable{ auraID = 2336, itemID = 2460, loc = "ELIXIR_OF_TONGUES", category = "EFFECT", icon = "inv_potion_12", preExpiration = 1 },
	NewConsumable{ auraID = 162906, itemID = 112321, loc = "ENCHANTED_DUST", category = "EFFECT", icon = "inv_enchant_dustspirit", preExpiration = 1 },
	NewConsumable{ auraID = 398458, itemID = 202290, loc = "FIREWATER_SORBET", category = "SIZE", icon = "inv_cooking_100_firewatersorbet", preExpiration = 1 },
	NewConsumable{ auraID = 393977, itemID = 201427, loc = "FLEETING_SANDS", category = "EFFECT", icon = "inv_relics_hourglass_02" },
	NewConsumable{ auraID = 454799, itemID = 225253, loc = "FLICKERING_FLAME_HOLDER", category = "HANDHELD", icon = "trade_archaeology_draenei candelabra", preExpiration = 1 },
	NewConsumable{ auraID = 58468, itemID = 43478, loc = "GIGANTIC_FEAST", category = "SIZE", icon = "ability_hunter_pet_boar", preExpiration = 1 },
	NewConsumable{ auraID = 244014, itemID = 151257, loc = "GREEN_DANCE_STICK", category = "HANDHELD", icon = "inv_enchanting_wod_crystalshard4", preExpiration = 1 },
	NewConsumable{ auraID = 1222840, itemID = 237334, loc = "HALF_EATEN_TAKEOUT", category = "HANDHELD", icon = "inv_misc_cookednoodles", preExpiration = 1 },
	NewConsumable{ auraID = 443688, itemID = 216708, loc = "HOLY_CANDLE", category = "PLACEMENT", icon = "inv_misc_candle_03", spellTrackable = true },
	NewConsumable{ auraID = 185394, itemID = 124640, loc = "INKY_BLACK_POTION", category = "EFFECT", icon = "inv_potion_132", preExpiration = 1 },
	NewConsumable{ auraID = 1218300, itemID = 235703, loc = "NOGGENFOGGER_SELECT_DOWN", category = "SIZE", icon = "inv_potion_140", stacks = true, maxStacks = 10, preExpiration = 1 },
	NewConsumable{ auraID = 1218297, itemID = 235704, loc = "NOGGENFOGGER_SELECT_UP", category = "SIZE", icon = "inv_potion_141", stacks = true, maxStacks = 10, preExpiration = 1 },
	NewConsumable{ auraID = 374957, itemID = 193029, loc = "PROJECTION_PRISM", category = "PRISM", icon = "inv_10_jewelcrafting_prism_blue", preExpiration = 1 },
	NewConsumable{ auraID = 368038, itemID = 190739, loc = "PROVIS_WAX", category = "EFFECT", icon = "inv_misc_food_legion_flaked sea salt", preExpiration = 1 },
	NewConsumable{ auraID = 244015, itemID = 151256, loc = "PURPLE_DANCE_STICK", category = "HANDHELD", icon = "inv_enchanting_wod_crystalshard2", preExpiration = 1 },
	NewConsumable{ auraID = 53805, itemID = 40195, loc = "PYGMY_OIL", category = "SIZE", icon = "inv_potion_07", stacks = true, maxStacks = 10 },
	NewConsumable{ auraID = 393979, itemID = 201428, loc = "QUICKSILVER_SANDS", category = "EFFECT", icon = "inv_relics_hourglass" },
	NewConsumable{ auraID = 1213974, itemID = 234287, loc = "RADIANT_FOCUS", category = "EFFECT", icon = "inv_radiant_remnant", preExpiration = 1 },
	NewConsumable{ auraID = 1214287, itemID = 234527, loc = "SACREDITES_LEDGER", category = "HANDHELD", icon = "inv_offhand_1h_priest_c_01", preExpiration = 1 },
	NewConsumable{ auraID = 163219, itemID = 112384, loc = "REFLECTING_PRISM", category = "PRISM", icon = "inv_jewelcrafting_prism", preExpiration = 1 },
	NewConsumable{ auraID = 279742, itemID = 163695, loc = "SCROLL_OF_INNER_TRUTH", category = "EFFECT", icon = "inv_misc_scrollunrolled04b" },
	NewConsumable{ auraID = 1222834, itemID = 237332, loc = "SINGLE_USE_GRILL", category = "PLACEMENT", icon = "achievement_cooking_masterofthegrill", spellTrackable = true },
	NewConsumable{ auraID = 58479, itemID = 43480, loc = "SMALL_FEAST", category = "SIZE", icon = "ability_hunter_pet_boar", preExpiration = 1 },
	NewConsumable{ auraID = 382729, itemID = 197766, loc = "SNOW_IN_A_CONE", category = "HANDHELD", icon = "inv_misc_food_31", preExpiration = 1 },
	NewConsumable{ auraID = 442106, itemID = 218107, loc = "SPARKBUG_JAR", category = "HANDHELD", icon = "inv_first_aid_70_ jar", preExpiration = 1 },
	NewConsumable{ auraID = 404840, itemID = 204370, loc = "STINKY_BRIGHT_POTION", category = "EFFECT", icon = "inv_trade_alchemy_dpotion_c1a", preExpiration = 1 },
	NewConsumable{ auraID = 254544, itemID = 153192, loc = "SUNGLOW", category = "EFFECT", icon = "inv_drink_29_sunkissedwine", unrefreshable = true },
	NewConsumable{ auraID = 1213975, itemID = 234466, loc = "TATTERED_ARATHI_PRAYER_SCROLL", category = "EFFECT", icon = "inv_10_inscription2_scroll3_color3", preExpiration = 1 },
	NewConsumable{ auraID = 393989, itemID = 201436, loc = "TEMPORALLY_LOCKED_SANDS", category = "EFFECT", icon = "inv_10_worlddroplevelingoptionalreagent_relics_hourglass_color1", preExpiration = 1 },
	NewConsumable{ auraID = 393994, itemID = 201438, loc = "WEARY_SANDS", category = "EFFECT", icon = "inv_10_worlddroplevelingoptionalreagent_relics_hourglass_color2", preExpiration = 1 },
	NewConsumable{ auraID = 17038, itemID = 12820, loc = "WINTERFALL_FIREWATER", category = "SIZE", icon = "inv_potion_92", preExpiration = 1 },
};

local remaining = {};
for _, consumable in ipairs(SIPPYCUP.Consumables.Data) do
	remaining[consumable.itemID] = true;

	-- `profile` from loc, e.g. "PYGMY_OIL" -> "pygmyOil"
	consumable.profile = string.gsub(string.lower(consumable.loc), "_(%a)", function(c)
		return c:upper();
	end);

	SIPPYCUP.Consumables.ByAuraID[consumable.auraID] = consumable;
	SIPPYCUP.Consumables.ByItemID[consumable.itemID] = consumable;
end

for _, consumable in ipairs(SIPPYCUP.Consumables.Data) do
	local item = Item:CreateFromItemID(consumable.itemID);
	item:ContinueOnItemLoad(function()
		consumable.name = item:GetItemName();
		remaining[consumable.itemID] = nil;
		SIPPYCUP.Consumables.ByName[consumable.name] = consumable;

		if next(remaining) == nil then
			-- All items loaded — safe to proceed
			table.sort(SIPPYCUP.Consumables.Data, function(a, b)
				return SIPPYCUP_TEXT.Normalize(a.name:lower()) < SIPPYCUP_TEXT.Normalize(b.name:lower());
			end);

			if SIPPYCUP.db then
				SIPPYCUP.Database.SetupConfig();
			else
				-- Defer SetupConfig until DB is ready
				SIPPYCUP.deferSetupConfig = true;
			end
		end
	end);
end

---RefreshStackSizes iterates over all enabled Sippy Cup consumables to set the correct stack sizes (startup / profile change / etc).
---@param checkAll boolean? If true, it will also check the inactive enabled ones.
---@return nil
function SIPPYCUP.Consumables.RefreshStackSizes(checkAll)
	local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID;

	-- Kill all the timers associated with previous consumables to start fresh.
	SIPPYCUP.Auras.CancelAllPreExpirationTimers();
	SIPPYCUP.Items.CancelAllItemTimers();

	-- Close all the opened Sippy Cup popups that still exist.
	SIPPYCUP.Popups.HideAllRefreshPopups();

	-- Rebuild the aura map from the latest database data that we have.
	SIPPYCUP.Database.RebuildAuraMap();

	-- auraToProfile will iterate over all the enabled consumables.
	for _, profileConsumableData in pairs(SIPPYCUP.Database.auraToProfile) do
		local auraInfo = GetPlayerAuraBySpellID(profileConsumableData.aura);
		local consumableData = SIPPYCUP.Consumables.ByAuraID[profileConsumableData.aura];
		local active = false;
		local startTime = 0;

		-- If item can only be tracked by the item cooldown (worst)
		if consumableData.itemTrackable then
			startTime, _, _ = C_Item.GetItemCooldown(consumableData.itemID)
			if startTime and startTime > 0 then
				active = true;
			end
		-- If item can be tracked through the spell cooldown (fine).
		elseif consumableData.spellTrackable then
			local spellCooldownInfo = C_Spell.GetSpellCooldown(consumableData.auraID);
			startTime = spellCooldownInfo and spellCooldownInfo.startTime;
			if startTime and startTime > 0 then
				active = true;
			end
		end

		-- Most of the checks below don't work during loading screens, we do them at other times.
		-- Howevever when a user switches profiles etc they generally aren't in that state so run it then.
		if not SIPPYCUP.InLoadingScreen then
			local preExpireFired;
			if consumableData.itemTrackable or consumableData.spellTrackable then
				preExpireFired = SIPPYCUP.Items.CheckNoAuraSingleConsumable(profileConsumableData, consumableData.auraID, nil, startTime);
			else
				preExpireFired = SIPPYCUP.Auras.CheckPreExpirationForSingleConsumable(profileConsumableData, nil);
			end

			if not preExpireFired then
				if auraInfo or active then
					-- When the aura is enabled and active.
					SIPPYCUP.Popups.QueuePopupAction(0, profileConsumableData.aura, auraInfo, auraInfo and auraInfo.auraInstanceID, "CheckConsumableStackSizes - active");
				elseif checkAll then
					-- The aura is enabled, not active. But CheckAll is on, so we still run it.
					SIPPYCUP.Popups.QueuePopupAction(1, profileConsumableData.aura, nil, nil, "CheckConsumableStackSizes - checkAll");
				end
			end
		end
	end
end
