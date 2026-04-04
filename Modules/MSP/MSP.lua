-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

---@class SippyCupMSP
local MSP = {};

---IsEnabled returns whether the MSP library is available and initialized.
---@return boolean
function MSP.IsEnabled()
	return (msp ~= nil and msp.my ~= nil);
end

MSP.FullName = "";
MSP.IC = false;

---CheckRPStatus evaluates the player's RP status via MSP.
---Returns whether the status changed, the previous RP status, and the newly calculated RP status.
---Also updates MSP.IC to the new value.
---@return boolean changed True if RP status changed, false if unchanged.
---@return boolean prevRP Previous RP status (false = OOC, true = IC).
---@return boolean newRP Newly calculated RP status (false = OOC, true = IC).
function MSP.CheckRPStatus()
	local prevRP = MSP.IC or false;
	local newRP = false;

	if MSP.IsEnabled() then
		-- "1" means OOC = false, anything else counts as IC = true
		newRP = msp.my.FC ~= "1";
	end

	MSP.IC = newRP;
	local changed = prevRP ~= newRP;

	return changed, prevRP, newRP;
end

---EnableIfAvailable sets up MSP integration if the library is present.
---@return boolean success True if MSP is available and integration was set up.
function MSP.EnableIfAvailable()
	if not MSP.IsEnabled() then
		return false;
	end

	-- First run we set everything in order.
	local name, realm = UnitFullName("player");
	MSP.FullName = format("%s-%s", name, realm);

	MSP.CheckRPStatus();

	-- Insert our code into the msp callback table
	if not MSP._callbackRegistered then
		table.insert(msp.callback["updated"], function(senderID)
			-- If MSP status checks are off, don't do anything, or if the addon is not ready.
			if not SC.Database:GetGlobalSetting("MSPStatusCheck") or not SC.Globals.States.addonReady then
				return;
			end

			-- If in combat, set MSP.IC but don't handle anything else.
			if InCombatLockdown() or SC.Globals.States.pvpMatch then
				MSP.CheckRPStatus();
				return;
			end

			-- Sometimes this gets spammed, we only care about handling IC/OOC updates.
			local changed, _, isIC = MSP.CheckRPStatus();

			-- If RP status remains the same before vs after this check, we just skip all handling after.
			if not changed then
				return;
			end

			if MSP.FullName == senderID then
				if isIC then
					-- Handle IC update, we check if all their enabled (even inactive ones) option stack sizes are in order.
					SC.Options.RefreshStackSizes(true);
				else
					-- Handle OOC update, we remove all popups.
					SC.Popups.HideAllRefreshPopups();
				end
			end
		end);
		MSP._callbackRegistered = true;
	end

	return true;
end

SC.MSP = MSP;
