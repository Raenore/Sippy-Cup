-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Bags = {};

SIPPYCUP.Bags.auraGeneration = 0;
SIPPYCUP.Bags.bagGeneration = 0;

function SIPPYCUP.Bags.BagUpdateDelayed()
	SIPPYCUP.Bags.lastBagUpdate = GetTime();
	SIPPYCUP.Bags.bagGeneration = SIPPYCUP.Bags.bagGeneration + 1;

	SIPPYCUP_OUTPUT.Debug("Bag generation:", SIPPYCUP.Bags.bagGeneration);
	SIPPYCUP.Bags.ClearBagQueue();
end

---HandleBagUpdate marks bag data as synchronized and processes deferred popups.
-- Fires on BAG_UPDATE_DELAYED, which batches all bag changes after UNIT_AURA.
function SIPPYCUP.Bags.ClearBagQueue()
	-- Flush deferred popups that were blocked by bag desync
	SIPPYCUP.Popups.HandleDeferredActions("bag", SIPPYCUP.Items.bagSyncedGeneration);
end
