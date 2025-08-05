-- Copyright The Sippy Cup Authors
-- Inspired by Total RP 3
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Flyway = {};

local SCHEMA_VERSION = 1;

local function ApplyPatches(fromBuild, toBuild)
	local patched = false;
	for i = fromBuild, toBuild do
		local patch = SIPPYCUP.Flyway.Patches[tostring(i)];
		local patchFn = type(patch) == "table" and patch.run or nil;

		if type(patchFn) == "function" then
			local desc = "Applying patch " .. i .. (patch.description and (": " .. patch.description) or "");
			SIPPYCUP_OUTPUT.Debug(desc);
			patchFn();
			patched = true;
		end
	end

	if patched then
		local logText = ("Patch applied from %s to %s on %s"):format(fromBuild - 1, toBuild, date("%d/%m/%y %H:%M:%S"));
		SIPPYCUP.db.global.Flyway.Log = logText;
	end
end

function SIPPYCUP.Flyway:ApplyPatches()
	-- Prevent running patches if the saved data is from a newer version than we support
	if SIPPYCUP.db.global.Flyway and SIPPYCUP.db.global.Flyway.CurrentBuild and SIPPYCUP.db.global.Flyway.CurrentBuild > SCHEMA_VERSION then
		SIPPYCUP_OUTPUT.Warn("Saved data is from a newer version (%s), skipping Flyway.", SIPPYCUP.db.global.Flyway.CurrentBuild);
		return;
	end

	SIPPYCUP.db.global.Flyway = SIPPYCUP.db.global.Flyway or {};

	if not SIPPYCUP.db.global.Flyway.CurrentBuild or SIPPYCUP.db.global.Flyway.CurrentBuild < SCHEMA_VERSION then
		ApplyPatches((SIPPYCUP.db.global.Flyway.CurrentBuild or 0) + 1, SCHEMA_VERSION);
	end

	SIPPYCUP.db.global.Flyway.CurrentBuild = SCHEMA_VERSION;
end
