-- Copyright The Sippy Cup Authors
-- Inspired by Total RP 3
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Flyway = {};

local SCHEMA_VERSION = 2;

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
		SIPPYCUP.Database:SetGlobalSetting("Flyway", { Log = logText });
	end
end

function SIPPYCUP.Flyway:ApplyPatches()
	local flyway = SIPPYCUP.Database:GetGlobalSetting("Flyway");
	local currentBuild = flyway and flyway.CurrentBuild or 0;

	-- Prevent running patches if saved data is from a newer version than we support
	if currentBuild > SCHEMA_VERSION then
		SIPPYCUP_OUTPUT.Warn("Saved data is from a newer version (%s), skipping Flyway.", currentBuild);
		return;
	end

	if currentBuild < SCHEMA_VERSION then
		ApplyPatches(currentBuild + 1, SCHEMA_VERSION);
	end

	SIPPYCUP.Database:SetGlobalSetting("Flyway", { CurrentBuild = SCHEMA_VERSION });
end
