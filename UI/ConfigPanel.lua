-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local L = SIPPYCUP.L;
local SharedMedia = LibStub("LibSharedMedia-3.0");

SIPPYCUP_CONFIG = {};

-- Constants
local HALF_WIDTH = 1.875; --luacheck: no unused
local THIRD_WIDTH = 1.25; --luacheck: no unused
local QUARTER_WIDTH = 0.625; --luacheck: no unused
local ICON_SIZE = 22; --luacheck: no unused

local defaultSounds = {
	{ key = "aggro_enter_warning_state", fid = 567401 },
	{ key = "belltollhorde", fid = 565853 },
	{ key = "belltolltribal", fid = 566027 },
	{ key = "belltollnightelf", fid = 566558 },
	{ key = "belltollalliance", fid = 566564 },
	{ key = "fx_darkmoonfaire_bell", fid = 1100031 },
	{ key = "fx_ship_bell_chime_01", fid = 1129273 },
	{ key = "fx_ship_bell_chime_02", fid = 1129274 },
	{ key = "fx_ship_bell_chime_03", fid = 1129275 },
	{ key = "raidwarning", fid = 567397 },
}

for _, sound in ipairs(defaultSounds) do
	SharedMedia:Register("sound", sound.key, sound.fid);
end

local soundList = {};

for _, soundName in ipairs(SharedMedia:List("sound")) do
	soundList[soundName] = soundName;
end

local optionOrder = 1;
---autoOrder increments and returns the current option order value, adjusting by the specified amount.
---@param amount number The amount to increment the option order by (optional, default is 1).
---@return number The current option order value before it is incremented.
local function autoOrder(amount)
	local current = optionOrder;
	optionOrder = optionOrder + (amount or 1);
	return current;
end

---CreateGeneralOptions creates and returns the options table for the general configuration of the addon.
---@return table generalOptions Table containing the general options for the addon
function SIPPYCUP_CONFIG.GenerateGeneral()
	local generalOptions = {
		type = "group",
		childGroups = "tree",
		name = SIPPYCUP.AddonMetadata.title,
		args = {
			instructions = {
				type = "description",
				name = SIPPYCUP.AddonMetadata.notes .. "|n ",
				fontSize = "medium",
				order = autoOrder(),
			},
			header = {
				type = "header",
				name = "",
				order = autoOrder(),
			},
			-------------------------------------------------
			blank1 = {
				type = "description",
				name = " ",
				width = "full",
				order = autoOrder(),
			},
			welcomeMsg = {
				type = "toggle",
				name = L.OPTIONS_GENERAL_WELCOME_NAME,
				desc = L.OPTIONS_GENERAL_WELCOME_DESC,
				get = function()
					return SIPPYCUP.db.global.WelcomeMessage;
				end,
				set = function(_, val)
					SIPPYCUP.db.global.WelcomeMessage = val;
				end,
				width = THIRD_WIDTH,
				order = autoOrder(),
			},
			minimapButton = {
				type = "toggle",
				name = L.OPTIONS_GENERAL_MINIMAPBUTTON_NAME,
				desc = L.OPTIONS_GENERAL_MINIMAPBUTTON_DESC,
				get = function()
					return not SIPPYCUP.db.global.MinimapButton.hide;
				end,
				set = function(_, val)
					SIPPYCUP.db.global.MinimapButton.hide = not val;
					SIPPYCUP.Minimap:UpdateMinimapButtons();
				end,
				width = THIRD_WIDTH,
				order = autoOrder(),
			},
			addonCompartmentButton = {
				type = "toggle",
				name = L.OPTIONS_GENERAL_ADDONCOMPARTMENT_NAME,
				desc = L.OPTIONS_GENERAL_ADDONCOMPARTMENT_DESC,
				get = function()
					return SIPPYCUP.db.global.MinimapButton.ShowAddonCompartmentButton;
				end,
				set = function(_, val)
					SIPPYCUP.db.global.MinimapButton.ShowAddonCompartmentButton = val;
					SIPPYCUP.Minimap:UpdateMinimapButtons();
				end,
				width = THIRD_WIDTH,
				order = autoOrder(),
			},
			blank2 = {
				type = "description",
				name = " ",
				width = "full",
				order = autoOrder(),
			},
			popupsHeader = {
				type = "header",
				name = L.OPTIONS_GENERAL_POPUPS_HEADER,
				order = autoOrder(),
			},
			-------------------------------------------------
			blank3 = {
				type = "description",
				name = " ",
				width = "full",
				order = autoOrder(),
			},
			positionSelect = {
				type = "select",
				name = L.OPTIONS_GENERAL_POPUPS_POSITION_NAME,
				desc = L.OPTIONS_GENERAL_POPUPS_POSITION_DESC,
				values = {
					["top"] = "Top (Default)",
					["center"] = "Center",
				},
				sorting = {
					"top",
					"center",
				},
				get = function()
					return SIPPYCUP.db.global.PopupPosition;
				end,
				set = function(_, value)
					SIPPYCUP.db.global.PopupPosition = value;
				end,
				width = THIRD_WIDTH,
				order = autoOrder(),
			},
			PopupIconEnable = {
				type = "toggle",
				name = L.OPTIONS_GENERAL_POPUPS_ICON_ENABLE,
				desc = L.OPTIONS_GENERAL_POPUPS_ICON_ENABLE_DESC,
				get = function()
					return SIPPYCUP.db.global.PopupIcon;
				end,
				set = function(_, val)
					SIPPYCUP.db.global.PopupIcon = val;
				end,
				width = THIRD_WIDTH,
				order = autoOrder(),
			},
			resetIgnoresButton = {
				type = "execute",
				name = L.OPTIONS_GENERAL_POPUPS_IGNORES,
				desc = L.OPTIONS_GENERAL_POPUPS_IGNORES_TEXT,
				disabled = function()
					return SIPPYCUP.Popups.IsEmpty();
				end,
				func = function()
					SIPPYCUP.Popups.ResetIgnored();
				end,
				width = THIRD_WIDTH,
				order = autoOrder(),
			},
			blankSmall2 = {
				type = "description",
				name = " ",
				width = "full",
				order = autoOrder(),
			},
			alertSoundEnable = {
				type = "toggle",
				name = BINDING_NAME_TOGGLESOUND,
				desc = L.OPTIONS_GENERAL_POPUPS_SOUND_ENABLE_DESC,
				get = function()
					return SIPPYCUP.db.global.AlertSound;
				end,
				set = function(_, val)
					SIPPYCUP.db.global.AlertSound = val;
				end,
				width = THIRD_WIDTH,
				order = autoOrder(),
			},
			alertSoundSelect = {
				type = "select",
				name = SOUND,
				desc = L.OPTIONS_GENERAL_POPUPS_ALERT_SOUND_DESC,
				values = soundList,
				disabled = function()
					return not SIPPYCUP.db.global.AlertSound;
				end,
				get = function()
					return SIPPYCUP.db.global.AlertSoundID;
				end,
				set = function(_, value)
					local soundPath = SharedMedia:Fetch("sound", value);
					if soundPath then
						PlaySoundFile(soundPath, "Master");
						SIPPYCUP.db.global.AlertSoundID = value;
					end
				end,
				width = THIRD_WIDTH,
				order = autoOrder(),
			},
			blankSmall3 = {
				type = "description",
				name = " ",
				width = "full",
				order = autoOrder(),
			},
			alertFlashTaskbarEnable = {
				type = "toggle",
				name = L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE,
				desc = L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE_DESC,
				get = function()
					return SIPPYCUP.db.global.FlashTaskbar;
				end,
				set = function(_, val)
					SIPPYCUP.db.global.FlashTaskbar = val;
				end,
				width = THIRD_WIDTH,
				order = autoOrder(),
			},
			blank6 = {
				type = "description",
				name = " ",
				width = "full",
				order = autoOrder(),
			},
			integrationsHeader = {
				type = "header",
				name = L.OPTIONS_GENERAL_ADDONINTEGRATIONS_HEADER,
				order = autoOrder(),
			},
			-------------------------------------------------
			blank7 = {
				type = "description",
				name = " ",
				width = "full",
				order = autoOrder(),
			},
			alertMSPStatusCheckEnable = {
				type = "toggle",
				name = L.OPTIONS_GENERAL_MSP_STATUSCHECK_ENABLE,
				desc = L.OPTIONS_GENERAL_MSP_STATUSCHECK_DESC,
				disabled = function()
					return not msp or not msp.my;
				end,
				get = function()
					return SIPPYCUP.db.global.MSPStatusCheck;
				end,
				set = function(_, val)
					SIPPYCUP.db.global.MSPStatusCheck = val;
					if val then
						SIPPYCUP.Auras.CheckConsumableStackSizes(val);
					end
				end,
				width = THIRD_WIDTH,
				order = autoOrder(),
			},
			blank8 = {
				type = "description",
				name = " ",
				width = "full",
				order = autoOrder(),
			},
			addInfoHeader = {
				type = "header",
				name = L.OPTIONS_GENERAL_ADDONINFO_HEADER,
				order = autoOrder(),
			},
			-------------------------------------------------
			blank9 = {
				type = "description",
				name = " ",
				width = "full",
				order = autoOrder(),
			},
			addonVersion = {
				type = "description",
				name = L.OPTIONS_GENERAL_ADDONINFO_VERSION:format(SIPPYCUP.AddonMetadata.version),
				fontSize = "medium",
				width = HALF_WIDTH,
				order = autoOrder(),
			},
			addonBuildBtn = {
				type = "execute",
				name = L.OPTIONS_GENERAL_ADDONINFO_BUILD:format(SIPPYCUP_BUILDINFO.Output(true)),
				desc = function()
					if SIPPYCUP_BUILDINFO.ValidateLatestBuild() then
						return L.OPTIONS_GENERAL_ADDONINFO_BUILD_CURRENT;
					else
						return L.OPTIONS_GENERAL_ADDONINFO_BUILD_OUTDATED;
					end
				end,
				func = function() end,
				width = THIRD_WIDTH,
				order = autoOrder(),
			},
			addonAuthor = {
				type = "description",
				name = L.OPTIONS_GENERAL_ADDONINFO_AUTHOR:format(SIPPYCUP.AddonMetadata.author),
				fontSize = "medium",
				width = HALF_WIDTH,
				order = autoOrder(),
			},
			bskyShill = {
				type = "execute",
				name = "Bluesky",
				desc = L.OPTIONS_GENERAL_BLUESKY_SHILL_DESC,
				func = function()
					SIPPYCUP.LinkDialog.CreateExternalLinkDialog("https://bsky.app/profile/dawnsong.me");
				end,
				width = THIRD_WIDTH,
				order = autoOrder(),
			},
		}
	}

	return generalOptions;
end


---IncrementOrder icrements the given order value by 1.
---@param order number The current order value.
---@return number order The incremented order value.
local function IncrementOrder(order)
	return order + 1;
end

---GenerateCategory generates options for a specific consumable category.
---@param category string The category of consumables to generate options for.
---@return table options The generated options table for the given category.
function SIPPYCUP_CONFIG.GenerateCategory(category)
	local options = {};
	local order = 1;

	options.type = "group";
	options.childGroups = "tree";
	options.name = L["OPTIONS_CONSUMABLE_" .. category .. "_TITLE"];

	local args = {};

	args.instructions = {
		type = "description",
		name = L["OPTIONS_CONSUMABLE_" .. category .. "_INSTRUCTION"] .. L.OPTIONS_TITLE_EXTRA .. "|n ",
		fontSize = "medium",
		order = order,
	};

	for _, consumable in ipairs(SIPPYCUP.Consumables.Data) do
		if consumable.category == category then

			-- First we create a Header.
			order = IncrementOrder(order);
			args[consumable.profile .. "Header"] = {
				type = "header",
				name = "",
				order = order,
			};
			-------------------------------------------------

			local consumableProfile = SIPPYCUP.db.profile[consumable.profile];

			-- Then we set the Enable button.
			order = IncrementOrder(order);
			args[consumable.profile .. "Enable"] = {
				type = "toggle",
				name = function()
					local enableStr = "|TInterface\\Icons\\" .. SIPPYCUP_ICON.RetrieveIcon(consumable.name) .. ":" .. ICON_SIZE .. "|t " .. consumable.name;
					if consumableProfile.enable then
						return "|cnWHITE_FONT_COLOR:" .. enableStr .. "|r";
					else
						return "|cffb8b8b8" .. enableStr .. "|r";
					end
				end,
				desc = L.OPTIONS_ENABLE_TEXT:format(consumable.name),
				get = function()
					return consumableProfile.enable;
				end,
				set = function(_, val)
					consumableProfile.enable = val;
					SIPPYCUP.Popups.Toggle(consumable.name, val);
				end,
				width = HALF_WIDTH,
				order = order,
			};

			order = IncrementOrder(order);
			-- If a consumable has stacks, we add a stacks slider.
			if consumable.stacks then
				args[consumable.profile .. "DesiredStacksSlider"] = {
					type = "range",
					name = L.OPTIONS_DESIRED_STACKS,
					desc = L.OPTIONS_SLIDER_TEXT:format(consumable.name),
					min = 1,
					max = consumable.maxStacks,
					step = 1,
					get = function()
						return consumableProfile.desiredStacks;
					end,
					set = function(_, val)
						consumableProfile.desiredStacks = val;
						-- Only show a popup if the consumable popups are enabled in the first place.
						if consumableProfile.enable then
							SIPPYCUP.Popups.Toggle(consumable.name, true);
						end
					end,
					width = THIRD_WIDTH,
					order = order,
				};
			else
				args[consumable.profile .. "HeightFix"] = {
					type = "description",
					name = "|TInterface\\AddOns\\SippyCup\\Resources\\UI\\transparent:51:10|t",
					width = 0.1,
					order = order,
				};
			end
		end
	end

	options.args = args;
	return options;
end
