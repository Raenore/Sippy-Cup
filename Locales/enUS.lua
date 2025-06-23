-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local title = C_AddOns.GetAddOnMetadata("SippyCup", "Title");
local L = LibStub("AceLocale-3.0"):NewLocale("SippyCup", "enUS", true, true);
if not L then return; end

--/ Welcome message /--
L.WELCOMEMSG_VERSION = "Prepared with flavor |cnGREEN_FONT_COLOR:%s|r!";
L.WELCOMEMSG_OPTIONS = "Options available through |cnGREEN_FONT_COLOR:/sc|r or |cnGREEN_FONT_COLOR:/sippycup|r.";

--/ Consumable names /--
L.ARCHIVISTS_CODEX = "Archivist's Codex";
L.ASHEN_LINIMENT = "Ashen Liniment";
L.BLUBBERY_MUFFIN = "Blubbery Muffin";
L.COLLECTIBLE_PINEAPPLETINI_MUG = "Collectible Pineappletini Mug";
L.DARKMOON_FIREWATER = "Darkmoon Firewater";
L.DECORATIVE_YARD_FLAMINGO = "Decorative Yard Flamingo";
L.DISPOSABLE_HAMBURGER = "Disposable Hamburger";
L.DISPOSABLE_HOTDOG = "Disposable Hotdog";
L.ELIXIR_OF_GIANT_GROWTH = "Elixir of Giant Growth";
L.ELIXIR_OF_TONGUES = "Elixir of Tongues";
L.ENCHANTED_DUST = "Enchanted Dust";
L.FIREWATER_SORBET = "Firewater Sorbet";
L.FLEETING_SANDS = "Fleeting Sands";
L.FLICKERING_FLAME_HOLDER = "Flickering Flame Holder";
L.GIGANTIC_FEAST = "Gigantic Feast";
L.GREEN_DANCE_STICK = "Green Dance Stick";
L.HALF_EATEN_TAKEOUT = "Half-Eaten Takeout";
L.HOLY_CANDLE = "Holy Candle";
L.INKY_BLACK_POTION = "Inky Black Potion";
L.NOGGENFOGGER_SELECT_DOWN = "Noggenfogger Select DOWN";
L.NOGGENFOGGER_SELECT_UP = "Noggenfogger Select UP";
L.PROVIS_WAX = "Provis Wax";
L.PURPLE_DANCE_STICK = "Purple Dance Stick";
L.PYGMY_OIL = "Pygmy Oil";
L.QUICKSILVER_SANDS = "Quicksilver Sands";
L.RADIANT_FOCUS = "Radiant Focus";
L.SACREDITES_LEDGER = "Sacredite's Ledger";
L.SCROLL_OF_INNER_TRUTH = "Scroll of Inner Truth";
L.SINGLE_USE_GRILL = "Single-Use Grill";
L.SMALL_FEAST = "Small Feast";
L.SNOW_IN_A_CONE = "Snow in a Cone";
L.SPARKBUG_JAR = "Sparkbug Jar";
L.STINKY_BRIGHT_POTION = "Stinky Bright Potion";
L.SUNGLOW = "Sunglow";
L.TATTERED_ARATHI_PRAYER_SCROLL = "Tattered Arathi Prayer Scroll";
L.TEMPORALLY_LOCKED_SANDS = "Temporally-Locked Sands";
L.WEARY_SANDS = "Weary Sands";
L.WINTERFALL_FIREWATER = "Winterfall Firewater";

--/ Popup dialog /--
L.POPUP_COOLDOWN_TEXT = "currently on cooldown.";
L.POPUP_LACKING_TEXT = "not found in your inventory.";
L.POPUP_LACKING_TEXT_AMOUNT = "not enough in your inventory.";
L.POPUP_STACK_TEXT = "not at desired stack size!";
L.POPUP_MISSING_TEXT = "is not active!";
L.POPUP_EXPIRING_SOON_TEXT = "is expiring soon!";
L.POPUP_IGNORE_TT = IGNORE .. "|r |cnWHITE_FONT_COLOR:blocks reminders until next session.|r";

L.POPUP_LINK = "|n|nPress |cnGREEN_FONT_COLOR:CTRL-C|r to copy the highlighted, then paste it in your web browser with |cnGREEN_FONT_COLOR:CTRL-V|r.";
L.COPY_SYSTEM_MESSAGE = "Copied to clipboard.";

--/ Options /--

-- General options
L.OPTIONS_GENERAL_WELCOME_NAME = "Startup message";
L.OPTIONS_GENERAL_WELCOME_DESC = "Toggles the display of the welcome message.";
L.OPTIONS_GENERAL_MINIMAPBUTTON_NAME = "Minimap button";
L.OPTIONS_GENERAL_MINIMAPBUTTON_DESC = "Toggles the display of the minimap button.";
L.OPTIONS_GENERAL_ADDONCOMPARTMENT_NAME = "Addon compartment";
L.OPTIONS_GENERAL_ADDONCOMPARTMENT_DESC = "Toggles the display of the addon compartment button.";

L.OPTIONS_GENERAL_POPUPS_HEADER = "Reminder popups";
L.OPTIONS_GENERAL_POPUPS_POSITION_NAME = "Position";
L.OPTIONS_GENERAL_POPUPS_POSITION_DESC = "Select where you want the reminder popups to display on your screen.";
L.OPTIONS_GENERAL_POPUPS_ICON_ENABLE = "Popup icon";
L.OPTIONS_GENERAL_POPUPS_ICON_ENABLE_DESC = "Toggles whether the consumable icon is shown in the reminder popup.|n|n|cnWARNING_FONT_COLOR:Keep in mind that enabling this option will make the popup taller.|r";
L.OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE = "Pre-Expiration Reminder";
L.OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE_DESC = "Toggles whether pre-expiration reminders should show close to the consumable expiring.|n|n|cnWARNING_FONT_COLOR:Keep in mind that not all items support this (it will be displayed on the enable tooltip).|r";
L.OPTIONS_GENERAL_POPUPS_IGNORES = "Reset ignored popups";
L.OPTIONS_GENERAL_POPUPS_IGNORES_TEXT = "Reset all the reminder popups that were ignored in this session so that they are visible again.";
L.OPTIONS_GENERAL_POPUPS_ALERT_SOUND_DESC = "Choose which sound you want to play when the reminder popup is shown.";
L.OPTIONS_GENERAL_POPUPS_SOUND_ENABLE_DESC = "Toggles playing a sound when the reminder popup is shown.";
L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE = "Flash Taskbar";
L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE_DESC = "Toggles flashing the taskbar when a reminder popup is shown.";

L.OPTIONS_GENERAL_ADDONINTEGRATIONS_HEADER = "Addon Integrations";
L.OPTIONS_GENERAL_MSP_STATUSCHECK_ENABLE = "Only when \"In Character\"";
L.OPTIONS_GENERAL_MSP_STATUSCHECK_DESC = "Show popups only when your character is marked as |cnGREEN_FONT_COLOR:In Character|r.|n|n|cnWARNING_FONT_COLOR:Note that this requires a RP Profile addon (e.g., TRP, MRP, XRP) to be running.|r";


L.OPTIONS_GENERAL_ADDONINFO_HEADER = "Addon Info";
L.OPTIONS_GENERAL_ADDONINFO_VERSION = "|cnNORMAL_FONT_COLOR:Version:|r %s";
L.OPTIONS_GENERAL_ADDONINFO_AUTHOR = "|cnNORMAL_FONT_COLOR:Author:|r %s";
L.OPTIONS_GENERAL_ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Build:|r %s";
L.OPTIONS_GENERAL_ADDONINFO_BUILD_OUTDATED = title .. " is not optimized for this game build.|n|n|cnWARNING_FONT_COLOR:If you notice unexpected behavior, this might be the cause.|r";
L.OPTIONS_GENERAL_ADDONINFO_BUILD_CURRENT = title .. " is optimized for your current game build.|n|n|cnGREEN_FONT_COLOR:Everything should function as expected.|r";
L.OPTIONS_GENERAL_BLUESKY_SHILL_DESC = "Follow me on Bluesky!";

-- Generic
L.OPTIONS_ENABLE_TEXT = "Enable consumable reminders for |cnGREEN_FONT_COLOR:%s|r.";
L.OPTIONS_ENABLE_PREXPIRE_TEXT = "|n|nNote that this consumable |cnGREEN_FONT_COLOR:supports pre-expiration reminders|r. When this feature is enabled, it will remind you close to it expiring.";
L.OPTIONS_ENABLE_PREXPIRE_MAXSTACKS_TEXT = "|n|nNote that this consumable |cnGREEN_FONT_COLOR:supports pre-expiration reminders on maximum stacks|r. When this feature is enabled, it will remind you close to it expiring.";
L.OPTIONS_ENABLE_NON_REFRESHABLE_TEXT = "|n|n|cnWARNING_FONT_COLOR:Note that you should not refresh this consumable before it expires, as the stack will be lost without any effects.|r";
L.OPTIONS_ENABLE_NON_STACKABLE_TEXT = "|n|n|cnWARNING_FONT_COLOR:Note that this consumable is harder to track, resulting in possible irregularities from time to time.|r";
L.OPTIONS_SLIDER_TEXT = "Set the desired stack count for |cnGREEN_FONT_COLOR:%s|r.|n|nReminders will continue to show up until desired stack count is reached.";
L.OPTIONS_DESIRED_STACKS = "|cnWHITE_FONT_COLOR:Desired stacks|r";
L.OPTIONS_TITLE_EXTRA = "|n|nNote: On login, only consumables that have active stacks that are lower than your desired stacks will show a reminder popup.";

-- Appearance
L.OPTIONS_CONSUMABLE_APPEARANCE_TITLE = "Appearance";
L.OPTIONS_CONSUMABLE_APPEARANCE_INSTRUCTION = "These options control all reminders for consumables that alter your appearance.";

-- Effect
L.OPTIONS_CONSUMABLE_EFFECT_TITLE = "Effect";
L.OPTIONS_CONSUMABLE_EFFECT_INSTRUCTION = "These options control all reminders for consumables that cast an effect.";

-- Handheld
L.OPTIONS_CONSUMABLE_HANDHELD_TITLE = "Handheld";
L.OPTIONS_CONSUMABLE_HANDHELD_INSTRUCTION = "These options control all reminders for consumables that make the character hold something.";

-- Placement
L.OPTIONS_CONSUMABLE_PLACEMENT_TITLE = "Placement";
L.OPTIONS_CONSUMABLE_PLACEMENT_INSTRUCTION = "These options control all reminders for consumables that can be placed on the ground.";

-- Size
L.OPTIONS_CONSUMABLE_SIZE_TITLE = "Size";
L.OPTIONS_CONSUMABLE_SIZE_INSTRUCTION = "These options control all reminders for consumables that change the character's size.";

--/ Addon Compartment /--
L.ADDON_COMPARTMENT_DESC = "|cnGREEN_FONT_COLOR:Left-Click: Open options|nRight-Click: Open profiles|r";
