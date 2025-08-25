-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local function createTicker(self, handleField, interval, callback)
	if not self[handleField] then
		self[handleField] = C_Timer.NewTicker(interval, callback);
	end
end

local CONTINUOUS_CHECK_INTERVAL = 180.0;
---StartContinuousCheck begins repeating timers (3 minutes interval) for pre-expiration aura checks and no-aura item usage, if not in combat.
function SIPPYCUP_Addon:StartContinuousCheck()
	-- don’t run if we’re in combat or addon is not loaded fully.
	if InCombatLockdown() or not SIPPYCUP.States.addonReady then
		return;
	end

	-- Both below timers don't need an immediate run as startup + new enables run these partially.

	createTicker(self, "preExpTicker", CONTINUOUS_CHECK_INTERVAL, function()
		SIPPYCUP.Auras.CheckPreExpirationForAllActiveConsumables();
	end)

	createTicker(self, "itemTicker", CONTINUOUS_CHECK_INTERVAL, function()
		SIPPYCUP.Items.CheckNoAuraItemUsage();
	end)
end

---StopContinuousCheck cancels all continuous check timers if active.
function SIPPYCUP_Addon:StopContinuousCheck()
	if self.preExpTicker then
		self.preExpTicker:Cancel();
		self.preExpTicker = nil;
	end

	if self.itemTicker then
		self.itemTicker:Cancel();
		self.itemTicker = nil;
	end
end