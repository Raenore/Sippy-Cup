max_line_length = false

exclude_files = {
	"Libs",
};

ignore = {
	-- Ignore global writes/accesses/mutations on anything prefixed with
	-- "SIPPYCUP_". This is the standard prefix for all of our global frame names
	-- and mixins.
	"11./^SIPPYCUP_",

	-- Ignore unused self. This would popup for Mixins and Objects
	"212/self",
};

globals = {
	-- Globals
	"SIPPYCUP",
	"SIPPYCUP_Addon",
};

read_globals = {
	-- Libraries/AddOns
	"ElvUI",
	"LibStub",
	"msp",

	-- Common protocol globals
	"CUSTOM_CLASS_COLORS",
	"GAME_LOCALE",
};

std = "lua51+wow";

stds.wow = {
	-- Globals that we mutate.
	globals = {
		ColorPickerFrame = {
			fields = {
				"hasOpacity",
				"opacity",
				"func",
				"opacityFunc",
				"cancelFunc",
			},
		},

		"GetColoredName",
		"ItemRefTooltip",
		"SetChannelPassword",
		"SlashCmdList",
		"StaticPopupDialogs",
	},

	-- Globals that we access.
	read_globals = {
		-- Lua function aliases and extensions

		bit = {
			fields = {
				"arshift",
				"band",
				"bor",
				"bxor",
			},
		},

		string = {
			fields = {
				"concat",
				"join",
				"split",
				"trim",
				"utf8lower", -- Added by the UTF8 library.
				"utf8sub", -- Added by the UTF8 library.
			},
		},

		table = {
			fields = {
				"wipe",
			},
		},

		"date",
		"floor",
		"format",
		"ipairs_reverse",
		"sort",
		"strconcat",
		"strjoin",
		"strlen",
		"strlenutf8",
		"strsplit",
		"strtrim",
		"strupper",
		"tAppendAll",
		"tContains",
		"tFilter",
		"time",
		"tinsert",
		"tInvert",
		"tremove",
		"wipe",

		-- Global Functions

		AnchorUtil = {
			fields = {
				"CreateAnchor",
				"CreateGridLayout",
				"GridLayout",
			},
		},

		Constants = {
			fields = {
				PetConsts = {
					fields = {
						"NUM_PET_SLOTS",
					},
				},
			},
		},

		C_AddOns = {
			fields = {
				"DisableAddOn",
				"GetAddOnEnableState",
				"GetAddOnMetadata",
				"IsAddOnLoaded",
			},
		},

		C_BattleNet = {
			fields = {
				"GetAccountInfoByGUID",
			},
		},

		C_ChatInfo = {
			fields = {
				"GetChannelShortcut",
				"IsTimerunningPlayer",
				"RegisterAddonMessagePrefix",
				"SwapChatChannelsByChannelIndex",
			},
		},

		C_Container = {
			fields = {
				"GetItemCooldown",
			},
		},

		C_CVar = {
			fields = {
				"GetCVarBool",
				"SetCVar",
			},
		},

		C_EquipmentSet = {
			fields = {
				"GetEquipmentSetID",
				"GetEquipmentSetInfo",
				"UseEquipmentSet",
			},
		},

		C_EventUtils = {
			fields = {
				"IsEventValid",
			},
		},

		C_FriendList = {
			fields = {
				"IsFriend",
			},
		},

		C_Item = {
			fields = {
				"DoesItemExistByID",
				"GetItemCount",
				"GetItemIconByID",
				"GetItemInfo",
				"GetItemNameByID",
				"IsItemInRange",
				"RequestLoadItemDataByID",
			},
		},

		C_LevelSquish = {
			fields = {
				"ConvertPlayerLevel",
			},
		},

		C_Map = {
			fields = {
				"GetBestMapForUnit",
				"GetMapInfo",
				"GetPlayerMapPosition",
			},
		},

		C_MountJournal = {
			fields = {
				"GetMountIDs",
				"GetMountInfoByID",
				"GetMountInfoExtraByID",
			},
		},

		C_NamePlate = {
			fields = {
				"GetNamePlateForUnit",
				"GetNamePlates",
			},
		},

		C_PetJournal = {
			fields = {
				"ClearSearchFilter",
				"GetNumPets",
				"GetNumPetSources",
				"GetNumPetTypes",
				"GetPetInfoByIndex",
				"GetPetInfoByPetID",
				"GetPetSortParameter",
				"GetSummonedPetGUID",
				"IsFilterChecked",
				"IsPetSourceChecked",
				"IsPetTypeChecked",
				"SetAllPetSourcesChecked",
				"SetAllPetTypesChecked",
				"SetCustomName",
				"SetFilterChecked",
				"SetPetSortParameter",
				"SetPetSourceChecked",
				"SetPetTypeFilter",
				"SetSearchFilter",
			},
		},

		C_PlayerInfo = {
			fields = {
				"GetAlternateFormInfo",
				"GUIDIsPlayer",
			},
		},

		C_PvP = {
			fields = {
				"GetZonePVPInfo",
				"IsWarModeActive",
			},
		},

		C_SocialRestrictions = {
			fields = {
				"IsChatDisabled",
			},
		},

		C_Spell = {
			fields = {
				"DoesSpellExist",
				"GetSpellInfo",
				"RequestLoadSpellData",
			},
		},

		C_StableInfo = {
			fields = {
				"GetStablePetInfo",
			},
		},

		C_StorePublic = {
			fields = {
				"IsDisabledByParentalControls",
			},
		},

		C_Texture = {
			fields = {
				"GetAtlasInfo",
			},
		},

		C_Timer = {
			fields = {
				"After",
				"NewTicker",
				"NewTimer",
			},
		},

		C_TooltipInfo = {
			fields = {
				"GetUnit",
				"GetWorldCursor",
			},
		},

		C_UnitAuras = {
			fields = {
				"GetAuraDataByIndex",
				"GetPlayerAuraBySpellID",
				"GetAuraDataByAuraInstanceID",
			},
		},

		Enum = {
			fields = {
				TooltipDataLineType = {
					fields = {
						"UnitOwner",
					},
				},

				TooltipDataType = {
					fields = {
						"Unit",
					},
				},

				TooltipTextureAnchor = {
					fields = {
						"LeftCenter",
					},
				},
			},
		},

		EventTrace = {
			fields = {
				"CanLogEvent",
				"IsLoggingCREvents",
				"LogLine",
			},
		},

		EventUtil = {
			fields = {
				"ContinueOnAddOnLoaded",
			},
		},

		Menu = {
			fields = {
				"ModifyMenu",
			},
		},

		MenuUtil = {
			fields = {
				"CreateButton",
				"CreateCheckbox",
				"CreateContextMenu",
				"CreateDivider",
				"CreateRadio",
				"CreateTitle",
				"GetElementText",
				"HideTooltip",
				"SetElementText",
				"ShowTooltip",
			},
		},

		PixelUtil = {
			fields = {
				"SetPoint",
				"SetSize",
			},
		},

		ScrollBoxConstants = {
			fields = {
				"DiscardScrollPosition",
				"NoScrollInterpolation",
				"RetainScrollPosition",
			},
		},

		ScrollUtil = {
			fields = {
				"AddManagedScrollBarVisibilityBehavior",
				"InitScrollBoxListWithScrollBar",
				"InitScrollBoxWithScrollBar",
				"RegisterScrollBoxWithScrollBar",
			},
		},

		TimerunningUtil = {
		    fields = {
                "AddSmallIcon",
            },
		},

		"AbbreviateLargeNumbers",
		"Ambiguate",
		"BNGetGameAccountInfoByGUID",
		"BNGetInfo",
		"CalculateStringEditDistance",
		"Chat_GetChatFrame",
		"ChatConfigChannelSettings_SwapChannelsByIndex",
		"ChatEdit_FocusActiveWindow",
		"ChatEdit_GetActiveWindow",
		"ChatFrame_AddMessageEventFilter",
		"ChatFrame_OpenChat",
		"ChatFrame_RemoveMessageEventFilter",
		"CheckInteractDistance",
		"Clamp",
		"ClampedPercentageBetween",
		"CloseDropDownMenus",
		"CopyTable",
		"CreateAndInitFromMixin",
		"CreateAtlasMarkup",
		"CreateCircularBuffer",
		"CreateDataProvider",
		"CreateFont",
		"CreateFrame",
		"CreateFramePool",
		"CreateFramePoolCollection",
		"CreateFromMixins",
		"CreateIndexRangeDataProvider",
		"CreateMinimalSliderFormatter",
		"CreateScrollBoxLinearView",
		"CreateScrollBoxListGridView",
		"CreateScrollBoxListLinearView",
		"CreateTextureMarkup",
		"CreateVector2D",
		"DisableAddOn",
		"DoesTemplateExist",
		"EventRegistry",
		"ExecuteFrameScript",
		"fastrandom",
		"FCF_GetCurrentChatFrame",
		"FindInTableIf",
		"FlashClientIcon",
		"FormatPercentage",
		"GameTooltip_AddBlankLineToTooltip",
		"GameTooltip_AddColoredLine",
		"GameTooltip_AddHighlightLine",
		"GameTooltip_AddNormalLine",
		"GameTooltip_SetDefaultAnchor",
		"GameTooltip_SetTitle",
		"GameTooltip_ShowDisabledTooltip",
		"GenerateClosure",
		"GetAutoCompleteRealms",
		"GetBindingText",
		"GetBuildInfo",
		"GetChannelDisplayInfo",
		"GetChannelList",
		"GetChannelName",
		"GetChannelRosterInfo",
		"GetChatWindowInfo",
		"GetConvertedKeyOrButton",
		"GetCursorPosition",
		"GetCVar",
		"GetDefaultLanguage",
		"GetFileIDFromPath",
		"GetFrameMetatable",
		"GetGuildInfo",
		"GetInventoryItemTexture",
		"GetInventorySlotInfo",
		"GetKeysArray",
		"GetLanguageByIndex",
		"GetLocale",
		"GetMaxLevelForLatestExpansion",
		"GetMinimapZoneText",
		"GetMouseFoci",
		"GetMouseFocus",
		"GetNormalizedRealmName",
		"GetNumLanguages",
		"GetPlayerInfoByGUID",
		"GetRealmName",
		"GetSpellBaseCooldown",
		"GetSpellDescription",
		"GetSpellInfo",
		"GetSpellTexture",
		"GetStablePetInfo",
		"GetSubZoneText",
		"GetTickTime",
		"GetTime",
		"GetTimePreciseSec",
		"GetUnitName",
		"GetValueOrCallFunction",
		"GetZoneText",
		"hooksecurefunc",
		"InCombatLockdown",
		"InterfaceOptionsFrame_OpenToCategory",
		"IsAltKeyDown",
		"IsChatAFK",
		"IsChatDND",
		"IsControlKeyDown",
		"IsGuildMember",
		"IsInGroup",
		"IsInGuild",
		"IsInInstance",
		"IsInRaid",
		"IsKeyDown",
		"IsMacClient",
		"IsMetaKeyDown",
		"IsModifierKeyDown",
		"IsMounted",
		"IsShiftKeyDown",
		"IsSpellKnown",
		"IsTrialAccount",
		"IsVeteranTrialAccount",
		"JoinChannelByName",
		"Lerp",
		"Mixin",
		"MouseIsOver",
		"NeutralPlayerSelectFaction",
		"nop",
		"OpenWorldMap",
		"PetCanBeAbandoned",
		"PlayMusic",
		"PlaySound",
		"PlaySoundFile",
		"RaidNotice_AddMessage",
		"RaidWarningFrame",
		"ReloadUI",
		"RemoveChatWindowChannel",
		"ResetCursor",
		"RoundToSignificantDigits",
		"RunNextFrame",
		"SafePack",
		"Saturate",
		"ScrollingEdit_OnCursorChanged",
		"ScrollingEdit_OnLoad",
		"ScrollingEdit_OnTextChanged",
		"SearchBoxTemplate_OnTextChanged",
		"SecondsFormatter",
		"SecondsFormatterMixin",
		"securecall",
		"securecallfunction",
		"SecureCmdOptionParse",
		"secureexecuterange",
		"SendChatMessage",
		"SendSystemMessage",
		"SetCursor",
		"SetCVar",
		"SetPetStablePaperdoll",
		"SetPortraitToTexture",
		"Settings",
		"ShouldShowName",
		"ShowCloak",
		"ShowHelm",
		"ShowingCloak",
		"ShowingHelm",
		"ShowUIPanel",
		"StaticPopup_Show",
		"StaticPopup_Hide",
		"StaticPopup_Visible",
		"StopMusic",
		"StopSound",
		"strcmputf8i",
		"StringToBoolean",
		"SwapChatChannelByLocalID",
		"ToggleDropDownMenu",
		"tostringall",
		"UIDropDownMenu_AddButton",
		"UIDropDownMenu_GetText",
		"UIDROPDOWNMENU_INIT_MENU",
		"UIDropDownMenu_Initialize",
		"UIDropDownMenu_IsEnabled",
		"UIDropDownMenu_RefreshAll",
		"UIDropDownMenu_SetAnchor",
		"UIDropDownMenu_SetDisplayMode",
		"UIDropDownMenu_SetDropDownEnabled",
		"UIDropDownMenu_SetInitializeFunction",
		"UIDropDownMenu_SetText",
		"UIDropDownMenu_SetWidth",
		"UIPanelCloseButton_SetBorderAtlas",
		"UnitAffectingCombat",
		"UnitBattlePetLevel",
		"UnitBattlePetType",
		"UnitClass",
		"UnitClassBase",
		"UnitCreatureFamily",
		"UnitCreatureType",
		"UnitExists",
		"UnitFactionGroup",
		"UnitFullName",
		"UnitGUID",
		"UnitHealth",
		"UnitHealthMax",
		"UnitInParty",
		"UnitInRaid",
		"UnitIsAFK",
		"UnitIsBattlePetCompanion",
		"UnitIsDND",
		"UnitIsOtherPlayersPet",
		"UnitIsOwnerOrControllerOfUnit",
		"UnitIsPlayer",
		"UnitIsPVP",
		"UnitIsUnit",
		"UnitLevel",
		"UnitName",
		"UnitNameUnmodified",
		"UnitPlayerControlled",
		"UnitPVPName",
		"UnitRace",
		"UnitSex",
		"UnitTokenFromGUID",
		"Wrap",
		"WrapTextInColorCode",

		-- Global Mixins and UI Objects

		BackdropTemplateMixin = {
			fields = {
				"SetBackdropBorderColor",
			},
		},

		ColorPickerFrame = {
			fields = {
				"GetColorRGB",
				"SetColorRGB",
				"SetupColorPickerAndShow",
			},
		},

		MinimalSliderWithSteppersMixin = {
			fields = {
				Label = {
					fields = {
						"Left",
					},
				},
			},
		},

		"BackdropTemplateMixin",
		"BaseMapPoiPinMixin",
		"CallbackRegistryMixin",
		"ChatFrame1EditBox",
		"ChatTypeInfo",
		"CombatLogGetCurrentEventInfo",
		"FontableFrameMixin",
		"GameFontDisableSmall",
		"GameFontHighlight",
		"GameFontHighlightSmall",
		"GameFontNormal",
		"GameFontNormalHuge",
		"GameFontNormalHuge3",
		"GameFontNormalLarge",
		"GameMenuFrame",
		"GameTooltip",
		"GameTooltipHeaderText",
		"GameTooltipText",
		"GridLayoutMixin",
		"MapCanvasDataProviderMixin",
		"MenuInputContext",
		"MenuResponse",
		"ModelFrameMixin",
		"NamePlateDriverFrame",
		"SystemFont_LargeNamePlate",
		"SystemFont_NamePlate",
		"SystemFont_Shadow_Huge1",
		"SystemFont_Shadow_Huge3",
		"SystemFont_Shadow_Large",
		"SystemFont_Shadow_Med1",
		"TargetFrame",
		"UIErrorsFrame",
		"UIParent",
		"UISpecialFrames",
		"WorldFrame",
		"WorldMapFrame",

		-- Global Constants

		"ACCEPT",
		"AMMOSLOT",
		"ARCANE_CHARGES",
		"BATTLENET_FONT_COLOR",
		"BINDING_NAME_TOGGLESOUND",
		"BNET_CLIENT_WOW",
		"CANCEL",
		"CHI",
		"CLOSE",
		"COMBO_POINTS",
		"DEFAULT_CHAT_FRAME",
		"DELETE",
		"DISABLE",
		"DISABLED_FONT_COLOR",
		"ENABLE_COLORBLIND_MODE",
		"ENABLE",
		"ENERGY",
		"ERR_TOO_MANY_CHAT_CHANNELS",
		"FOCUS_TOKEN_NOT_FOUND",
		"FOCUS",
		"FUEL",
		"FURY",
		"GENERIC_FRACTION_STRING",
		"GREEN_FONT_COLOR",
		"HEALTH",
		"HIGHLIGHT_FONT_COLOR",
		"HOLY_POWER",
		"IGNORE",
		"INSANITY",
		"ITEM_ARTIFACT_COLOR",
		"ITEM_EPIC_COLOR",
		"ITEM_GOOD_COLOR",
		"ITEM_LEGENDARY_COLOR",
		"ITEM_POOR_COLOR",
		"ITEM_QUALITY0_DESC",
		"ITEM_QUALITY1_DESC",
		"ITEM_QUALITY2_DESC",
		"ITEM_QUALITY3_DESC",
		"ITEM_QUALITY4_DESC",
		"ITEM_QUALITY5_DESC",
		"ITEM_QUALITY6_DESC",
		"ITEM_QUALITY7_DESC",
		"ITEM_QUALITY8_DESC",
		"ITEM_STANDARD_COLOR",
		"ITEM_SUPERIOR_COLOR",
		"ITEM_WOW_TOKEN_COLOR",
		"ITEM_WOW_TOKEN_COLOR",
		"KEY_BINDING_NAME_AND_KEY",
		"KEY_BINDING_TOOLTIP",
		"LE_EXPANSION_BATTLE_FOR_AZEROTH",
		"LE_EXPANSION_BURNING_CRUSADE",
		"LE_EXPANSION_CATACLYSM",
		"LE_EXPANSION_CLASSIC",
		"LE_EXPANSION_LEGION",
		"LE_EXPANSION_LEVEL_CURRENT",
		"LE_EXPANSION_MISTS_OF_PANDARIA",
		"LE_EXPANSION_SHADOWLANDS",
		"LE_EXPANSION_WARLORDS_OF_DRAENOR",
		"LE_EXPANSION_WRATH_OF_THE_LICH_KING",
		"LE_PARTY_CATEGORY_HOME",
		"LE_PET_JOURNAL_FILTER_COLLECTED",
		"LE_PET_JOURNAL_FILTER_NOT_COLLECTED",
		"LE_SORT_BY_LEVEL",
		"LIGHTBLUE_FONT_COLOR",
		"LINK_FONT_COLOR",
		"LIST_DELIMITER",
		"LOCALE_enGB",
		"LOCALIZED_CLASS_NAMES_MALE",
		"LOWER_RIGHT_VERTEX",
		"LUNAR_POWER",
		"MAELSTROM",
		"MANA",
		"MAX_CHANNEL_BUTTONS",
		"MAX_WOW_CHAT_CHANNELS",
		"MODELFRAME_MAX_PLAYER_ZOOM",
		"NO",
		"NONE",
		"NORMAL_FONT_COLOR",
		"NOT_BOUND",
		"NUM_CHAT_WINDOWS",
		"OKAY",
		"PAIN",
		"PLAYER_FACTION_COLOR_ALLIANCE",
		"PLAYER_FACTION_COLOR_HORDE",
		"POWER_TYPE_ARCANE_CHARGES",
		"POWER_TYPE_ENERGY",
		"POWER_TYPE_FOCUS",
		"POWER_TYPE_FUEL",
		"POWER_TYPE_FURY",
		"POWER_TYPE_INSANITY",
		"POWER_TYPE_LUNAR_POWER",
		"POWER_TYPE_MAELSTROM",
		"POWER_TYPE_MANA",
		"POWER_TYPE_PAIN",
		"POWER_TYPE_RUNIC_POWER",
		"RAGE",
		"RAID_CLASS_COLORS",
		"RED_FONT_COLOR",
		"REFRESH",
		"RESET",
		"RUNES",
		"RUNIC_POWER",
		"SAVE",
		"SOUL_SHARDS",
		"SOUND",
		"SOUNDKIT",
		"STATICPOPUP_NUMDIALOGS",
		"TARGET_TOKEN_NOT_FOUND",
		"TOOLTIP_DEFAULT_BACKGROUND_COLOR",
		"TOOLTIP_DEFAULT_COLOR",
		"TOOLTIP_UNIT_LEVEL_TYPE",
		"TRANSMOGRIFY_FONT_COLOR",
		"UIDROPDOWNMENU_DEFAULT_WIDTH_PADDING",
		"UIDROPDOWNMENU_OPEN_MENU",
		"UNIT_TYPE_LEVEL_TEMPLATE",
		"UNITNAME_TITLE_CHARM",
		"UNITNAME_TITLE_COMPANION",
		"UNITNAME_TITLE_CREATION",
		"UNITNAME_TITLE_GUARDIAN",
		"UNITNAME_TITLE_MINION",
		"UNITNAME_TITLE_PET",
		"UNITNAME_TITLE_SQUIRE",
		"UNKNOWN",
		"UNKNOWNOBJECT",
		"UNLOCK",
		"UPPER_LEFT_VERTEX",
		"VIDEO_QUALITY_LABEL6",
		"WARNING_FONT_COLOR",
		"WHITE_FONT_COLOR",
		"WOW_PROJECT_BURNING_CRUSADE_CLASSIC",
		"WOW_PROJECT_CLASSIC",
		"WOW_PROJECT_ID",
		"WOW_PROJECT_MAINLINE",
		"YELLOW_FONT_COLOR",
		"YES",
	},
};
