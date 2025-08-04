-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local title = C_AddOns.GetAddOnMetadata("SippyCup", "Title");
local L = LibStub("AceLocale-3.0"):NewLocale("SippyCup", "enUS", true, true);
if not L then return; end

--/ Welcome message /--
L.WELCOMEMSG_VERSION = "Prepared with |cnGREEN_FONT_COLOR:%s|r flavor (|cnWHITE_FONT_COLOR:%s|r)!";
L.WELCOMEMSG_OPTIONS = "Options available through |cnGREEN_FONT_COLOR:/sc|r or |cnGREEN_FONT_COLOR:/sippycup|r.";

--/ Popup dialog /--
L.POPUP_ON_COOLDOWN_TEXT = "On Cooldown";
L.POPUP_NOT_IN_INVENTORY_TEXT = "Not in Inventory";
L.POPUP_NOT_ENOUGH_IN_INVENTORY_TEXT = "Not Enough (%d Missing)";
L.POPUP_INSUFFICIENT_NEXT_REFRESH_TEXT = "insufficient (%d / %d) for next refresh.";
L.POPUP_LOW_STACK_COUNT_TEXT = "Low Stack Count!";
L.POPUP_NOT_ACTIVE_TEXT = "Not Active!";
L.POPUP_EXPIRING_SOON_TEXT = "Expiring Soon!";
L.POPUP_IGNORE_TT = "Blocks reminders for this consumable until your next session.";

L.POPUP_LINK = "|n|nPress |cnGREEN_FONT_COLOR:CTRL-C|r to copy the highlighted, then paste it in your web browser with |cnGREEN_FONT_COLOR:CTRL-V|r.";
L.COPY_SYSTEM_MESSAGE = "Copied to clipboard.";

--/ Options /--

-- General options
L.OPTIONS_GENERAL_HEADER = "General";
L.OPTIONS_GENERAL_WELCOME_NAME = "Startup message";
L.OPTIONS_GENERAL_WELCOME_DESC = "Toggles the display of the welcome message.";
L.OPTIONS_GENERAL_MINIMAPBUTTON_NAME = "Minimap button";
L.OPTIONS_GENERAL_MINIMAPBUTTON_DESC = "Toggles the display of the minimap button.";
L.OPTIONS_GENERAL_ADDONCOMPARTMENT_NAME = "Addon compartment";
L.OPTIONS_GENERAL_ADDONCOMPARTMENT_DESC = "Toggles the display of the addon compartment button.";

L.OPTIONS_GENERAL_POPUPS_HEADER = "Reminder popups";
L.OPTIONS_GENERAL_POPUPS_POSITION_NAME = "Position";
L.OPTIONS_GENERAL_POPUPS_POSITION_DESC = "Select where reminder popups appear on your screen.";
L.OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE = "Pre-Expiration Reminder";
L.OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE_DESC = "Toggles showing pre-expiration reminders shortly before the consumable expires.|n|n|cnWARNING_FONT_COLOR:Not all items support this; see the tooltip when enabled.|r";
L.OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE = "Insufficient Reminder";
L.OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE_DESC = "Toggles showing a popup when there is insufficient quantity for the next refresh.";
L.OPTIONS_GENERAL_POPUPS_IGNORES = "Reset ignored popups";
L.OPTIONS_GENERAL_POPUPS_IGNORES_TEXT = "Resets all reminder popups ignored during this session, making them visible again.";
L.OPTIONS_GENERAL_POPUPS_ALERT_SOUND_DESC = "Choose the sound to play when a reminder popup appears.";
L.OPTIONS_GENERAL_POPUPS_SOUND_ENABLE_DESC = "Toggles playing a sound when a reminder popup appears.";
L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE = "Flash Taskbar";
L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE_DESC = "Toggles flashing the taskbar when a reminder popup appears.";

L.OPTIONS_GENERAL_ADDONINTEGRATIONS_HEADER = "Addon Integrations";
L.OPTIONS_GENERAL_MSP_STATUSCHECK_ENABLE = "Only when \"In Character\"";
L.OPTIONS_GENERAL_MSP_STATUSCHECK_DESC = "Show popups only when your character is marked as |cnGREEN_FONT_COLOR:In Character|r.|n|n|cnWARNING_FONT_COLOR:Requires an RP Profile addon (e.g., TRP, MRP, XRP) to be running.|r";


L.OPTIONS_GENERAL_ADDONINFO_HEADER = "Addon Info";
L.OPTIONS_GENERAL_ADDONINFO_VERSION = "|cnNORMAL_FONT_COLOR:Version:|r %s";
L.OPTIONS_GENERAL_ADDONINFO_AUTHOR = "|cnNORMAL_FONT_COLOR:Author:|r %s";
L.OPTIONS_GENERAL_ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Build:|r %s";
L.OPTIONS_GENERAL_ADDONINFO_BUILD_OUTDATED = title .. " is not optimized for this game build.|n|n|cnWARNING_FONT_COLOR:This may cause unexpected behavior.|r";
L.OPTIONS_GENERAL_ADDONINFO_BUILD_CURRENT = title .. " is optimized for your current game build.|n|n|cnGREEN_FONT_COLOR:All features should work as expected.|r";
L.OPTIONS_GENERAL_BLUESKY_SHILL_DESC = "Follow me on Bluesky!";

-- Generic
L.OPTIONS_ENABLE_TEXT = "Enable consumable reminders for |cnGREEN_FONT_COLOR:%s|r.";
L.OPTIONS_ENABLE_PREXPIRE_TEXT = "|n|nNote that this consumable |cnGREEN_FONT_COLOR:supports pre-expiration reminders|r. Enabling that option will remind you shortly before it expires.";
L.OPTIONS_ENABLE_PREXPIRE_MAXSTACKS_TEXT = "|n|nNote that this consumable |cnGREEN_FONT_COLOR:supports pre-expiration reminders at maximum stacks|r. Enabling that option will remind you shortly before it expires.";
L.OPTIONS_ENABLE_NON_REFRESHABLE_TEXT = "|n|n|cnWARNING_FONT_COLOR:Do not refresh this consumable before it expires, as the stack will be lost without any effect.|r";
L.OPTIONS_ENABLE_NON_AURA_TEXT = "|n|n|cnWARNING_FONT_COLOR:This consumable is harder to track and may cause occasional irregularities.|r";
L.OPTIONS_SLIDER_TEXT = "Set the desired stack count for |cnGREEN_FONT_COLOR:%s|r.|n|nReminders will continue until the desired stack count is reached.";
L.OPTIONS_DESIRED_STACKS = "Desired stacks";
L.OPTIONS_TITLE_EXTRA = "|n|nOn login, a popup will appear for tracked consumables with active stacks. If the 'Only when \"In Character\"' option is enabled, it will also remind you about inactive stacks.";

L.OPTIONS_LEGENDA_PRE_EXPIRATION_NAME = "Pre-Expiration Support";
L.OPTIONS_LEGENDA_PRE_EXPIRATION_DESC = "This consumable supports pre-expiration reminders and will notify you shortly before it expires when the pre-expiration reminder option is enabled.";
L.OPTIONS_LEGENDA_NON_REFRESHABLE_NAME = "Non-Refreshable";
L.OPTIONS_LEGENDA_NON_REFRESHABLE_DESC = "Refreshing this consumable early will waste the stack without renewing its effect or timer.";
L.OPTIONS_LEGENDA_STACKS_NAME = "Stack Count Support";
L.OPTIONS_LEGENDA_STACKS_DESC = "This consumable supports setting a desired stack count and will remind you when your current stacks are below that number.";
L.OPTIONS_LEGENDA_NO_AURA_NAME = "Tracking Limitations";
L.OPTIONS_LEGENDA_NO_AURA_DESC = "This consumable is harder to track and may occasionally cause irregularities.";

-- Appearance
L.OPTIONS_CONSUMABLE_APPEARANCE_TITLE = "Appearance";
L.OPTIONS_CONSUMABLE_APPEARANCE_INSTRUCTION = "These options control all reminders for consumables that alter your appearance.";

-- Effect
L.OPTIONS_CONSUMABLE_EFFECT_TITLE = "Effect";
L.OPTIONS_CONSUMABLE_EFFECT_INSTRUCTION = "These options control all reminders for consumables that apply a visual.";

-- Handheld
L.OPTIONS_CONSUMABLE_HANDHELD_TITLE = "Handheld";
L.OPTIONS_CONSUMABLE_HANDHELD_INSTRUCTION = "These options control all reminders for consumables that make your character hold an item.";

-- Placement
L.OPTIONS_CONSUMABLE_PLACEMENT_TITLE = "Placement";
L.OPTIONS_CONSUMABLE_PLACEMENT_INSTRUCTION = "These options control all reminders for consumables that are placed on the ground.";

-- Prism
L.OPTIONS_CONSUMABLE_PRISM_TITLE = "Prism";
L.OPTIONS_CONSUMABLE_PRISM_INSTRUCTION = "These options control all reminders for prism consumables that change your appearance.";

-- Size
L.OPTIONS_CONSUMABLE_SIZE_TITLE = "Size";
L.OPTIONS_CONSUMABLE_SIZE_INSTRUCTION = "These options control all reminders for consumables that change your character's size.";

--/ Addon Compartment /--
L.ADDON_COMPARTMENT_DESC = "|cnGREEN_FONT_COLOR:Left-Click: Open options|nRight-Click: Open profiles|r";

-- Profiles
L.OPTIONS_PROFILES_HEADER = "Profiles";
L.OPTIONS_PROFILES_INSTRUCTION = "Settings under the General tab are global, while all consumable settings are profile-specific.";

L.OPTIONS_PROFILES_RESETBUTTON_NAME = "Reset Profile";
L.OPTIONS_PROFILES_RESETBUTTON_DESC = "Reset the current profile to its default settings.";

L.OPTIONS_PROFILES_CURRENTPROFILE = "Current Profile: %s";

L.OPTIONS_PROFILES_EXISTINGPROFILES_NAME = "Existing Profiles";
L.OPTIONS_PROFILES_EXISTINGPROFILES_DESC = "Select one of your available profiles.";

L.OPTIONS_PROFILES_NEWPROFILE_NAME = "New Profile";
L.OPTIONS_PROFILES_NEWPROFILE_DESC = "Enter a name for the new profile and press Enter.";

L.OPTIONS_PROFILES_COPYFROM_NAME = "Copy From";
L.OPTIONS_PROFILES_COPYFROM_DESC = "Copy settings from the selected profile into your current profile.";

L.OPTIONS_PROFILES_DELETEPROFILE_NAME = "Delete Profile";
L.OPTIONS_PROFILES_DELETEPROFILE_DESC = "Delete the selected profile from the database.";
