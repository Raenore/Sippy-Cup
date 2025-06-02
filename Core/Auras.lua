-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Auras = {};

---CheckedEnabledAurasForConsumables iterates over all the enabled Sippy Cup consumables to see if they are active and passes that to Popup handling.
---@return nil
function SIPPYCUP.Auras.CheckedEnabledAurasForConsumables()
	local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID;

	for _, profileConsumableData in pairs(SIPPYCUP.db.profile) do
		if profileConsumableData.enable and profileConsumableData.aura then
			local auraInfo = GetPlayerAuraBySpellID(profileConsumableData.aura);

			if auraInfo then
				SIPPYCUP.Popups.QueuePopupAction(false, profileConsumableData.aura, auraInfo, auraInfo.auraInstanceID);
			end
		end
	end
end

---CheckEnabledAuras displays data on the currently tracking enabled consumables (even if they are zero).
---@return nil
function SIPPYCUP.Auras.DebugEnabledAuras()
	for _, profileConsumableData in pairs(SIPPYCUP.db.profile) do
		if profileConsumableData.enable and profileConsumableData.aura then
			local consumableData = SIPPYCUP.Consumables.ByAuraID[profileConsumableData.aura];
			local profileConsumableInfo = consumableData and SIPPYCUP.db.profile[consumableData.profile];

			if consumableData and profileConsumableInfo then
				SIPPYCUP_OUTPUT.Write("AuraID: " .. consumableData.auraID ..
					" - Name: " .. consumableData.name ..
					" - Desired Stacks: " .. profileConsumableInfo.desiredStacks ..
					" - Current Stacks: " .. profileConsumableInfo.currentStacks ..
					" - AuraInstanceID: " .. tostring(profileConsumableInfo.currentInstanceID));
			else
				SIPPYCUP_OUTPUT.Write("Missing data for auraID: " .. tostring(profileConsumableData.aura));
			end
		end
	end
end

---FindMatchingConsumable returns consumable profile data matching a given spell ID or aura instance ID.
---@param spellId number? The spell ID to match against (optional).
---@param instanceID number? The instance ID to match against (optional).
---@return table|nil consumableData The matching consumable profile data if found, or nil if not.
local function FindMatchingConsumable(spellId, instanceID)
	if not spellId and not instanceID then
		return nil;
	end

	for _, profileConsumableInfo in pairs(SIPPYCUP.db.profile) do
		if profileConsumableInfo.enable then
			if spellId and profileConsumableInfo.aura == spellId then
				return profileConsumableInfo;
			end
			if instanceID and profileConsumableInfo.currentInstanceID == instanceID then
				return profileConsumableInfo;
			end
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
	local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID;

	-- On aura application.
	if updateInfo.addedAuras then
		for _, auraInfo in ipairs(updateInfo.addedAuras) do
			local match = FindMatchingConsumable(auraInfo.spellId);
			if match then
				SIPPYCUP.Popups.QueuePopupAction(false, auraInfo.spellId, auraInfo, auraInfo.auraInstanceID);
			end
		end
	end

	-- On aura update.
	if updateInfo.updatedAuraInstanceIDs then
		for _, auraInstanceID in ipairs(updateInfo.updatedAuraInstanceIDs) do
			local match = FindMatchingConsumable(nil, auraInstanceID);
			if match then
				local auraInfo = GetAuraDataByAuraInstanceID("player", auraInstanceID);
				if auraInfo then
					SIPPYCUP.Popups.QueuePopupAction(false, auraInfo.spellId, auraInfo, auraInfo.auraInstanceID);
				end
			end
		end
	end

	-- On aura removal.
	if updateInfo.removedAuraInstanceIDs then
		for _, auraInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
			local match = FindMatchingConsumable(nil, auraInstanceID);
			if match then
				-- Unfortunately there are situations where if a user teleports, the client will send a removedAuraInstanceIDs.
				-- This will contain an aura that is not actually removed, but it seems to happen when PLAYER_ENTERING_WORLD is triggered.
				-- Below we try three times to see if we can find the associated aura in case it's a missfire, before we assume it's gone.

				-- First, immediate check:
				local auraInfoNow = GetPlayerAuraBySpellID(match.aura);
				SIPPYCUP_OUTPUT.Debug("First attempt at missfire check on auraInfo.");
				if auraInfoNow then
					-- Found immediately: treat as update, no removal.
					SIPPYCUP_OUTPUT.Debug("AuraInfo received in first attempt.");
					SIPPYCUP.Popups.QueuePopupAction(false,
						auraInfoNow.spellId,
						auraInfoNow,
						auraInfoNow.auraInstanceID
					);
				else
					-- Second check after 0.30s:
					C_Timer.After(0.30, function()
						local auraInfoLater = GetPlayerAuraBySpellID(match.aura);
						SIPPYCUP_OUTPUT.Debug("Second attempt at missfire check on auraInfo.");
						if auraInfoLater then
							-- It re-appeared (zoning delay). Queue as an update:
							SIPPYCUP_OUTPUT.Debug("AuraInfo received in second attempt.");
							SIPPYCUP.Popups.QueuePopupAction(false,
								auraInfoLater.spellId,
								auraInfoLater,
								auraInfoLater.auraInstanceID
							);
						else
							-- Third (final) check after 0.60s more:
							C_Timer.After(0.60, function()
								local auraInfoLast = GetPlayerAuraBySpellID(match.aura);
								SIPPYCUP_OUTPUT.Debug("Third (and final) attempt at missfire check on auraInfo.");
								if auraInfoLast then
									-- Found on third pass: treat as update.
									SIPPYCUP_OUTPUT.Debug("AuraInfo received in third attempt.");
									SIPPYCUP.Popups.QueuePopupAction(false,
										auraInfoLast.spellId,
										auraInfoLast,
										auraInfoLast.auraInstanceID
									);
								else
									-- Still not found: queue the removal popup.
									SIPPYCUP_OUTPUT.Debug("AuraInfo was not found, aura expired for real.");
									SIPPYCUP.Popups.QueuePopupAction(true, match.aura, nil, auraInstanceID);
								end
							end);
						end
					end);
				end
			end
		end
	end
end

---Convert adapts incoming aura events into the proper updateInfo format (UNIT_AURA).
---@param source number The source of the data.
---@param data table The data to be converted.
---@return nil
function SIPPYCUP.Auras.Convert(source, data)
	local updateInfo = {};

	if source == 1 then
		-- Source 1: AURA_INFO data is already in the correct updateInfo format.
		updateInfo = data;
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
	elseif source == 3 then
		-- Source 3: DB mismatch — simulate expired aura using its last known instance ID.
		updateInfo.removedAuraInstanceIDs = { data[1] };
	else
		-- Unknown source passed in — log to user so they can let us know.
		SIPPYCUP_OUTPUT.Write("Convert called with unknown source: " .. tostring(source));
		return;
	end

	if next(updateInfo) then
		ParseAura(updateInfo);
	end
end

---CheckStackMismatchInDB runs every 5 seconds to check if there is a mismatch between actual stacks and the DB.
---
---This can happen in the rare (but possible) case where UNIT_AURA did not catch a consumable expiration.
---@return nil
function SIPPYCUP.Auras.CheckStackMismatchInDB()
	local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID;

	for _, profileConsumableData in pairs(SIPPYCUP.db.profile) do
		-- If consumable is enabled and currentStacks > 0, it's considered ON.
		if profileConsumableData.enable and profileConsumableData.currentStacks > 0 then
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
end
