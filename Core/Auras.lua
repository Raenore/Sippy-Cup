-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Auras = {};

---CheckEnabledAuras displays data on the currently tracking enabled options (even if they are zero).
---@return nil
function SIPPYCUP.Auras.DebugEnabledAuras()
	for _, profileOptionData in pairs(SIPPYCUP.Database.auraToProfile) do
		local optionData = SIPPYCUP.Options.ByAuraID[profileOptionData.aura];

		if optionData then
			local output = table.concat({
				"AuraID: " .. optionData.auraID,
				"Name: " .. optionData.name,
				"Desired Stacks: " .. profileOptionData.desiredStacks,
				"Current Stacks: " .. profileOptionData.currentStacks,
				"AuraInstanceID: " .. tostring(profileOptionData.currentInstanceID),
			}, "|n");

			SIPPYCUP_OUTPUT.Write(output);
		else
			SIPPYCUP_OUTPUT.Write("Missing data for auraID: " .. tostring(profileOptionData.aura));
		end
	end
end

---QueueAuraAction enqueues a popup action for aura changes.
---@param profileOptionData table The option profile data.
---@param auraInfo table? The aura information, or nil if removed.
---@param reason number The reason for the popup (ADDITION, REMOVAL, etc).
---@param source string The source description of the action.
---@return nil
local function QueueAuraAction(profileOptionData, auraInfo, reason, source)
	local data = {
		active = auraInfo ~= nil,
		auraID = profileOptionData.aura,
		auraInfo = auraInfo,
		optionData = SIPPYCUP.Options.ByAuraID[profileOptionData.aura],
		profileOptionData = profileOptionData,
		reason = reason,
	}
	SIPPYCUP.Popups.QueuePopupAction(data, source);
end

---@class AuraUpdateInfo
---@field addedAuras table? List of added auras.
---@field updatedAuraInstanceIDs table? List of updated aura instance IDs.
---@field removedAuraInstanceIDs table? List of removed aura instance IDs.
---@field isFullUpdate boolean? True if this is a full aura update; all other fields will be nil.

---ParseAura extracts aura application, updates, and removals from updateInfo.
---@param updateInfo AuraUpdateInfo
---@return nil
local function ParseAura(updateInfo)
	local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID;
	local auraAdded = false;

	-- isFullUpdate true means nil values, invalidate the state.
	if updateInfo.isFullUpdate then
		-- If in loading screen, we process this later, otherwise immediately.
		if SIPPYCUP.States.loadingScreen then
			SIPPYCUP.States.hasSeenFullUpdate = true;
		else
			SIPPYCUP.Auras.CheckAllActiveOptions();
		end
	end

	-- On aura application (spellId secret in combat).
	local added = updateInfo.addedAuras;
	if added then
		for _, auraInfo in ipairs(updateInfo.addedAuras) do
			local profileOptionData = SIPPYCUP.Database.FindMatchingProfile(auraInfo.spellId);
			if profileOptionData and profileOptionData.enable then
				auraAdded = true;
				profileOptionData.currentInstanceID = auraInfo.auraInstanceID;
				SIPPYCUP.Database.instanceToProfile[auraInfo.auraInstanceID] = profileOptionData;

				SIPPYCUP.Auras.CheckPreExpirationForSingleOption(profileOptionData);

				QueueAuraAction(profileOptionData, auraInfo, SIPPYCUP.Popups.Reason.ADDITION, "ParseAura - addition");
			end
		end
	end

	-- On aura update (auraInstanceID is not secret).
	local updated = updateInfo.updatedAuraInstanceIDs;
	if updated then
		for _, auraInstanceID in ipairs(updateInfo.updatedAuraInstanceIDs) do
			local profileOptionData = SIPPYCUP.Database.FindMatchingProfile(nil, auraInstanceID);
			if profileOptionData and profileOptionData.enable then
				local auraInfo = GetAuraDataByAuraInstanceID("player", auraInstanceID);
				if auraInfo then
					auraAdded = true;
					-- This is not necessary, but a safety update just in case.
					profileOptionData.currentInstanceID = auraInfo.auraInstanceID;
					SIPPYCUP.Database.instanceToProfile[auraInfo.auraInstanceID] = profileOptionData;

					-- On aura update, we remove all pre-expiration timers as that's obvious no longer relevant.
					SIPPYCUP.Auras.CancelPreExpirationTimer(nil, profileOptionData.aura, auraInstanceID);
					SIPPYCUP.Auras.CheckPreExpirationForSingleOption(profileOptionData);

					QueueAuraAction(profileOptionData, auraInfo, SIPPYCUP.Popups.Reason.ADDITION, "ParseAura - updated");
				end
			end
		end
	end

	-- On aura removal (auraInstanceID is not secret).
	local removed = updateInfo.removedAuraInstanceIDs;
	if removed then
		for _, auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
			local profileOptionData = SIPPYCUP.Database.FindMatchingProfile(nil, auraInstanceID);
			if profileOptionData and profileOptionData.enable and profileOptionData.currentInstanceID then
				SIPPYCUP.Database.instanceToProfile[auraInstanceID] = nil;
				profileOptionData.currentInstanceID = nil;

				-- On aura removal, we remove all pre-expiration timers as that's obvious no longer relevant.
				SIPPYCUP.Auras.CancelPreExpirationTimer(nil, profileOptionData.aura, auraInstanceID);

				QueueAuraAction(profileOptionData, nil, SIPPYCUP.Popups.Reason.REMOVAL, "ParseAura - removed");
			end
		end
	end

	-- If no auras were added, there was no bag update so we mark bag as synchronized.
	if not auraAdded then
		SIPPYCUP.Items.HandleBagUpdate();
	end
end

SIPPYCUP.Auras.auraQueue = {};
SIPPYCUP.Auras.auraQueueScheduled = false;

---flushAuraQueue combines all the UNIT_AURA events in the same frame together, filtering them for weird exceptions.
---@return nil
local function flushAuraQueue()
	local queue = SIPPYCUP.Auras.auraQueue;
	SIPPYCUP.Auras.auraQueue = {};
	SIPPYCUP.Auras.auraQueueScheduled = false;

	-- Merge all queued updateInfo into one combined table.
	local combined = {
		addedAuras = {},
		updatedAuraInstanceIDs = {},
		removedAuraInstanceIDs = {},
	};

	-- Deduplication arrays
	local seenAdd, seenUpdate, seenRemoval = {}, {}, {};
	local isFullUpdate = false

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

		local updated = updateInfo.updatedAuraInstanceIDs;
		if updated then
			for i = 1, #updated do
				seenUpdate[updated[i]] = true;
			end
		end

		local removed = updateInfo.removedAuraInstanceIDs;
		if removed then
			for i = 1, #removed do
				seenRemoval[removed[i]] = true;
			end
		end

		if updateInfo.isFullUpdate then
			isFullUpdate = true;
		end
	end

	-- 2) convert any remove+add-of-same-spell into an update
	for removedID in pairs(seenRemoval) do
		local profileOptionData = SIPPYCUP.Database.instanceToProfile[removedID];
		if profileOptionData then
			local auraID = profileOptionData.aura;
			for addID, auraInfo in pairs(seenAdd) do
				if auraInfo.spellId == auraID then
					-- cancel any pre-expiration timer keyed by this spell+instance
					local key = tostring(auraID) .. "-" .. tostring(removedID);
					SIPPYCUP.Auras.CancelPreExpirationTimer(key);

					seenRemoval[removedID] = nil;
					seenUpdate[addID] = true;

					-- Update linkage
					SIPPYCUP.Database.instanceToProfile[removedID] = nil;
					profileOptionData.currentInstanceID = addID;
					SIPPYCUP.Database.instanceToProfile[addID] = profileOptionData;
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

	for instanceID in pairs(seenUpdate) do
		combined.updatedAuraInstanceIDs[#combined.updatedAuraInstanceIDs + 1] = instanceID;
	end

	for instanceID in pairs(seenRemoval) do
		combined.removedAuraInstanceIDs[#combined.removedAuraInstanceIDs + 1] = instanceID;
	end

	combined.isFullUpdate = isFullUpdate;

	-- 5) finally invoke ParseAura
	ParseAura(combined);
end

SIPPYCUP.Auras.Sources = {
	UNIT_AURA = 1,
	CLE = 2,
	ADD_AURA = 3,
	UPDATE_AURA = 4,
	REMOVE_AURA = 5,
};

---Convert adapts incoming aura events into the proper updateInfo format (UNIT_AURA).
---@param source number The source of the data.
---@param data table The data to be converted.
---@return nil
function SIPPYCUP.Auras.Convert(source, data)
	local updateInfo = {};

	if source == SIPPYCUP.Auras.Sources.UNIT_AURA then
		-- Source 1: UNIT_AURA provides the right shape, but copy to avoid Blizzard table reuse.
		if data.addedAuras then
			updateInfo.addedAuras = { unpack(data.addedAuras) };
		end
		if data.updatedAuraInstanceIDs then
			updateInfo.updatedAuraInstanceIDs = { unpack(data.updatedAuraInstanceIDs) };
		end
		if data.removedAuraInstanceIDs then
			updateInfo.removedAuraInstanceIDs = { unpack(data.removedAuraInstanceIDs) };
		end
		updateInfo.isFullUpdate = data.isFullUpdate;
	elseif source == SIPPYCUP.Auras.Sources.CLE then
		-- Source 2: Combat Log events (e.g., SPELL_AURA_APPLIED).
		-- Currently unused, but might return at some point.
		local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(data[2]);

		if data[1] == "SPELL_AURA_APPLIED" and auraInfo then
			updateInfo.addedAuras = { auraInfo };
		elseif data[1] == "SPELL_AURA_APPLIED_DOSE" and auraInfo then
			updateInfo.updatedAuraInstanceIDs = { auraInfo.auraInstanceID };
		elseif data[1] == "SPELL_AURA_REMOVED" and auraInfo then
			updateInfo.removedAuraInstanceIDs = { auraInfo.auraInstanceID };
		end
	elseif source == SIPPYCUP.Auras.Sources.ADD_AURA then
		-- Source 3: Handle added auras not sent through UNIT_AURA
		updateInfo.addedAuras = data;
	elseif source == SIPPYCUP.Auras.Sources.UPDATE_AURA then
		-- Source 4: Handle updates to auras not sent through UNIT_AURA
		-- e.g. Instance ID Update — simulate updated aura using with a new instance ID.
		updateInfo.updatedAuraInstanceIDs = { data[1] };
	elseif source == SIPPYCUP.Auras.Sources.REMOVE_AURA then
		-- Source 5: Handle removed auras not sent through UNIT_AURA
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
	SIPPYCUP.Auras.auraQueue[#SIPPYCUP.Auras.auraQueue + 1] = updateInfo

	-- flush on the next frame (which will run the batched UNIT_AURAs)
	if not SIPPYCUP.Auras.auraQueueScheduled then
		SIPPYCUP.Auras.auraQueueScheduled = true;
		RunNextFrame(flushAuraQueue);
	end
end

---CheckAllActiveOptions checks enabled options and updates their aura status.
---Triggers add, update, or remove conversions based on aura presence and instance ID changes.
---@return nil
function SIPPYCUP.Auras.CheckAllActiveOptions()
	-- Data sent through/around loading screens will not be reliable, so skip that.
	if SIPPYCUP.States.loadingScreen then
		return;
	end

	local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID;
	local auraToProfile = SIPPYCUP.Database.auraToProfile;
	local instanceToProfile = SIPPYCUP.Database.instanceToProfile;
	local Convert = SIPPYCUP.Auras.Convert;

	-- auraToProfile holds only enabled options (whether they are active or not).
	for _, profileOptionData in pairs(auraToProfile) do
		local currentInstanceID = profileOptionData.currentInstanceID
		-- True if it's active (or was), false if it's not been active.
		local canBeActive = (currentInstanceID or 0) ~= 0;
		local auraInfo = GetPlayerAuraBySpellID(profileOptionData.aura);

		if not auraInfo then
			-- auraInfo does and was meant to be active, meaning the spell was removed.
			if canBeActive then
				-- Prepare this option to get popup'd anew, by faking a "this has expired" call to our system.
				-- Don't worry about ignored or other stuff, popups handle this later in the chain.
				Convert(SIPPYCUP.Auras.Sources.REMOVE_AURA, { currentInstanceID });
				instanceToProfile[currentInstanceID] = nil;
			end
		else
			local newInstanceID = auraInfo.auraInstanceID;

			if canBeActive then
				-- The spell was active but the InstanceIDs are different, so we assume the InstanceID was changed.
				if currentInstanceID ~= newInstanceID then
					instanceToProfile[currentInstanceID] = nil;
					profileOptionData.currentInstanceID = newInstanceID;
					instanceToProfile[newInstanceID] = profileOptionData;

					SIPPYCUP_OUTPUT.Debug("InstanceID Changed!|nName:", auraInfo.name, "|nSpellID:", profileOptionData.aura, "|nOld:", currentInstanceID, "|nNew:", newInstanceID);
					Convert(SIPPYCUP.Auras.Sources.UPDATE_AURA, { newInstanceID });
				end
			else
				-- There is auraInfo data but the spell was not marked as active, this means it was added but we did not catch it.
				Convert(SIPPYCUP.Auras.Sources.ADD_AURA, auraInfo);
			end
		end
	end
end

---CheckInstanceIDForAllActiveOptions checks and updates active options aura instance IDs, removing expired ones.
---@return nil
function SIPPYCUP.Auras.CheckInstanceIDForAllActiveOptions()
	-- Data sent through/around loading screens will not be reliable, so skip that.
	if SIPPYCUP.States.loadingScreen then
		return;
	end

	local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID;
	local instanceToProfile = SIPPYCUP.Database.instanceToProfile;
	local Convert = SIPPYCUP.Auras.Convert;

	-- instanceToProfile holds only enabled and active options (with a known instanceID) AKA the ones our DB thinks are running.
	for oldInstanceID, profileOptionData in pairs(instanceToProfile) do
		-- Sometimes aura instanceIDs are changed between loading screens or such while they're still active.
		local auraInfo = GetPlayerAuraBySpellID(profileOptionData.aura);

		-- If no auraInfo exists, the spell was actually removed.
		if not auraInfo then
			-- Prepare this option to get popup'd anew, by faking a "this has expired" call to our system.
			-- Don't worry about ignored or other stuff, popups handle this later in the chain.
			Convert(SIPPYCUP.Auras.Sources.REMOVE_AURA, { oldInstanceID });
			instanceToProfile[oldInstanceID] = nil;
		else
			local newInstanceID = auraInfo.auraInstanceID;

			-- Given auraInfo still exists, it means it wasn't really removed, we switch out some details.
			if oldInstanceID ~= newInstanceID then
				instanceToProfile[oldInstanceID] = nil;
				profileOptionData.currentInstanceID = newInstanceID;
				instanceToProfile[newInstanceID] = profileOptionData;

				SIPPYCUP_OUTPUT.Debug("InstanceID Changed!|nName:", auraInfo.name, "|nSpellID:", profileOptionData.aura, "|nOld:", oldInstanceID, "|nNew:", newInstanceID);
				Convert(SIPPYCUP.Auras.Sources.UPDATE_AURA, { newInstanceID });
			end
		end
	end
end

local scheduledPreExpirationAuraTimers = {};

local function BuildAuraKey(auraID, instanceID)
	return tostring(auraID) .. "-" .. tostring(instanceID)
end

---CreatePreExpirationTimer schedules a pre-expiration popup for a specific aura.
---Either pass in `key` directly, or provide `auraID` and `auraInstanceID` to build it.
---@param fireIn number Seconds until the timer fires.
---@param auraInfo table? Optional aura information.
---@param key string? Optional timer key. Built from auraID/auraInstanceID if nil.
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
		key = BuildAuraKey(auraID, auraInstanceID);
	end

	-- Avoid double‐scheduling
	if scheduledPreExpirationAuraTimers[key] then
		return;
	end

	-- Schedule the timer
	local handle = C_Timer.NewTimer(fireIn, function()
		scheduledPreExpirationAuraTimers[key] = nil;
		local data = {
			active = auraInfo ~= nil,
			auraID = auraInfo and auraInfo.spellId or auraID,
			auraInfo = auraInfo,
			optionData = nil,
			profileOptionData = nil,
			reason = SIPPYCUP.Popups.Reason.PRE_EXPIRATION,
		};
		-- Fire the popup
		SIPPYCUP.Popups.QueuePopupAction(data, "CreatePreExpirationTimer - Aura");
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
			key = BuildAuraKey(auraID, auraInstanceID);
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

---CheckPreExpirationForAllActiveOptions sets up pre-expiration timers for all active options before popup.
---@param minSeconds number? Minimum duration in seconds required before scheduling a timer. Default is 180.
---@return nil
function SIPPYCUP.Auras.CheckPreExpirationForAllActiveOptions(minSeconds)
	-- Data sent through/around loading screens will not be reliable, so skip that.
	if SIPPYCUP.States.loadingScreen or not SIPPYCUP.global.PreExpirationChecks then
		return;
	end

	-- instanceToProfile holds only enabled, active and trackable options (with a known instanceID), as inactive enabled ones shouldn't have timers.
	for _, profileOptionData in pairs(SIPPYCUP.Database.instanceToProfile) do
		SIPPYCUP.Auras.CheckPreExpirationForSingleOption(profileOptionData, minSeconds);
	end
end

---CheckPreExpirationForSingleOption sets up pre-expiration warnings for aura-based options.
---@param profileOptionData table Profile data for the option.
---@param minSeconds number? Time window to check ahead, defaults to 180.
---@return boolean preExpireFired True if a pre-expiration popup was fired.
function SIPPYCUP.Auras.CheckPreExpirationForSingleOption(profileOptionData, minSeconds)
	local preExpireFired = false;

	-- If pre-expiration checks can't be done, why are we even here?
	if SIPPYCUP.States.loadingScreen or not SIPPYCUP.global.PreExpirationChecks then
		return preExpireFired;
	end

	minSeconds = minSeconds or 180.0;
	-- default warning offset to 60s
	local preOffset = 60.0;
	local auraID = profileOptionData.aura;
	local auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(auraID);

	-- If there's no auraInfo, stop here.
	if not auraInfo then
		return preExpireFired;
	end

	local active = true;
	local key = BuildAuraKey(auraID, auraInfo.auraInstanceID);
	local optionData = SIPPYCUP.Options.ByAuraID[auraID];

	if not optionData.preExpiration or scheduledPreExpirationAuraTimers[key] then
		return preExpireFired;
	end

	profileOptionData.currentStacks = SIPPYCUP.Auras.CalculateCurrentStacks(auraInfo, auraID, 0, active);

	-- Some stack items can be pre-expired for refresh but ONLY if the current stacks == maxStacks
	if optionData.stacks and profileOptionData.currentStacks ~= optionData.maxStacks then
		return preExpireFired;
	end

	local now = GetTime();
	local remaining = auraInfo.expirationTime - now;
	local duration = auraInfo.duration;

	-- If the option only lasts for 60 seconds, we warn at 15 seconds.
	if duration <= 60 then
		preOffset = 15;
	end

	-- How far out we’ll scan: look‑ahead + warning offset
	local windowHigh = minSeconds + preOffset;

	-- Only care about auras that will expire before our next 180s (or custom) scan
	if remaining > 0 and remaining <= windowHigh then
		-- Schedule for "preOffset" seconds before expiration
		local fireIn = remaining - preOffset;

		if fireIn <= 0 and SIPPYCUP.global.PreExpirationChecks then
			-- Less than 60s left and we want pre-expiration popup: fire immediately
			preExpireFired = true;

			local data = {
				active = auraInfo ~= nil,
				auraID = auraID,
				auraInfo = auraInfo,
				optionData = optionData,
				profileOptionData = profileOptionData,
				reason = SIPPYCUP.Popups.Reason.PRE_EXPIRATION,
			};
			SIPPYCUP.Popups.QueuePopupAction(data, "CheckPreExpirationForSingleOption - pre-expiration");
		elseif SIPPYCUP.global.PreExpirationChecks then
			-- Schedule our 1m before expiration reminder.
			SIPPYCUP.Auras.CreatePreExpirationTimer(fireIn, auraInfo, key, auraID);
		end
	end

	return preExpireFired;
end

---@param auraInfo table? Information about the aura, or nil if not present.
---@param auraID number The aura ID.
---@param reason number The situation to calculate stacks for (0 - add/update, 1 = removal, 2 = pre-expire, 3 = toggle)
---@param active boolean Whether the aura is currently active (false = inactive, true = active).
---@return number currentStacks The current stacks for this aura.
function SIPPYCUP.Auras.CalculateCurrentStacks(auraInfo, auraID, reason, active)
	reason = reason or SIPPYCUP.Popups.Reason.ADDITION;

	if not auraInfo then
		auraInfo = C_UnitAuras.GetPlayerAuraBySpellID(auraID);
	end

	-- Deal with possible inacurracies from deferrment
	if auraInfo and not active then
		reason = SIPPYCUP.Popups.Reason.TOGGLE;
		active = true;
	end

	-- Case 1: Aura removed or missing
	if not active or reason == SIPPYCUP.Popups.Reason.REMOVAL or not auraInfo then
		return 0;
	end

	-- Case 2: Pre-expiration (return maxStacks - 1 for stackable that require 1 re-application for full)
	if reason == SIPPYCUP.Popups.Reason.PRE_EXPIRATION then
		local optionData = SIPPYCUP.Options.ByAuraID[auraID];
		local profileOptionData = SIPPYCUP.Profile[auraID];

		if optionData.stacks and profileOptionData.currentStacks == optionData.maxStacks then
			return optionData.maxStacks - 1;
		end

		return 0;
	end

	-- Case 0: Normal add/update (return applications or 1)
	return math.max(auraInfo.applications or 0, 1);
end
