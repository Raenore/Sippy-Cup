-- Copyright The Sippy Cup Authors
-- Inspired by Total RP 3
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Flyway.Patches = {};

-- Patch 0.3.0 and flyway introduction
SIPPYCUP.Flyway.Patches["1"] = {
	run = function()
		if not SIPPYCUP.db or not SIPPYCUP.global then
			return;
		end

		if SIPPYCUP.global.PopupIcon ~= nil then
			SIPPYCUP_OUTPUT.Debug("Flyway Patch 1: Removing deprecated PopupIcon setting.");
			SIPPYCUP.global.PopupIcon = nil;
		end
	end,

	description = "Remove deprecated global PopupIcon setting (Flyway 0.3.0 init)",
};
