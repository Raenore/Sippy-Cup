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
		SIPPYCUP.global.Flyway.Log = ("Patch applied from %s to %s on %s"):format(fromBuild, toBuild, date("%d/%m/%y %H:%M:%S"));
	end
end

function SIPPYCUP.Flyway:ApplyPatches()
	-- Prevent running patches if the saved data is from a newer version than we support
	if SIPPYCUP.global.Flyway and SIPPYCUP.global.Flyway.CurrentBuild and SIPPYCUP.global.Flyway.CurrentBuild > SCHEMA_VERSION then
		SIPPYCUP_OUTPUT.Warn("Saved data is from a newer version (%s), skipping Flyway.", SIPPYCUP.global.Flyway.CurrentBuild);
		return;
	end

	SIPPYCUP.global.Flyway = SIPPYCUP.global.Flyway or {};

	if not SIPPYCUP.global.Flyway.CurrentBuild or SIPPYCUP.global.Flyway.CurrentBuild < SCHEMA_VERSION then
		ApplyPatches((SIPPYCUP.global.Flyway.CurrentBuild or 0) + 1, SCHEMA_VERSION);
	end

	SIPPYCUP.global.Flyway.CurrentBuild = SCHEMA_VERSION;
end
