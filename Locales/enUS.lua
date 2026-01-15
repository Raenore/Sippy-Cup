-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local title = C_AddOns.GetAddOnMetadata("SippyCup", "Title");
local L;

L = {
	--/ Welcome message /--
	WELCOMEMSG_VERSION = "Prepared with |cnGREEN_FONT_COLOR:%s|r flavor (|cnWHITE_FONT_COLOR:%s|r)!",
	WELCOMEMSG_OPTIONS = "Options available through |cnGREEN_FONT_COLOR:/sc|r or |cnGREEN_FONT_COLOR:/sippycup|r",

	--/ Popup dialog /--
	POPUP_ON_COOLDOWN_TEXT = "On Cooldown",
	POPUP_IN_FLIGHT_TEXT = "Disabled to prevent dismount during flight.",
	POPUP_FOOD_BUFF_TEXT = "Disappears once food buff is applied. Do not move!",
	POPUP_NOT_IN_INVENTORY_TEXT = "Not in Inventory",
	POPUP_NOT_ENOUGH_IN_INVENTORY_TEXT = "Not Enough (%d Missing)",
	POPUP_INSUFFICIENT_NEXT_REFRESH_TEXT = "insufficient (%d / %d) for next refresh.",
	POPUP_LOW_STACK_COUNT_TEXT = "Low Stack Count!",
	POPUP_NOT_ACTIVE_TEXT = "Not Active!",
	POPUP_EXPIRING_SOON_TEXT = "Expiring Soon!",
	POPUP_IGNORE_TT = "Blocks reminders for this consumable/toy until your next session.",
	POPUP_LINK = "|n|nPress |cnGREEN_FONT_COLOR:CTRL-C|r to copy the highlighted, then paste it in your web browser with |cnGREEN_FONT_COLOR:CTRL-V|r.",
	COPY_SYSTEM_MESSAGE = "Copied to clipboard.",

	--/ Options /--

	-- General options
	OPTIONS_GENERAL_HEADER = "General",
	OPTIONS_GENERAL_WELCOME_NAME = "Startup message",
	OPTIONS_GENERAL_WELCOME_DESC = "Toggles the display of the welcome message.",
	OPTIONS_GENERAL_MINIMAPBUTTON_NAME = "Minimap button",
	OPTIONS_GENERAL_MINIMAPBUTTON_DESC = "Toggles the display of the minimap button.",
	OPTIONS_GENERAL_ADDONCOMPARTMENT_NAME = "Addon compartment",
	OPTIONS_GENERAL_ADDONCOMPARTMENT_DESC = "Toggles the display of the addon compartment button.",
	OPTIONS_GENERAL_POPUPS_HEADER = "Reminder popups",
	OPTIONS_GENERAL_POPUPS_POSITION_NAME = "Position",
	OPTIONS_GENERAL_POPUPS_POSITION_DESC = "Select where reminder popups appear on your screen.",
	OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE = "Pre-Expiration Reminder",
	OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE_DESC = "Toggles showing pre-expiration reminders shortly before the consumable/toy expires.|n|n|cnWARNING_FONT_COLOR:Not all options support this; see the tooltip when enabled.|r",
	OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE = "Insufficient Reminder",
	OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE_DESC = "Toggles showing a popup when there is insufficient quantity for the next refresh.",
	OPTIONS_GENERAL_POPUPS_TRACK_TOY_ITEM_CD_ENABLE = "Use Toy Cooldown",
	OPTIONS_GENERAL_POPUPS_TRACK_TOY_ITEM_CD_ENABLE_DESC = "Toggles tracking toy cooldowns from the toy itself instead of its effect, ensuring the popup only appears when the toy can be used.|n|n|cnWARNING_FONT_COLOR:This only affects 'Cooldown Mismatch' toys.|r",
	OPTIONS_GENERAL_POPUPS_IGNORES = "Reset ignored popups",
	OPTIONS_GENERAL_POPUPS_IGNORES_TEXT = "Resets all reminder popups ignored during this session, making them visible again.",
	OPTIONS_GENERAL_REMINDER_LEAD_TIMER = "Reminder Lead Time",
	OPTIONS_GENERAL_REMINDER_LEAD_TIMER_TEXT = "Set the desired time, in minutes, before expiration when a reminder popup should be shown (default: 1 minute).|n|n|cnWARNING_FONT_COLOR:If an option does not support the chosen time, it will default to 1 minute, or 15 seconds if 1 minute is not supported.|r",
	OPTIONS_GENERAL_POPUPS_ALERT_SOUND_DESC = "Choose the sound to play when a reminder popup appears.",
	OPTIONS_GENERAL_POPUPS_SOUND_ENABLE_DESC = "Toggles playing a sound when a reminder popup appears.",
	OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE = "Flash Taskbar",
	OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE_DESC = "Toggles flashing the taskbar when a reminder popup appears.",
	OPTIONS_GENERAL_ADDONINTEGRATIONS_HEADER = "Addon Integrations",
	OPTIONS_GENERAL_MSP_STATUSCHECK_ENABLE = "Only when \"In Character\"",
	OPTIONS_GENERAL_MSP_STATUSCHECK_DESC = "Show popups only when your character is marked as |cnGREEN_FONT_COLOR:In Character|r.|n|n|cnWARNING_FONT_COLOR:Requires an RP Profile addon (e.g., TRP, MRP, XRP) to be running.|r",
	OPTIONS_GENERAL_ADDONINFO_HEADER = "Addon Info",
	OPTIONS_GENERAL_ADDONINFO_VERSION = "|cnNORMAL_FONT_COLOR:Version:|r %s",
	OPTIONS_GENERAL_ADDONINFO_AUTHOR = "|cnNORMAL_FONT_COLOR:Author:|r %s",
	OPTIONS_GENERAL_ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Build:|r %s",
	OPTIONS_GENERAL_ADDONINFO_BUILD_OUTDATED = title .. " is not optimized for this game build.|n|n|cnWARNING_FONT_COLOR:This may cause unexpected behavior.|r",
	OPTIONS_GENERAL_ADDONINFO_BUILD_CURRENT = title .. " is optimized for your current game build.|n|n|cnGREEN_FONT_COLOR:All features should work as expected.|r",
	OPTIONS_GENERAL_BLUESKY_SHILL_DESC = "Follow me on Bluesky!",

	-- Generic
	OPTIONS_SLIDER_TEXT = "Set the desired stack count for |cnGREEN_FONT_COLOR:%s|r.|n|nReminders will continue until the desired stack count is reached.",
	OPTIONS_DESIRED_STACKS = "Desired stacks",
	OPTIONS_TITLE_EXTRA = "|n|nOn login, a popup will appear for tracked consumables/toys with active stacks. If the 'Only when \"In Character\"' option is enabled, it will also remind you about inactive stacks.",
	OPTIONS_LEGENDA_PRE_EXPIRATION_NAME = "Pre-Expiration Support",
	OPTIONS_LEGENDA_PRE_EXPIRATION_DESC = "This consumable/toy supports pre-expiration reminders and will notify you shortly before it expires when the pre-expiration reminder option is enabled.",
	OPTIONS_LEGENDA_NON_REFRESHABLE_NAME = "Non-Refreshable",
	OPTIONS_LEGENDA_NON_REFRESHABLE_DESC = "Refreshing this consumable/toy early will waste the stack without renewing its effect or timer.",
	OPTIONS_LEGENDA_STACKS_NAME = "Stack Count Support",
	OPTIONS_LEGENDA_STACKS_DESC = "This consumable/toy supports setting a desired stack count and will remind you when your current stacks are below that number.",
	OPTIONS_LEGENDA_NO_AURA_NAME = "Tracking Limitations",
	OPTIONS_LEGENDA_NO_AURA_DESC = "This consumable/toy is harder to track and may occasionally cause irregularities.",
	OPTIONS_LEGENDA_COOLDOWN_NAME = "Cooldown Mismatch",
	OPTIONS_LEGENDA_COOLDOWN_DESC = "This consumable/toy has a longer cooldown than its effect duration, which may cause the reminder popup to appear while the refresh button is still on cooldown.|n|n|cnWARNING_FONT_COLOR:This can be mitigated by enabling 'Use Toy Cooldown' in the General menu.|r",

	-- Appearance
	OPTIONS_TAB_APPEARANCE_TITLE = "Appearance",
	OPTIONS_TAB_APPEARANCE_INSTRUCTION = "These options control all reminders for consumables/toys that alter your appearance.",

	-- Effect
	OPTIONS_TAB_EFFECT_TITLE = "Effect",
	OPTIONS_TAB_EFFECT_INSTRUCTION = "These options control all reminders for consumables/toys that apply a visual.",

	-- Handheld
	OPTIONS_TAB_HANDHELD_TITLE = "Handheld",
	OPTIONS_TAB_HANDHELD_INSTRUCTION = "These options control all reminders for consumables/toys that make your character hold an item.",

	-- Placement
	OPTIONS_TAB_PLACEMENT_TITLE = "Placement",
	OPTIONS_TAB_PLACEMENT_INSTRUCTION = "These options control all reminders for consumables/toys that are placed on the ground.",

	-- Prism
	OPTIONS_TAB_PRISM_TITLE = "Prism",
	OPTIONS_TAB_PRISM_INSTRUCTION = "These options control all reminders for prism consumables/toys that change your appearance.",

	-- Size
	OPTIONS_TAB_SIZE_TITLE = "Size",
	OPTIONS_TAB_SIZE_INSTRUCTION = "These options control all reminders for consumables/toys that change your character's size.",

	--/ Addon Compartment /--
	ADDON_COMPARTMENT_DESC = "|cnGREEN_FONT_COLOR:Left-Click: Open options|nRight-Click: Open profiles|r",

	-- Profiles
	OPTIONS_PROFILES_HEADER = "Profiles",
	OPTIONS_PROFILES_INSTRUCTION = "Settings under the General tab are global, while all consumable/toys settings are profile-specific.",
	OPTIONS_PROFILES_RESETBUTTON_NAME = "Reset Profile",
	OPTIONS_PROFILES_RESETBUTTON_DESC = "Reset the current profile to its default settings.",
	OPTIONS_PROFILES_CURRENTPROFILE = "Current Profile: %s",
	OPTIONS_PROFILES_EXISTINGPROFILES_NAME = "Existing Profiles",
	OPTIONS_PROFILES_EXISTINGPROFILES_DESC = "Select one of your available profiles.",
	OPTIONS_PROFILES_NEWPROFILE_NAME = "New Profile",
	OPTIONS_PROFILES_NEWPROFILE_DESC = "Enter a name for the new profile and press Enter.",
	OPTIONS_PROFILES_COPYFROM_NAME = "Copy From",
	OPTIONS_PROFILES_COPYFROM_DESC = "Copy settings from the selected profile into your current profile.",
	OPTIONS_PROFILES_DELETEPROFILE_NAME = "Delete Profile",
	OPTIONS_PROFILES_DELETEPROFILE_DESC = "Delete the selected profile from the database.",
};

SIPPYCUP.L_ENUS = L;
