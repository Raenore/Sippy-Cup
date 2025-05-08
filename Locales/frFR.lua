-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local title = C_AddOns.GetAddOnMetadata("SippyCup", "Title");
local L = LibStub("AceLocale-3.0"):NewLocale("SippyCup", "frFR", false);
if not L then return; end

--/ Welcome message /--
L.WELCOMEMSG_VERSION = "Prepared with flavor |cnGREEN_FONT_COLOR:%s|r!";
L.WELCOMEMSG_OPTIONS = "Options available through |cnGREEN_FONT_COLOR:/sc|r or |cnGREEN_FONT_COLOR:/sippycup|r.";

--/ Consumable names /--
L.ARCHIVISTS_CODEX = "Codex des archivistes";
L.ASHEN_LINIMENT = "Liniment cendreux";
L.DARKMOON_FIREWATER = "Eau-de-feu de Sombrelune";
L.ELIXIR_OF_GIANT_GROWTH = "Élixir de taille de géant";
L.ELIXIR_OF_TONGUES = "Élixir des langages";
L.FIREWATER_SORBET = "Sorbet d'eau-de-feu";
L.FLICKERING_FLAME_HOLDER = "Support de flamme vacillante";
L.GIGANTIC_FEAST = "Festin gigantesque";
L.INKY_BLACK_POTION = "Potion noire comme de l'encre";
L.NOGGENFOGGER_SELECT_DOWN = "Sélection rétrécissante de Brouillecaboche";
L.NOGGENFOGGER_SELECT_UP = "Sélection grandissante de Brouillecaboche";
L.PROVIS_WAX = "Cire de Provis";
L.PYGMY_OIL = "Huile de pygmée";
L.RADIANT_FOCUS = "Concentration rayonnante";
L.SACREDITES_LEDGER = "Registre de sacrédit";
L.SMALL_FEAST = "Petit festin";
L.SPARKBUG_JAR = "Jarre de lumiptères";
L.STINKY_BRIGHT_POTION = "Potion lumineuse puante";
L.SUNGLOW = "Soléclat";
L.TATTERED_ARATHI_PRAYER_SCROLL = "Parchemin de prière arathi en lambeaux";
L.WINTERFALL_FIREWATER = "Eau-de-feu des Tombe-hiver";

--/ Popup dialog /--
L.POPUP_ITEM_NAME = "|cnGREEN_FONT_COLOR:%s|r ";
L.POPUP_ITEM_ICON = "|TInterface\\Icons\\%s:%d|t |cnGREEN_FONT_COLOR:%s|r|n|n";

L.POPUP_LACKING_TEXT = "not found in your inventory.";
L.POPUP_TEXT = "not at desired stack size!";
L.POPUP_IGNORE_TT = IGNORE .. "|r |cnWHITE_FONT_COLOR:blocks reminders until next session.|r";

L.POPUP_BUTTON_REFRESH = REFRESH .. " (%dx)";
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
L.OPTIONS_GENERAL_POPUPS_IGNORES = "Reset ignored popups";
L.OPTIONS_GENERAL_POPUPS_IGNORES_TEXT = "Reset all the reminder popups that were ignored in this session so that they are visible again.";
L.OPTIONS_GENERAL_POPUPS_ALERT_SOUND = SOUND;
L.OPTIONS_GENERAL_POPUPS_ALERT_SOUND_DESC = "Choose which sound you want to play when the reminder popup is shown.";
L.OPTIONS_GENERAL_POPUPS_SOUND_ENABLE = BINDING_NAME_TOGGLESOUND;
L.OPTIONS_GENERAL_POPUPS_SOUND_ENABLE_DESC = "Toggles playing a sound when the reminder popup is shown.";
L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE = "Flash Taskbar";
L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE_DESC = "Toggles flashing the taskbar when a reminder popup is shown.";


L.OPTIONS_GENERAL_ADDONINFO_HEADER = "Addon Info";
L.OPTIONS_GENERAL_ADDONINFO_VERSION = "|cnNORMAL_FONT_COLOR:Version:|r %s";
L.OPTIONS_GENERAL_ADDONINFO_AUTHOR = "|cnNORMAL_FONT_COLOR:Author:|r %s";
L.OPTIONS_GENERAL_ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Build:|r %s";
L.OPTIONS_GENERAL_ADDONINFO_BUILD_OUTDATED = title .. " is not optimized for this game build.|n|n|cnWARNING_FONT_COLOR:If you notice unexpected behavior, this might be the cause.|r";
L.OPTIONS_GENERAL_ADDONINFO_BUILD_CURRENT = title .. " is optimized for your current game build.|n|n|cnGREEN_FONT_COLOR:Everything should function as expected.|r";
L.OPTIONS_GENERAL_BLUESKY_SHILL_DESC = "Follow me on Bluesky!";

-- Generic
L.OPTIONS_ENABLE_TEXT = "Enable consumable reminders for |cnGREEN_FONT_COLOR:%s|r.";
L.OPTIONS_SLIDER_TEXT = "Set the desired stack count for |cnGREEN_FONT_COLOR:%s|r.|n|nReminders will continue to show up until desired stack count is reached.";
L.OPTIONS_DESIRED_STACKS = "|cnWHITE_FONT_COLOR:Desired stacks|r";
L.OPTIONS_TITLE_EXTRA = "|n|nNote: On login, only consumables that have active stacks that are lower than your desired stacks will show a reminder popup.";

-- Effect
L.OPTIONS_CONSUMABLE_EFFECT_TITLE = "Effect";
L.OPTIONS_CONSUMABLE_EFFECT_INSTRUCTION = "These options control all reminders for consumables that cast an effect.";

-- Size
L.OPTIONS_CONSUMABLE_SIZE_TITLE = "Size";
L.OPTIONS_CONSUMABLE_SIZE_INSTRUCTION = "These options control all reminders for consumables that change the character's size.";

--/ Addon Compartment /--
L.ADDON_COMPARTMENT_DESC = "|cnGREEN_FONT_COLOR:Left-Click: Open options|nRight-Click: Open profiles|r";
