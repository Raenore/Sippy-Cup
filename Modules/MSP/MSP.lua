-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.MSP = {};

function SIPPYCUP.MSP.IsEnabled()
	return msp and msp.my ~= nil;
end

function SIPPYCUP.MSP.EnableIfAvailable()
	if not msp or not msp.my then
		return false;
	end

	local startupCheck = true;
	local refreshedStackSizes = false;

	table.insert(msp.callback["updated"], function(senderID)
		if not SIPPYCUP.global.MSPStatusCheck then
			if startupCheck then
				SIPPYCUP.Consumables.RefreshStackSizes(false);
				startupCheck = false;
				refreshedStackSizes = true;
			end
			return;
		end

		-- Sometimes this gets spammed, we only care about handling IC/OOC updates.
		local previousIsOOC = SIPPYCUP.Player.OOC;
		local newIsOOC = SIPPYCUP_PLAYER.CheckOOCStatus();
		SIPPYCUP.Player.OOC = newIsOOC;

		-- If RP status remains the same before vs after this check, we just skip all handling after.
		if previousIsOOC ~= nil and newIsOOC ~= nil and previousIsOOC == newIsOOC then
			return;
		end

		-- When update callback is found, we check the IC PLAYER if all their enabled (even inactive ones) consumable stack sizes are in order.
		if startupCheck and not SIPPYCUP.Player.OOC then
			SIPPYCUP.Consumables.RefreshStackSizes(true);
			startupCheck = false;
			refreshedStackSizes = true;
			return;
		end

		if SIPPYCUP.Player.FullName == senderID then
			-- Handle IC update, we check if all their enabled (even inactive ones) consumable stack sizes are in order.
			if not SIPPYCUP.Player.OOC then
				SIPPYCUP.Consumables.RefreshStackSizes(true);
				refreshedStackSizes = true;
			-- Handle OOC update, we remove all popups.
			else
				SIPPYCUP.Popups.HideAllRefreshPopups();
			end
		end
	end);

	-- First run we set everything in order.
	local isOOC = SIPPYCUP_PLAYER.CheckOOCStatus();
	SIPPYCUP.Player.OOC = isOOC;

	if not refreshedStackSizes then
		SIPPYCUP.Consumables.RefreshStackSizes(true);
	end

	return true;
end
