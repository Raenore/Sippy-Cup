-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

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

	if not addonBuild then
		return false;
	end

	for token in string.gmatch(addonBuild, "[^,%s]+") do
		if token == liveBuild then
			return true;
		end
	end

	return false;
end

---Output formats the addon's build version, optionally colorized based on whether it matches the live build.
---@param colorized boolean If true, the build version will be colorized based on whether it matches the live build.
---@return string formattedBuild The formatted build version, colorized if requested.
function SIPPYCUP_BUILDINFO.Output(colorized)
	local liveBuild = tostring(select(4, GetBuildInfo()));
	local addonBuild = SIPPYCUP.AddonMetadata.addonBuild;
	if not addonBuild then
		return "Unknown Build";
	end

	local output;
	for token in string.gmatch(addonBuild, "[^,%s]+") do
		if token == liveBuild then
			output = FormatBuild(token);
		end
	end

	if colorized then
		local color = SIPPYCUP_BUILDINFO.ValidateLatestBuild() and "|cnGREEN_FONT_COLOR:" or "|cnWARNING_FONT_COLOR:";
		output = color .. output .. "|r";
	end

	return output;
end

SIPPYCUP_OUTPUT = {};

local function Print(msg)
	print(SIPPYCUP.AddonMetadata.title .. ": " .. tostring(msg));
end


---Write prints formatted output with an optional command prefix.
---@param output string|table The output to be printed, either a string or a table.
---@param command? string The optional command prefix to display before the output.
function SIPPYCUP_OUTPUT.Write(output, command)
	if not output then
		return;
	end

	if type(output) == "table" then
		output = table.concat(output, "|n");
	end

	local formattedOutput = ("|cnGREEN_FONT_COLOR:%s|r|cnTRANSMOGRIFY_FONT_COLOR:%s|r"):format(command and (command .. " ") or "", output);

	Print(formattedOutput);
end

---Debug prints formatted output, only works when IS_DEV_BUILD is true.
---Accepts any number of arguments and joins them with space.
---@param ... any Values to print (strings, numbers, tables, etc.)
function SIPPYCUP_OUTPUT.Debug(...)
	if not SIPPYCUP.IS_DEV_BUILD then
		return;
	end

	local args = { ... };
	local outputLines = {};

	for _, arg in ipairs(args) do
		if type(arg) == "table" then
			local isArray = (#arg > 0);
			if isArray then
				for _, v in ipairs(arg) do
					table.insert(outputLines, tostring(v));
				end
			else
				for k, v in pairs(arg) do
					table.insert(outputLines, tostring(k) .. ": " .. tostring(v));
				end
			end
		else
			table.insert(outputLines, tostring(arg));
		end
	end

	local finalOutput = table.concat(outputLines, " ");
	Print("|cnTRANSMOGRIFY_FONT_COLOR:" .. finalOutput .. "|r");
end

SIPPYCUP.Player = {};
SIPPYCUP.Player.FullName = "";
SIPPYCUP.Player.OOC = true;

SIPPYCUP_PLAYER = {};

function SIPPYCUP_PLAYER.GetFullName()
	local name, realm = UnitFullName("player");
	SIPPYCUP.Player.FullName = format("%s-%s", name, realm);
end

function SIPPYCUP_PLAYER.CheckOOCStatus()
	-- msp.my.FC can be nil sometimes, mostly on login.
	if not (msp and msp.my and msp.my.FC) then
		return nil;
	end

	return (msp.my.FC == "1");
end

SIPPYCUP_TEXT = {};

function SIPPYCUP_TEXT.Normalize(str)
	return str
		:gsub("á", "a"):gsub("à", "a"):gsub("ã", "a"):gsub("ä", "a"):gsub("â", "a")
		:gsub("é", "e"):gsub("è", "e"):gsub("ê", "e"):gsub("ë", "e")
		:gsub("í", "i"):gsub("ì", "i"):gsub("î", "i"):gsub("ï", "i")
		:gsub("ó", "o"):gsub("ò", "o"):gsub("õ", "o"):gsub("ö", "o"):gsub("ô", "o")
		:gsub("ú", "u"):gsub("ù", "u"):gsub("û", "u"):gsub("ü", "u")
		:gsub("ç", "c"):gsub("ñ", "n")
		:gsub("Á", "A"):gsub("À", "A"):gsub("Ã", "A"):gsub("Ä", "A"):gsub("Â", "A")
		:gsub("É", "E"):gsub("È", "E"):gsub("Ê", "E"):gsub("Ë", "E")
		:gsub("Í", "I"):gsub("Ì", "I"):gsub("Î", "I"):gsub("Ï", "I")
		:gsub("Ó", "O"):gsub("Ò", "O"):gsub("Õ", "O"):gsub("Ö", "O"):gsub("Ô", "O")
		:gsub("Ú", "U"):gsub("Ù", "U"):gsub("Û", "U"):gsub("Ü", "U")
		:gsub("Ç", "C"):gsub("Ñ", "N");
end
