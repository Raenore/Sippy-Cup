-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.MSP = {};

function SIPPYCUP.MSP.IsEnabled()
	return msp and msp.my ~= nil;
end

function SIPPYCUP.MSP.EnableIfAvailable()
	local success = false;
	local refreshedStackSizes = false;
	if msp and msp.my then
		success = true;
		local startupCheck = true;
		table.insert(msp.callback["updated"], function(senderID)
			-- Don't run updated if MSP status is not being checked.
			if not SIPPYCUP.db.global.MSPStatusCheck then
				if startupCheck then
					SIPPYCUP.Consumables.RefreshStackSizes(false);
				end
				startupCheck = false;
				refreshedStackSizes = true;
				return success;
			end

			-- Sometimes this gets spammed, we only care about handling IC/OOC updates.
			local previousIsOOC = SIPPYCUP.Player.OOC;
			local newIsOOC = SIPPYCUP_PLAYER.CheckOOCStatus();
			SIPPYCUP.Player.OOC = newIsOOC;
			-- If RP status remains the same before vs after this check, we just skip all handling after.
			if previousIsOOC ~= nil and newIsOOC ~= nil and previousIsOOC == newIsOOC then
				return success;
			end

			-- When update callback is found, we check the IC PLAYER if all their enabled (even inactive ones) consumable stack sizes are in order.
			if startupCheck and not SIPPYCUP.Player.OOC then
				SIPPYCUP.Consumables.RefreshStackSizes(true);
				startupCheck = false;
				refreshedStackSizes = true;
				return success;
			end

			-- Handle IC update, we check if all their enabled (even inactive ones) consumable stack sizes are in order.
			if SIPPYCUP.Player.FullName == senderID and not SIPPYCUP.Player.OOC then
				SIPPYCUP.Consumables.RefreshStackSizes(true);
				refreshedStackSizes = true;
			end

			-- Handle OOC update, we remove all popups.
			if SIPPYCUP.Player.FullName == senderID and SIPPYCUP.Player.OOC then
				SIPPYCUP.Popups.HideAllRefreshPopups();
			end
		end)
	end

	-- First run we set everything in order.
	if success then
		local isOOC = SIPPYCUP_PLAYER.CheckOOCStatus();
		SIPPYCUP.Player.OOC = isOOC;
		if not refreshedStackSizes then
			SIPPYCUP.Consumables.RefreshStackSizes(true);
		end
	end

	return success;
end
