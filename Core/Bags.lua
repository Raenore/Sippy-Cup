-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

---@class SippyCupBags
local Bags = {};

Bags.auraGeneration = 0;
Bags.bagGeneration = 0;

---BagUpdateDelayed records the time of the latest bag update and advances the bag generation counter.
---Fires on BAG_UPDATE_DELAYED, which batches all bag changes after UNIT_AURA.
---@return nil
function Bags.BagUpdateDelayed()
	Bags.lastBagUpdate = GetTime();
	Bags.bagGeneration = Bags.bagGeneration + 1;

	SC.Utils.Log("DEBUG", "Bag generation:", Bags.bagGeneration);
	Bags.ClearBagQueue();
end

---ClearBagQueue marks bag data as synchronized and processes deferred popups.
---Fires on BAG_UPDATE_DELAYED, which batches all bag changes after UNIT_AURA.
---@return nil
function Bags.ClearBagQueue()
	-- Flush deferred popups that were blocked by bag desync
	SC.Popups.HandleDeferredActions("bag", SC.Items.bagSyncedGeneration);
end

SC.Bags = Bags;
