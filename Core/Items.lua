-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Items = {};

local scheduledItemTimers = {};

---CreateItemTimer will create a pre-expiration timer for a specific aura.
---Either pass in `key` directly, or pass `auraID` and `auraInstanceID` to build it.
---@param fireIn number The amount of seconds that should elapse before the timer fires.
---@param key string? Optional pre-expiration timer key. If not provided, will be built from auraID, reason and auraInstanceIDorItemID.
---@param auraID number Required if key is not provided.
---@param reason number The item's timer reason (1 = removal, 2 = pre-expire)
---@param itemID number? Required if key is not provided.
---@return boolean success True when the timer was created successfully.
function SIPPYCUP.Items.CreateItemTimer(fireIn, key, auraID, reason, itemID)
	local success = false;

	-- Validate inputs
	if type(fireIn) ~= "number" or fireIn <= 0 then
		return success;
	end

	-- If no key is given, we need auraID, reason and itemID to build it
	if not key then
		if type(auraID) ~= "number" or type(itemID) ~= "number" or type(reason) ~= "number" then
			return success;
		end
		key = tostring(auraID) .. "-" .. tostring(itemID) .. "-" .. tostring(reason);
	end

	-- Avoid double‐scheduling
	if scheduledItemTimers[key] then
		return success;
	end

	-- Schedule the timer
	local handle = C_Timer.NewTimer(fireIn, function()
		scheduledItemTimers[key] = nil;

		local data = {
			active = true,
			auraID = auraID,
			auraInfo = nil,
			consumableData = nil,
			profileConsumableData = nil,
			reason = reason,
		};
		-- Fire the popup
		SIPPYCUP.Popups.QueuePopupAction(data, "CreatePreExpirationTimer - Item - Reason: " .. reason);
	end);

	-- Store it for potential cancellation later
	scheduledItemTimers[key] = handle;
	success = true;
	return success;
end

---CancelItemTimer will cancel a chosen pre-expiration timer early.
---Either pass in `key` directly, or pass `auraID` and `auraInstanceID` to build it.
---@param key string? The pre‐expiration timer key, or nil to build from auraID+reason+itemID.
---@param auraID number? The aura ID (used only if key is nil or if you want to cancel timers by auraID).
---@param reason number? The item's timer reason (1 = removal, 2 = pre-expire)
---@param itemID number? The item ID (used only if key is nil).
---@return boolean success True when the timer was cancelled successfully.
function SIPPYCUP.Items.CancelItemTimer(key, auraID, reason, itemID)
	local success = false;

	-- If no key was provided, build it from auraID and auraInstanceID
	if not key then
		if auraID and reason and itemID then
			key = tostring(auraID) .. "-" .. tostring(itemID) .. "-" .. tostring(reason);
		elseif auraID and not reason and not itemID then
			-- Only auraID is available: cancel all timers with matching auraID
			local targetPrefix = tostring(auraID) .. "-";
			for k, timer in pairs(scheduledItemTimers) do
				if k:sub(1, #targetPrefix) == targetPrefix then
					success = true;
					timer:Cancel();
					scheduledItemTimers[k] = nil;
				end
			end
			return success;
		else
			-- Not enough info to build key or match by auraID
			return success;
		end
	end

	local expirationTimer = scheduledItemTimers[key];
	if expirationTimer then
		success = true;
		expirationTimer:Cancel();
		scheduledItemTimers[key] = nil;
	end

	return success;
end

---CancelAllItemTimers cancel every pre-expiration timer or only those matching a reason.
-- If reason is nil, all timers are canceled.
-- If reason is a number (1 = removal, 2 = pre-expire), only timers whose key ends in "-<reason>" are canceled.
---@param reason number? reason to filter by; nil to cancel all
---@return nil
function SIPPYCUP.Items.CancelAllItemTimers(reason)
	if reason == nil then
		for key, handle in pairs(scheduledItemTimers) do
			handle:Cancel();
			scheduledItemTimers[key] = nil;
		end
	else
		local reasonStr = tostring(reason);
		for key, handle in pairs(scheduledItemTimers) do
			local keyReason = key:match(".*%-(%d+)$");
			if keyReason == reasonStr then
				handle:Cancel();
				scheduledItemTimers[key] = nil;
			end
		end
	end
end

---CheckNoAuraItemUsage Monitors item usage for items that skip UNIT_AURA.
---@param minSeconds number? The minimum amount of seconds the duration should be above before it starts handling more, default is 180 (3 minutes).
---@return nil
function SIPPYCUP.Items.CheckNoAuraItemUsage(minSeconds)
	-- Data sent through/around loading screens will not be reliable, so skip that.
	if SIPPYCUP.States.loadingScreen then
		return;
	end

	-- noAuraTrackableProfile holds only enabled no aura consumables.
	for _, profileConsumableData in pairs(SIPPYCUP.Database.noAuraTrackableProfile) do
		SIPPYCUP.Items.CheckNoAuraSingleConsumable(profileConsumableData, profileConsumableData.aura, minSeconds);
	end
end

---CheckNoAuraSingleConsumable evaluates cooldowns for non-aura items to fire popups when expiring or missing.
---@param profileConsumableData table? Optional profile data; will be resolved if nil.
---@param spellID number The spell ID to track.
---@param minSeconds number? Time window to check ahead, defaults to 180.
---@param startTime number? Optional cooldown start time.
---@return boolean preExpireFired True if a pre-expiration popup was fired.
function SIPPYCUP.Items.CheckNoAuraSingleConsumable(profileConsumableData, spellID, minSeconds, startTime)
	if not minSeconds then
		minSeconds = 180.0;
	end

	local preExpireFired = false;

	-- Data sent through/around loading screens will not be reliable, so skip that.
	if SIPPYCUP.States.loadingScreen then
		return preExpireFired;
	end

	if not profileConsumableData then
		profileConsumableData = SIPPYCUP.Database.FindMatchingConsumable(spellID);
	end

	-- Sanity check: if profileConsumableData is nil or is not a no aura, bail out
	if not profileConsumableData or not profileConsumableData.noAuraTrackable then
		return preExpireFired;
	end

	local auraID = profileConsumableData and profileConsumableData.aura or spellID;
	local consumableData = SIPPYCUP.Consumables.ByAuraID[auraID];

	-- Make sure there is valid consumableData (sanity check).
	if not consumableData then
		return preExpireFired;
	end

	-- If consumalbe is "NoAura", we check the cooldown instead (of the spell or item, depending on what's available).
	local now = GetTime();
	-- Unfortunately duration can be 5 seconds (GCD), so we pull from the spell's base cooldown associated with the item.
	local duration;
	if consumableData.spellTrackable then
		local spellCooldownInfo = C_Spell.GetSpellCooldown(auraID);
		startTime = spellCooldownInfo and spellCooldownInfo.startTime;
		local durationMS = GetSpellBaseCooldown(auraID);
		duration = durationMS / 1000;
	elseif consumableData.itemTrackable then
		startTime, duration = C_Item.GetItemCooldown(consumableData.itemID);
	end

	-- Calculate how many seconds are left on cooldown right now.
	local expirationTime = startTime + duration;
	local remaining = math.max(0, expirationTime - now);

	-- SIPPYCUP_OUTPUT.Debug({startTime = startTime, duration = duration, expirationTime = expirationTime, remaining = remaining});

	-- Cleaup opened popups, nontrackable auras don't fire stack updates so we can't evaluate it in other places.
	local existingPopup = SIPPYCUP.Popups.activeByLoc[consumableData.loc];

	if startTime > 0 then
		profileConsumableData.currentStacks = 1;
		SIPPYCUP.Database.noAuraTrackableProfile[consumableData.itemID] = profileConsumableData;

		if existingPopup and existingPopup:IsShown() then
			existingPopup:Hide();
		end
	end

	-- default warning offset to 60s
	local preOffset = 60.0;

	if not SIPPYCUP.global.PreExpirationChecks or remaining == 0 then
		-- Pre‑expiration disabled means no offset at all
		preOffset = 0;
	elseif duration <= 60 then
		-- Pre‑checks enabled, short buff means 15s before expiry
		preOffset = 15;
	end

	-- How far out we’ll scan: look‑ahead + warning offset
	local windowHigh = minSeconds + preOffset;

	if remaining > 0 and remaining <= windowHigh then
		-- Schedule for “preOffset” seconds before expiration
		local fireIn = remaining - preOffset;
		local reason;

		if fireIn <= 0 and SIPPYCUP.global.PreExpirationChecks then
			-- Less than 60s left and we want pre-expiration popup: fire immediately
			preExpireFired = true;

			local data = {
				active = true,
				auraID = auraID,
				auraInfo = nil,
				consumableData = consumableData,
				profileConsumableData = profileConsumableData,
				reason = SIPPYCUP.Popups.Reason.PRE_EXPIRATION,
			};
			SIPPYCUP.Popups.QueuePopupAction(data, "CheckNonTrackableSingleConsumable - pre-expiration");
		elseif SIPPYCUP.global.PreExpirationChecks then
			-- Schedule our 1m before expiration reminder.
			reason = 2;
			local key = tostring(auraID) .. "-" .. tostring(consumableData.itemID)  .. "-" .. tostring(reason);

			SIPPYCUP.Items.CreateItemTimer(fireIn, key, auraID, 2); -- (1 = removal, 2 = pre-expire)
		end

		-- We also need to send a removal popup when the nontrackable item is gone if it falls within this check window.
		reason = 1;
		local key = tostring(auraID) .. "-" .. tostring(consumableData.itemID)  .. "-" .. tostring(reason);
		SIPPYCUP.Items.CreateItemTimer(remaining, key, auraID, 1); -- (1 = removal, 2 = pre-expire)
	end

	return preExpireFired;
end

SIPPYCUP.Items.bagUpdateUnhandled = false;

---HandleBagUpdate Marks bag data as synced and processes deferred popups.
-- Fires on BAG_UPDATE_DELAYED, which batches all bag changes after UNIT_AURA.
function SIPPYCUP.Items.HandleBagUpdate()
	SIPPYCUP.Items.bagUpdateUnhandled = false;

	-- Now that bag data is synced, process deferred actions using accurate data.
	SIPPYCUP.Popups.HandleDeferredActions("bag");
end
