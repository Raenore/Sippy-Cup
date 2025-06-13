-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Auras = {};
SIPPYCUP.Auras.InLoadingScreen = false;

---CheckEnabledAuras displays data on the currently tracking enabled consumables (even if they are zero).
---@return nil
function SIPPYCUP.Auras.DebugEnabledAuras()
	for _, profileConsumableData in pairs(SIPPYCUP.Database.auraToProfile) do
		local consumableData = SIPPYCUP.Consumables.ByAuraID[profileConsumableData.aura];

		if consumableData then
			SIPPYCUP_OUTPUT.Write("AuraID: " .. consumableData.auraID ..
				" - Name: " .. consumableData.name ..
				" - Desired Stacks: " .. profileConsumableData.desiredStacks ..
				" - Current Stacks: " .. profileConsumableData.currentStacks ..
				" - AuraInstanceID: " .. tostring(profileConsumableData.currentInstanceID));
		else
			SIPPYCUP_OUTPUT.Write("Missing data for auraID: " .. tostring(profileConsumableData.aura));
		end
	end
end

---ParseAura extracts aura updates, including application, updates and removals from a updateInfo format.
---@param updateInfo table A table containing details about the aura updates.
---     updateInfo.addedAuras (table)? A list of auras that were added.
---     updateInfo.updatedAuraInstanceIDs (table)? A list of aura instance IDs that were updated.
---     updateInfo.removedAuraInstanceIDs (table)? A list of aura instance IDs that were removed.
---@return nil
local function ParseAura(updateInfo)
	local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID;

	-- On aura application.
	if updateInfo.addedAuras then
		for _, auraInfo in ipairs(updateInfo.addedAuras) do
			local profileConsumableData = SIPPYCUP.Database.FindMatchingConsumable(auraInfo.spellId);
			if profileConsumableData then
				profileConsumableData.currentInstanceID = auraInfo.auraInstanceID;
				SIPPYCUP.Database.instanceToProfile[auraInfo.auraInstanceID] = profileConsumableData;

				SIPPYCUP.Auras.CheckPreExpirationForSingleConsumable(profileConsumableData);
				SIPPYCUP.Popups.QueuePopupAction(0, auraInfo.spellId, auraInfo, auraInfo.auraInstanceID, nil, "ParseAura - addition");
			end
		end
	end

	-- On aura update.
	if updateInfo.updatedAuraInstanceIDs then
		for _, auraInstanceID in ipairs(updateInfo.updatedAuraInstanceIDs) do
			local profileConsumableData = SIPPYCUP.Database.FindMatchingConsumable(nil, auraInstanceID);
			if profileConsumableData then
				local auraInfo = GetAuraDataByAuraInstanceID("player", auraInstanceID);
				if auraInfo then
					-- This is not necessary, but a safety update just in case.
					profileConsumableData.currentInstanceID = auraInfo.auraInstanceID;
					SIPPYCUP.Database.instanceToProfile[auraInfo.auraInstanceID] = profileConsumableData;

					-- On aura update, we remove all pre-expiration timers as that's obvious no longer relevant.
					SIPPYCUP.Auras.CancelPreExpirationTimer(nil, profileConsumableData.aura, auraInstanceID);
					SIPPYCUP.Auras.CheckPreExpirationForSingleConsumable(profileConsumableData);
					SIPPYCUP.Popups.QueuePopupAction(0, auraInfo.spellId, auraInfo, auraInfo.auraInstanceID, nil, "ParseAura - updated");
				end
			end
		end
	end

	-- On aura removal.
	if updateInfo.removedAuraInstanceIDs then
		for _, auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
			local profileConsumableData = SIPPYCUP.Database.FindMatchingConsumable(nil, auraInstanceID);
			if profileConsumableData then
				SIPPYCUP.Database.instanceToProfile[auraInstanceID] = nil;
				profileConsumableData.currentInstanceID = nil;

				-- On aura removal, we remove all pre-expiration timers as that's obvious no longer relevant.
				SIPPYCUP.Auras.CancelPreExpirationTimer(nil, profileConsumableData.aura, auraInstanceID);
				SIPPYCUP.Popups.QueuePopupAction(1, profileConsumableData.aura, nil, auraInstanceID, nil, "ParseAura - removed");
			end
		end
	end
end

SIPPYCUP.Auras.auraQueue = {};
SIPPYCUP.Auras.auraQueueSchededule = false;

---flushAuraQueue combines all the UNIT_AURA events in the same frame together, filtering them for weird exceptions.
---@return nil
local function flushAuraQueue()
	local queue = SIPPYCUP.Auras.auraQueue;
	SIPPYCUP.Auras.auraQueue = {};
	SIPPYCUP.Auras.auraQueueSchededule = false;

	-- Merge all queued updateInfo into one combined table.
	local combined = {
		addedAuras = {},
		updatedAuraInstanceIDs = {},
		removedAuraInstanceIDs = {},
	};

	 -- Deduplication arrays
	local seenAdd, seenUpdate, seenRemoval = {}, {}, {};

	-- 1) harvest everything into seenAdd / seenUpdate / seenRemoval
	for _, updateInfo in ipairs(queue) do
		local adds = updateInfo.addedAuras;
		if adds then
			for i = 1, #adds do
				local auraInfo = adds[i];
				if not seenAdd[auraInfo.auraInstanceID] then
					seenAdd[auraInfo.auraInstanceID] = auraInfo;
				end
			end
		end

		local updatedAuraInstanceIDs = updateInfo.updatedAuraInstanceIDs;
		if updatedAuraInstanceIDs then
			for i = 1, #updatedAuraInstanceIDs do
				seenUpdate[updatedAuraInstanceIDs[i]] = true;
			end
		end

		local removedAuraInstanceIDs = updateInfo.removedAuraInstanceIDs;
		if removedAuraInstanceIDs then
			for i = 1, #removedAuraInstanceIDs do
				seenRemoval[removedAuraInstanceIDs[i]] = true;
			end
		end
	end

	-- 2) convert any remove+add-of-same-spell into an update
	for removedID in pairs(seenRemoval) do
		local profileData = SIPPYCUP.Database.instanceToProfile[removedID];
		if profileData then
			local auraID = profileData.aura;
			for addID, auraInfo in pairs(seenAdd) do
				if auraInfo.spellId == auraID then
					-- cancel any pre-expiration timer keyed by this spell+instance
					local key = tostring(auraID) .. "-" .. tostring(removedID);
					SIPPYCUP.Auras.CancelPreExpirationTimer(key);

					seenRemoval[removedID] = nil;
					seenUpdate[addID] = true;
					break;
				end
			end
		end
	end

	-- 3) convert any update+add-of-same-spell into an update
	for updatedAuraInstanceIDs in pairs(seenUpdate) do
		if seenAdd[updatedAuraInstanceIDs] then
			-- cancel any pre-expiration timer keyed by this spell+instance
			local key = tostring(seenAdd[updatedAuraInstanceIDs].spellId) .. "-" .. tostring(updatedAuraInstanceIDs);
			SIPPYCUP.Auras.CancelPreExpirationTimer(key);
			seenAdd[updatedAuraInstanceIDs] = nil;
		end
	end

	-- 4) flush into combined
	for _, auraInfo in pairs(seenAdd) do
		combined.addedAuras[#combined.addedAuras + 1] = auraInfo;
	end

	for updatedAuraInstanceIDs in pairs(seenUpdate) do
		combined.updatedAuraInstanceIDs[#combined.updatedAuraInstanceIDs + 1] = updatedAuraInstanceIDs;
	end

	for removedAuraInstanceIDs in pairs(seenRemoval) do
		combined.removedAuraInstanceIDs[#combined.removedAuraInstanceIDs + 1] = removedAuraInstanceIDs;
	end

	-- 5) finally invoke ParseAura
	ParseAura(combined);
end

---Convert adapts incoming aura events into the proper updateInfo format (UNIT_AURA).
---@param source number The source of the data.
---@param data table The data to be converted.
---@return nil
function SIPPYCUP.Auras.Convert(source, data)
	local updateInfo = {};

	if source == 1 then
		-- Source 1: UNIT_AURA gives us a table already in the right shape,
		-- but we shallow-copy to avoid buffering Blizzard’s reuse.
		if data.addedAuras then
			updateInfo.addedAuras = data.addedAuras;
		end
		if data.updatedAuraInstanceIDs then
			updateInfo.updatedAuraInstanceIDs = data.updatedAuraInstanceIDs;
		end
		if data.removedAuraInstanceIDs then
			updateInfo.removedAuraInstanceIDs = data.removedAuraInstanceIDs;
		end
	elseif source == 2 then
		-- Source 2: Combat Log events (e.g., SPELL_AURA_APPLIED).
		-- Currently unused, but might return at some point.
		local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(data[2]);

		if data[1] == "SPELL_AURA_APPLIED" then
			updateInfo.addedAuras = { data[2] };
		elseif data[1] == "SPELL_AURA_APPLIED_DOSE" and auraInfo then
			updateInfo.updatedAuraInstanceIDs = { auraInfo.auraInstanceID };
		elseif data[1] == "SPELL_AURA_REMOVED" and auraInfo then
			updateInfo.removedAuraInstanceIDs = { auraInfo.auraInstanceID };
		end
	elseif source == 3 and not SIPPYCUP.Auras.InLoadingScreen then
		-- Source 3: DB mismatch — simulate expired aura using its last known instance ID.
		-- Data sent through/around loading screens will not be reliable, so skip that.
		updateInfo.removedAuraInstanceIDs = { data[1] };
	else
		-- Unknown source passed in — log to user so they can let us know.
		SIPPYCUP_OUTPUT.Write("Convert called with unknown source: " .. tostring(source));
		return;
	end

	if not next(updateInfo) then
		return;
	end

	 -- buffer it instead of parsing immediately
	table.insert(SIPPYCUP.Auras.auraQueue, updateInfo);

	-- flush on the next frame (which will run the batched UNIT_AURAs)
	if not SIPPYCUP.Auras.auraQueueSchededule then
		SIPPYCUP.Auras.auraQueueSchededule = true;
		RunNextFrame(flushAuraQueue);
	end
end

---CheckStackMismatchInDBForAllActiveConsumables runs every 5 seconds to check if there is a mismatch between actual stacks and the DB.
---
---This can happen in the rare (but possible) case where UNIT_AURA did not catch a consumable expiration.
---@return nil
function SIPPYCUP.Auras.CheckStackMismatchInDBForAllActiveConsumables()
	-- Data sent through/around loading screens will not be reliable, so skip that.
	if SIPPYCUP.Auras.InLoadingScreen then
		return;
	end

	local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID;

	-- instanceToProfile holds only enabled and active consumables (with a known instanceID) AKA the ones our DB thinks are running.
	for _, profileConsumableData in pairs(SIPPYCUP.Database.instanceToProfile) do
		local auraInfo = GetPlayerAuraBySpellID(profileConsumableData.aura);

		-- If no auraInfo is found, the consumable got removed and our checks did not notice.
		if not auraInfo and profileConsumableData.currentInstanceID then
			local expiredInstanceID = { profileConsumableData.currentInstanceID };

			-- Prepare this consumable to get popup'd anew, by faking a "this has expired" call to our system.
			-- Don't worry about ignored or other stuff, popups handle this later in the chain.
			SIPPYCUP.Auras.Convert(3, expiredInstanceID);
		end
	end
end

local scheduledPreExpirationAuraTimers = {};

---CreatePreExpirationTimer will create a pre-expiration timer for a specific aura.
---Either pass in `key` directly, or pass `auraID` and `auraInstanceID` to build it.
---@param fireIn number The amount of seconds that should elapse before the timer fires.
---@param auraInfo table? Optional information about the aura.
---@param key string? Optional pre-expiration timer key. If not provided, will be built from auraID and auraInstanceID.
---@param auraID number? Required if key is not provided.
---@param auraInstanceID number? Required if key is not provided.
---@return nil
function SIPPYCUP.Auras.CreatePreExpirationTimer(fireIn, auraInfo, key, auraID, auraInstanceID)
	-- Validate inputs
	if type(fireIn) ~= "number" or fireIn <= 0 then
		return;
	end

	if auraInfo then
		if type(auraInfo) ~= "table" or not auraInfo.spellId or not auraInfo.auraInstanceID then
			return;
		end
	end

	-- If no key is given, we need both auraID and auraInstanceID to build it
	if not key then
		if type(auraID) ~= "number" or type(auraInstanceID) ~= "number" then
			return;
		end
		key = tostring(auraID) .. "-" .. tostring(auraInstanceID);
	end

	-- Avoid double‐scheduling
	if scheduledPreExpirationAuraTimers[key] then
		return;
	end

	-- Schedule the timer
	local handle = C_Timer.NewTimer(fireIn, function()
		scheduledPreExpirationAuraTimers[key] = nil;
		-- Fire the popup
		SIPPYCUP.Popups.QueuePopupAction(2, auraInfo and auraInfo.spellId or auraID, auraInfo, auraInfo and auraInfo.auraInstanceID, nil, "CreatePreExpirationTimer - Aura");
	end);

	-- Store it for potential cancellation later
	scheduledPreExpirationAuraTimers[key] = handle;
end

---CancelPreExpirationTimer will cancel a chosen pre-expiration timer early.
---Either pass in `key` directly, or pass `auraID` and `auraInstanceID` to build it.
---@param key string? The pre‐expiration timer key, or nil to build from auraID+auraInstanceID.
---@param auraID number? The aura ID (used only if key is nil or if you want to cancel timers by auraID).
---@param auraInstanceID number? The instance ID (used only if key is nil).
---@return nil
function SIPPYCUP.Auras.CancelPreExpirationTimer(key, auraID, auraInstanceID)
	-- If no key was provided, build it from auraID and auraInstanceID
	if not key then
		if auraID and auraInstanceID then
			key = tostring(auraID) .. "-" .. tostring(auraInstanceID);
		elseif auraID and not auraInstanceID then
			-- Only auraID is available: cancel all timers with matching auraID
			local targetPrefix = tostring(auraID) .. "-";
			for k, timer in pairs(scheduledPreExpirationAuraTimers) do
				if k:sub(1, #targetPrefix) == targetPrefix then
					timer:Cancel();
					scheduledPreExpirationAuraTimers[k] = nil;
				end
			end
			return;
		else
			-- Not enough info to build key or match by auraID
			return;
		end
	end

	local expirationTimer = scheduledPreExpirationAuraTimers[key];
	if expirationTimer then
		expirationTimer:Cancel();
		scheduledPreExpirationAuraTimers[key] = nil;
	end
end

---CancelAllPreExpirationTimers will cancel every pre-expiration timer currently scheduled.
---@return nil
function SIPPYCUP.Auras.CancelAllPreExpirationTimers()
	for key, handle in pairs(scheduledPreExpirationAuraTimers) do
		handle:Cancel();
		scheduledPreExpirationAuraTimers[key] = nil;
	end
end

---CheckPreExpirationForAllActiveConsumables Handles pre-expiration timer setup where appropriate, calculating the pre-expiration time before popup.
---@param minSeconds number? The minimum amount of seconds the duration should be above before it starts handling more, default is 180 (3 minutes).
---@return nil
function SIPPYCUP.Auras.CheckPreExpirationForAllActiveConsumables(minSeconds)
	-- Data sent through/around loading screens will not be reliable, so skip that.
	if SIPPYCUP.Auras.InLoadingScreen or not SIPPYCUP.db.global.PreExpirationChecks then
		return;
	end

	-- instanceToProfile holds only enabled, active and trackable consumables (with a known instanceID), as inactive enabled ones shouldn't have timers.
	for _, profileConsumableData in pairs(SIPPYCUP.Database.instanceToProfile) do
		SIPPYCUP.Auras.CheckPreExpirationForSingleConsumable(profileConsumableData, minSeconds);
	end
end

---CheckPreExpirationForSingleConsumable Handles pre-expiration timer setup where appropriate, calculating the pre-expiration time before popup.
---@return boolean preExpireFired
function SIPPYCUP.Auras.CheckPreExpirationForSingleConsumable(profileConsumableData, minSeconds)
	local preExpireFired = false;

	-- If pre-expiration checks can't be done, why are we even here?
	if SIPPYCUP.Auras.InLoadingScreen or not SIPPYCUP.db.global.PreExpirationChecks then
		return preExpireFired;
	end

	if not minSeconds then
		minSeconds = 180.0;
	end

	-- default warning offset to 60s
	local preOffset = 60.0;
	local auraID = profileConsumableData.aura;
	local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(auraID);

	-- If there's no auraInfo, stop here.
	if not auraInfo then
		return preExpireFired;
	end

	local key = tostring(auraID) .. "-" .. tostring(auraInfo.auraInstanceID);
	local consumableData = SIPPYCUP.Consumables.ByAuraID[auraID];

	if consumableData.preExpiration == 0 or scheduledPreExpirationAuraTimers[key] then
		return preExpireFired;
	end

	local now = GetTime();
	local remaining = auraInfo.expirationTime - now;
	local duration = auraInfo.duration;

	-- If the consumable only lasts for 60 seconds, we warn at 15 seconds.
	if duration <= 60 then
		preOffset = 15;
	end

	-- How far out we’ll scan: look‑ahead + warning offset
	local windowHigh = minSeconds + preOffset;

	-- Only care about auras that will expire before our next 180s (or custom) scan
	if remaining > 0 and remaining <= windowHigh then
		-- Schedule for “preOffset” seconds before expiration
		local fireIn = remaining - preOffset;

		if fireIn <= 0 and SIPPYCUP.db.global.PreExpirationChecks then
			-- Less than 60s left and we want pre-expiration popup: fire immediately

			local spellId = auraInfo and auraInfo.spellId or profileConsumableData.aura;
			local auraInstanceID = auraInfo and auraInfo.auraInstanceID;
			preExpireFired = true;
			SIPPYCUP.Popups.QueuePopupAction(2, spellId, auraInfo or nil, auraInstanceID, nil, "CheckPreExpirationForSingleConsumable");
		elseif SIPPYCUP.db.global.PreExpirationChecks then
			-- Schedule our 1m before expiration reminder.
			SIPPYCUP.Auras.CreatePreExpirationTimer(fireIn, auraInfo, key, auraID);
		end
	end

	return preExpireFired;
end
