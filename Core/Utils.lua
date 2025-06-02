-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.L = LibStub("AceLocale-3.0"):GetLocale("SippyCup", true);

SIPPYCUP_BUILDINFO = {};

---FormatBuild formats a build version into the major.minor.patch format.
---@param build string The raw build version string (6 digits).
---@return string formattedBuild The formatted build version in the format "major.minor.patch".
local function FormatBuild(build)
	build = tostring(build);

	local major = tonumber(string.sub(build, 1, 2));  -- First 2 digits, convert to number to remove leading zeros
	local minor = tonumber(string.sub(build, 3, 4));  -- Next 2 digits, convert to number to remove leading zeros
	local patch = tonumber(string.sub(build, 5, 6));  -- Last 2 digits, convert to number to remove leading zeros

	return major .. "." .. minor .. "." .. patch;
end

---ValidateLatestBuild compares the live game build with the addon's build version.
---@return boolean isLatestBuild True if the live build matches the addon's build, false otherwise.
function SIPPYCUP_BUILDINFO.ValidateLatestBuild()
	local liveBuild = tostring(select(4, GetBuildInfo()));
	local addonBuild = SIPPYCUP.AddonMetadata.addonBuild;

	return liveBuild == addonBuild;
end

---Output formats the addon's build version, optionally colorized based on whether it matches the live build.
---@param colorized boolean If true, the build version will be colorized based on whether it matches the live build.
---@return string formattedBuild The formatted build version, colorized if requested.
function SIPPYCUP_BUILDINFO.Output(colorized)
	local addonBuild = SIPPYCUP.AddonMetadata.addonBuild;
	if not addonBuild then
		return "Unknown Build";
	end

	local output = FormatBuild(addonBuild);

	if colorized then
		local color = SIPPYCUP_BUILDINFO.ValidateLatestBuild() and "|cnGREEN_FONT_COLOR:" or "|cnWARNING_FONT_COLOR:";
		output = color .. output .. "|r";
	end

	return output;
end

SIPPYCUP_ICON = {};

---RetrieveIcon fetches the icon for a consumable by its name.
---@param itemName string The name of the consumable item.
---@return string icon The icon path for the consumable, or a default "question mark" icon if not found.
function SIPPYCUP_ICON.RetrieveIcon(itemName)
	-- Grab the right consumable by name, and check if aura exists.
	local consumable = SIPPYCUP.Consumables.ByName[itemName];
	if consumable then
		return consumable.icon;
	end

	return "inv_misc_questionmark";
end

SIPPYCUP_OUTPUT = {};

---Write prints formatted output with an optional command prefix.
---@param output string|table The output to be printed, either a string or a table.
---@param command? string The optional command prefix to display before the output.
function SIPPYCUP_OUTPUT.Write(output, command)
	if type(output) == "table" then
		output = table.concat(output, "|n");
	end

	local formattedOutput = ("|cnGREEN_FONT_COLOR:%s|r|cnTRANSMOGRIFY_FONT_COLOR:%s|r"):format(command and (command .. " ") or "", output);

	SIPPYCUP_Addon:Print(formattedOutput);
end

---Write prints formatted output with an optional command prefix, only works when IS_DEV_BUILD is true.
---@param output string|table The output to be printed, either a string or a table.
---@param command? string The optional command prefix to display before the output.
function SIPPYCUP_OUTPUT.Debug(output, command)
	if not SIPPYCUP.IS_DEV_BUILD then
		return;
	end

	if type(output) == "table" then
		output = table.concat(output, "|n");
	end

	local formattedOutput = ("|cnGREEN_FONT_COLOR:%s|r|cnTRANSMOGRIFY_FONT_COLOR:%s|r"):format(command and (command .. " ") or "", output);

	SIPPYCUP_Addon:Print(formattedOutput);
end
