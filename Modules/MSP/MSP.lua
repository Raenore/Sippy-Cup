-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.MSP = {};

function SIPPYCUP.MSP.IsEnabled()
	return (msp ~= nil and msp.my ~= nil);
end

SIPPYCUP.MSP.FullName = "";
SIPPYCUP.MSP.IC = false;

---CheckRPStatus evaluates the player's RP status via MSP.
---Returns whether the status changed, the previous RP status, and the newly calculated RP status.
---Also updates SIPPYCUP.MSP.IC to the new value.
---@return boolean changed True if RP status changed, false if unchanged.
---@return boolean prevRP Previous RP status (false = OOC, true = IC).
---@return boolean newRP Newly calculated RP status (false = OOC, true = IC).
function SIPPYCUP.MSP.CheckRPStatus()
	local prevRP = SIPPYCUP.MSP.IC or false;
	local newRP = false;

	if SIPPYCUP.MSP.IsEnabled() then
		-- "1" means OOC = false, anything else counts as IC = true
		newRP = msp.my.FC ~= "1";
	end

	SIPPYCUP.MSP.IC = newRP;
	local changed = prevRP ~= newRP;

	return changed, prevRP, newRP;
end

function SIPPYCUP.MSP.EnableIfAvailable()
	if not SIPPYCUP.MSP.IsEnabled() then
		return false;
	end

	-- First run we set everything in order.
	local name, realm = UnitFullName("player");
	SIPPYCUP.MSP.FullName = format("%s-%s", name, realm);

	SIPPYCUP.MSP.CheckRPStatus();

	-- Insert our code into the msp callback table
	if not SIPPYCUP.MSP._callbackRegistered then
		table.insert(msp.callback["updated"], function(senderID)
			-- If MSP status checks are off, don't do anything, or if the addon is not ready.
			if not SIPPYCUP.global.MSPStatusCheck or not SIPPYCUP.States.addonReady then
				return;
			end

			-- If in combat, set SIPPYCUP.MSP.IC but don't handle anything else.
			if InCombatLockdown() or SIPPYCUP.States.restricted then
				SIPPYCUP.MSP.CheckRPStatus();
				return;
			end

			-- Sometimes this gets spammed, we only care about handling IC/OOC updates.
			local changed, _, isIC = SIPPYCUP.MSP.CheckRPStatus();

			-- If RP status remains the same before vs after this check, we just skip all handling after.
			if not changed then
				return;
			end

			if SIPPYCUP.MSP.FullName == senderID then
				if isIC then
					-- Handle IC update, we check if all their enabled (even inactive ones) option stack sizes are in order.
					SIPPYCUP.Options.RefreshStackSizes(true);
				else
					-- Handle OOC update, we remove all popups.
					SIPPYCUP.Popups.HideAllRefreshPopups();
				end
			end
		end);
		SIPPYCUP.MSP._callbackRegistered = true;
	end

	return true;
end
