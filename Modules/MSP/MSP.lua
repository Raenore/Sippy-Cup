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

	-- First run we set everything in order.
	local isOOC = SIPPYCUP_PLAYER.CheckOOCStatus();
	SIPPYCUP.Player.OOC = isOOC;

	-- Insert our code into the msp callback table
	table.insert(msp.callback["updated"], function(senderID)
		-- If MSP status checks are off, don't do anything, or if the addon startup is not done.
		if not SIPPYCUP.global.MSPStatusCheck or not SIPPYCUP.State.startupLoaded then
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

		if SIPPYCUP.Player.FullName == senderID then
			if not SIPPYCUP.Player.OOC then
				-- Handle IC update, we check if all their enabled (even inactive ones) consumable stack sizes are in order.
				SIPPYCUP.Consumables.RefreshStackSizes(true);
			else
				-- Handle OOC update, we remove all popups.
				SIPPYCUP.Popups.HideAllRefreshPopups();
			end
		end
	end);

	return true;
end
