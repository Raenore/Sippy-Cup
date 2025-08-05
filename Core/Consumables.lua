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
	NewConsumable{ auraID = 1213428, itemID = 234526, category = "HANDHELD", preExpiration = 1 }, -- ARCHIVISTS_CODEX
	NewConsumable{ auraID = 357489, itemID = 187421, category = "EFFECT", preExpiration = 1 }, -- ASHEN_LINIMENT
	NewConsumable{ auraID = 382761, itemID = 197767, category = "APPEARANCE", preExpiration = 1 }, -- BLUBBERY_MUFFIN
	NewConsumable{ auraID = 1222839, itemID = 237335, category = "HANDHELD", preExpiration = 1 }, -- COLLECTIBLE_PINEAPPLETINI_MUG
	NewConsumable{ auraID = 185562, itemID = 124671, category = "SIZE", unrefreshable = true }, -- DARKMOON_FIREWATER
	NewConsumable{ auraID = 1213663, itemID = 234282, category = "PLACEMENT", itemTrackable = true }, -- DECORATIVE_YARD_FLAMINGO
	NewConsumable{ auraID = 1222835, itemID = 237330, category = "HANDHELD", preExpiration = 1 }, -- DISPOSABLE_HAMBURGER
	NewConsumable{ auraID = 1222833, itemID = 237331, category = "HANDHELD", preExpiration = 1 }, -- DISPOSABLE_HOTDOG
	NewConsumable{ auraID = 8212, itemID = 6662, category = "SIZE", preExpiration = 1 }, -- ELIXIR_OF_GIANT_GROWTH
	NewConsumable{ auraID = 2336, itemID = 2460, category = "EFFECT", preExpiration = 1 }, -- ELIXIR_OF_TONGUES
	NewConsumable{ auraID = 162906, itemID = 112321, category = "EFFECT", preExpiration = 1 }, -- ENCHANTED_DUST
	NewConsumable{ auraID = 398458, itemID = 202290, category = "SIZE", preExpiration = 1 }, -- FIREWATER_SORBET
	NewConsumable{ auraID = 393977, itemID = 201427, category = "EFFECT" }, -- FLEETING_SANDS
	NewConsumable{ auraID = 454799, itemID = 225253, category = "HANDHELD", preExpiration = 1 }, -- FLICKERING_FLAME_HOLDER
	NewConsumable{ auraID = 58468, itemID = 43478, category = "SIZE", preExpiration = 1 }, -- GIGANTIC_FEAST
	NewConsumable{ auraID = 244014, itemID = 151257, category = "HANDHELD", preExpiration = 1 }, -- GREEN_DANCE_STICK
	NewConsumable{ auraID = 1222840, itemID = 237334, category = "HANDHELD", preExpiration = 1 }, -- HALF_EATEN_TAKEOUT
	NewConsumable{ auraID = 443688, itemID = 216708, category = "PLACEMENT", spellTrackable = true }, -- HOLY_CANDLE
	NewConsumable{ auraID = 185394, itemID = 124640, category = "EFFECT", preExpiration = 1 }, -- INKY_BLACK_POTION
	NewConsumable{ auraID = 1218300, itemID = 235703, category = "SIZE", stacks = true, maxStacks = 10, preExpiration = 1 }, -- NOGGENFOGGER_SELECT_DOWN
	NewConsumable{ auraID = 1218297, itemID = 235704, category = "SIZE", stacks = true, maxStacks = 10, preExpiration = 1 }, -- NOGGENFOGGER_SELECT_UP
	NewConsumable{ auraID = 374957, itemID = 193029, category = "PRISM", preExpiration = 1 }, -- PROJECTION_PRISM
	NewConsumable{ auraID = 368038, itemID = 190739, category = "EFFECT", preExpiration = 1 }, -- PROVIS_WAX
	NewConsumable{ auraID = 244015, itemID = 151256, category = "HANDHELD", preExpiration = 1 }, -- PURPLE_DANCE_STICK
	NewConsumable{ auraID = 53805, itemID = 40195, category = "SIZE", stacks = true, maxStacks = 10 }, -- PYGMY_OIL
	NewConsumable{ auraID = 393979, itemID = 201428, category = "EFFECT" }, -- QUICKSILVER_SANDS
	NewConsumable{ auraID = 1213974, itemID = 234287, category = "EFFECT", preExpiration = 1 }, -- RADIANT_FOCUS
	NewConsumable{ auraID = 1214287, itemID = 234527, category = "HANDHELD", preExpiration = 1 }, -- SACREDITES_LEDGER
	NewConsumable{ auraID = 163219, itemID = 112384, category = "PRISM", preExpiration = 1 }, -- REFLECTING_PRISM
	NewConsumable{ auraID = 279742, itemID = 163695, category = "EFFECT" }, -- SCROLL_OF_INNER_TRUTH
	NewConsumable{ auraID = 1222834, itemID = 237332, category = "PLACEMENT", spellTrackable = true }, -- SINGLE_USE_GRILL
	NewConsumable{ auraID = 58479, itemID = 43480, category = "SIZE", preExpiration = 1 }, -- SMALL_FEAST
	NewConsumable{ auraID = 382729, itemID = 197766, category = "HANDHELD", preExpiration = 1 }, -- SNOW_IN_A_CONE
	NewConsumable{ auraID = 442106, itemID = 218107, category = "HANDHELD", preExpiration = 1 }, -- SPARKBUG_JAR
	NewConsumable{ auraID = 404840, itemID = 204370, category = "EFFECT", preExpiration = 1 }, -- STINKY_BRIGHT_POTION
	NewConsumable{ auraID = 254544, itemID = 153192, category = "EFFECT", unrefreshable = true }, -- SUNGLOW
	NewConsumable{ auraID = 1213975, itemID = 234466, category = "EFFECT", preExpiration = 1 }, -- TATTERED_ARATHI_PRAYER_SCROLL
	NewConsumable{ auraID = 393989, itemID = 201436, category = "EFFECT", preExpiration = 1 }, -- TEMPORALLY_LOCKED_SANDS
	NewConsumable{ auraID = 393994, itemID = 201438, category = "EFFECT", preExpiration = 1 }, -- WEARY_SANDS
	NewConsumable{ auraID = 17038, itemID = 12820, category = "SIZE", preExpiration = 1 }, -- WINTERFALL_FIREWATER
};

local function NormalizeLocName(name)
	return name:upper():gsub("[^%w]+", "_");
end

local remaining = {};
for _, consumable in ipairs(SIPPYCUP.Consumables.Data) do
	remaining[consumable.itemID] = true;

	SIPPYCUP.Consumables.ByAuraID[consumable.auraID] = consumable;
	SIPPYCUP.Consumables.ByItemID[consumable.itemID] = consumable;
end

SIPPYCUP.deferSetup = false;

for _, consumable in ipairs(SIPPYCUP.Consumables.Data) do
	local item = Item:CreateFromItemID(consumable.itemID);
	item:ContinueOnItemLoad(function()
		consumable.name = item:GetItemName();

		-- `loc` from name, e.g. "Noggenfogger Select UP" -> "NOGGENFOGGER_SELECT_UP" and "Half-Eaten Takeout" -> "HALF_EATEN_TAKEOUT"
		consumable.loc = NormalizeLocName(consumable.name);

		-- `profile` from loc, e.g. "PYGMY_OIL" -> "pygmyOil"
		consumable.profile = string.gsub(string.lower(consumable.loc), "_(%a)", function(c)
			return c:upper();
		end);

		consumable.icon = item:GetItemIcon();

		remaining[consumable.itemID] = nil;
		SIPPYCUP.Consumables.ByName[consumable.name] = consumable;

		if next(remaining) == nil then
			-- All items loaded — safe to proceed
			table.sort(SIPPYCUP.Consumables.Data, function(a, b)
				return SIPPYCUP_TEXT.Normalize(a.name:lower()) < SIPPYCUP_TEXT.Normalize(b.name:lower());
			end);

			--[[
			if SIPPYCUP.db then
				-- RUN DEFERRED SETUP
				-- SIPPYCUP.Database.RefreshUI();
				print("DB was ready");
			else
				-- Defer SetupConfig until DB is ready
				SIPPYCUP.deferSetup = true;
				print("DB was not ready");
			end
			]]
		end
	end);
end

---RefreshStackSizes iterates over all enabled Sippy Cup consumables to set the correct stack sizes (startup / profile change / etc).
---@param checkAll boolean? If true, it will also check the inactive enabled ones.
---@return nil
function SIPPYCUP.Consumables.RefreshStackSizes(checkAll)
	local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID;

	local QUEUE_POPUP_ACTIVE = 0;
	local QUEUE_POPUP_CHECKALL = 1; -- (Marked as 'remove')

	-- Helper to check cooldown startTime for item or spell trackable
	local function GetCooldownStartTime(consumable)
		if consumable.itemTrackable then
			local startTime = select(1, C_Item.GetItemCooldown(consumable.itemID));
			if startTime and startTime > 0 then
				return startTime;
			end
		elseif consumable.spellTrackable then
			local spellCooldown = C_Spell.GetSpellCooldown(consumable.auraID);
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
	SIPPYCUP.Popups.HideAllRefreshPopups();

	-- Rebuild the aura map from the latest database data that we have.
	SIPPYCUP.Database.RebuildAuraMap();

	-- auraToProfile will iterate over all the enabled (not active!) consumables.
	for _, profileConsumableData in pairs(SIPPYCUP.Database.auraToProfile) do
		local auraID = profileConsumableData.aura;
		local auraInfo = GetPlayerAuraBySpellID(auraID);
		local consumableData = SIPPYCUP.Consumables.ByAuraID[auraID];
		local startTime = GetCooldownStartTime(consumableData);
		local active = startTime ~= nil;

		if not SIPPYCUP.InLoadingScreen then
			local preExpireFired;
			if consumableData.itemTrackable or consumableData.spellTrackable then
				preExpireFired = SIPPYCUP.Items.CheckNoAuraSingleConsumable(profileConsumableData, auraID, nil, startTime);
			else
				preExpireFired = SIPPYCUP.Auras.CheckPreExpirationForSingleConsumable(profileConsumableData, nil);
			end

			if not preExpireFired then
				if auraInfo or active then
					SIPPYCUP.Popups.QueuePopupAction(QUEUE_POPUP_ACTIVE, auraID, auraInfo, auraInfo and auraInfo.auraInstanceID, "CheckConsumableStackSizes - active");
				elseif checkAll then
					SIPPYCUP.Popups.QueuePopupAction(QUEUE_POPUP_CHECKALL, auraID, nil, nil, "CheckConsumableStackSizes - checkAll");
				end
			end
		end
	end
end
