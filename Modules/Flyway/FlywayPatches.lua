-- Copyright The Sippy Cup Authors
-- Inspired by Total RP 3
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Flyway.Patches = {};

-- Patch 0.3.0 and flyway introduction
SIPPYCUP.Flyway.Patches["1"] = function()
	if not SIPPYCUP.db then
		return;
	end

	-- Remove popup icon option
	SIPPYCUP.db.global.PopupIcon = nil;
end
