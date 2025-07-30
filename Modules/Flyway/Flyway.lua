-- Copyright The Sippy Cup Authors
-- Inspired by Total RP 3
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Flyway = {};

local SCHEMA_VERSION = 1;

local function ApplyPatches(fromBuild, toBuild)
	for i = fromBuild, toBuild do
		if type(SIPPYCUP.Flyway.Patches[tostring(i)]) == "function" then
			SIPPYCUP_OUTPUT.Debug("Applying patch %s", i);
			SIPPYCUP.Flyway.Patches[tostring(i)]();
		end
	end
	SIPPYCUP.db.global.Flyway.Log = ("Patch applied from %s to %s on %s"):format(fromBuild, toBuild, date("%d/%m/%y %H:%M:%S"));
end

function SIPPYCUP.Flyway:ApplyPatches()
	SIPPYCUP.db.global.Flyway = SIPPYCUP.db.global.Flyway or {};

	if not SIPPYCUP.db.global.Flyway.CurrentBuild or SIPPYCUP.db.global.Flyway.CurrentBuild < SCHEMA_VERSION then
		ApplyPatches((SIPPYCUP.db.global.Flyway.CurrentBuild or 0) + 1, SCHEMA_VERSION);
	end
	SIPPYCUP.db.global.Flyway.CurrentBuild = SCHEMA_VERSION;
end
