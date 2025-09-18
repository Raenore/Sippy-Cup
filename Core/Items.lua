-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Items = {};

local scheduledItemTimers = {};

local function BuildItemKey(auraID, itemID, reason)
    return table.concat({auraID, itemID, reason}, "-")
end

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
		key = BuildItemKey(auraID, itemID, reason);
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
			optionData = nil,
			profileOptionData = nil,
			reason = reason,
		};
		-- Fire the popup
		SIPPYCUP.Popups.QueuePopupAction(data, "CreateItemTimer - Item - Reason: " .. reason);
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
			key = BuildItemKey(auraID, itemID, reason);
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

	-- noAuraTrackableProfile holds only enabled no aura options.
	for _, profileOptionData in pairs(SIPPYCUP.Database.noAuraTrackableProfile) do
		SIPPYCUP.Items.CheckNoAuraSingleOption(profileOptionData, profileOptionData.aura, minSeconds);
	end
end

---CheckNoAuraSingleOption evaluates cooldowns for non-aura items/toys to fire pre-expiration and removal popups.
---@param profileOptionData table? Optional profile data; will be resolved if nil.
---@param spellID number The spell ID to track.
---@param minSeconds number? Time window to check ahead, defaults to 180.
---@param startTime number? Optional cooldown start time.
---@return boolean preExpireFired True if a pre-expiration popup was fired.
function SIPPYCUP.Items.CheckNoAuraSingleOption(profileOptionData, spellID, minSeconds, startTime)
	minSeconds = minSeconds or 180;
	local preExpireFired = false;

	-- Data sent through/around loading screens will not be reliable, so skip that.
	if SIPPYCUP.States.loadingScreen then
		return preExpireFired;
	end

	if not profileOptionData then
		profileOptionData = SIPPYCUP.Database.FindMatchingProfile(spellID);
	end

	-- Sanity check: if profileOptionData is nil or is not a no aura, bail out
	if not profileOptionData or not profileOptionData.noAuraTrackable then
		return preExpireFired;
	end

	local auraID = profileOptionData.aura;
	local optionData = SIPPYCUP.Options.ByAuraID[auraID];

	-- Make sure there is valid optionData (sanity check).
	if not optionData then
		return preExpireFired;
	end

	-- At this point in time, we have a confirmed "no aura" item that we can only track through the spell or item cooldown.
	local now = GetTime();
	-- Unfortunately duration can be 5 seconds (GCD), so we pull from the spell's base cooldown associated with the item.
	local duration;

	local trackBySpell = false;
	local trackByItem = false;

	-- Determine tracking method
	if optionData.type == 0 then
		trackBySpell = optionData.spellTrackable;
		trackByItem = optionData.itemTrackable;
	elseif optionData.type == 1 then
		-- Always track by item if itemTrackable
		if optionData.itemTrackable then
			trackByItem = true;
		end

		if optionData.spellTrackable then
			if SIPPYCUP.global.UseToyCooldown then
				trackByItem = true;
			else
				trackBySpell = true;
			end
		end
	end

	if trackBySpell then
		local spellCooldownInfo = C_Spell.GetSpellCooldown(auraID);
		startTime = startTime or (spellCooldownInfo and spellCooldownInfo.startTime);
		local durationMS = GetSpellBaseCooldown(auraID);
		duration = durationMS / 1000;
	elseif trackByItem then
		startTime, duration = C_Item.GetItemCooldown(optionData.itemID);
	end

	-- SIPPYCUP_OUTPUT.Debug({startTime = startTime, duration = duration, expirationTime = expirationTime, remaining = remaining});

	-- Cleanup opened popups, nontrackable auras don't fire stack updates so we can't evaluate it in other places.
	local existingPopup = SIPPYCUP.Popups.activeByLoc[optionData.loc];

	-- This is a reliable check, but toys (type 1) might not immediately report a cooldown. But their usage generally means we can close their popup.
	if startTime and startTime > 0 or optionData.type == 1 then
		profileOptionData.currentStacks = 1;
		SIPPYCUP.Database.noAuraTrackableProfile[optionData.itemID] = profileOptionData;

		if existingPopup and existingPopup:IsShown() then
			existingPopup:Hide();
		end
	end

	-- If pre-expiration checks are not on, or pre-expiration is not a thing for this item, return false.
	if not SIPPYCUP.global.PreExpirationChecks or not optionData.preExpiration then
		return preExpireFired;
	end

	-- default warning offset to 60s
	local preOffset = 60.0;
	-- Calculate how many seconds are left on cooldown right now.
	local expirationTime = (startTime or 0) + (duration or 0);
	local remaining = math.max(0, expirationTime - now);

	if remaining == 0 then
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

		if fireIn <= 0 then
			-- Less than 60s left and we want pre-expiration popup: fire immediately
			preExpireFired = true;

			local data = {
				active = true,
				auraID = auraID,
				auraInfo = nil,
				optionData = optionData,
				profileOptionData = profileOptionData,
				reason = SIPPYCUP.Popups.Reason.PRE_EXPIRATION,
			};
			SIPPYCUP.Popups.QueuePopupAction(data, "CheckNonTrackableSingleConsumable - pre-expiration");
		else
			-- Schedule our 1m before expiration reminder.
			local key = BuildItemKey(auraID, optionData.itemID, SIPPYCUP.Popups.Reason.PRE_EXPIRATION);

			SIPPYCUP.Items.CreateItemTimer(fireIn, key, auraID, SIPPYCUP.Popups.Reason.PRE_EXPIRATION);
		end

		-- We also need to send a removal popup when the nontrackable item is gone if it falls within this check window.
		local key = BuildItemKey(auraID, optionData.itemID, SIPPYCUP.Popups.Reason.REMOVAL);
		SIPPYCUP.Items.CreateItemTimer(remaining, key, auraID, SIPPYCUP.Popups.Reason.REMOVAL);
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
