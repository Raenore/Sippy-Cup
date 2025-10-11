-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0
-- Перевод ZamestoTV

local title = C_AddOns.GetAddOnMetadata("SippyCup", "Title");
local L;

L = {
	--/ Welcome message /--
	WELCOMEMSG_VERSION = "Приготовлено с душой |cnGREEN_FONT_COLOR:%s|r!",
	WELCOMEMSG_OPTIONS = "Настройки доступны через |cnGREEN_FONT_COLOR:/sc|r или |cnGREEN_FONT_COLOR:/sippycup|r.",

	--/ Popup dialog /--
	POPUP_ON_COOLDOWN_TEXT = "currently on cooldown.", -- (NEW)
	POPUP_IN_FLIGHT_TEXT = "Disabled to prevent dismount during flight.", -- (NEW)
	POPUP_FOOD_BUFF_TEXT = "Disappears once food buff is applied. Do not move!", -- (NEW)
	POPUP_NOT_IN_INVENTORY_TEXT = "не найден в вашем инвентаре.", -- (TEXT CHANGE IN ENGLISH)
	POPUP_NOT_ENOUGH_IN_INVENTORY_TEXT = "недостаточно в вашем инвентаре.|n(%d missing)", -- (NEW) (Ending)
	POPUP_INSUFFICIENT_NEXT_REFRESH_TEXT = "insufficient (%d / %d) for next refresh.", -- (NEW)
	POPUP_LOW_STACK_COUNT_TEXT = "не соответствует желаемому количеству в стопке!", -- (TEXT CHANGE IN ENGLISH)
	POPUP_NOT_ACTIVE_TEXT = "is not active!", -- (NEW)
	POPUP_EXPIRING_SOON_TEXT = "is expiring soon!", -- (NEW)
	POPUP_IGNORE_TT = "блокирует напоминания до следующей сессии.", -- (TEXT CHANGE IN ENGLISH)
	POPUP_LINK = "|n|nНажмите |cnGREEN_FONT_COLOR:CTRL-C|r, чтобы скопировать выделенное, затем вставьте в браузер с помощью |cnGREEN_FONT_COLOR:CTRL-V|r.",
	COPY_SYSTEM_MESSAGE = "Скопировано в буфер обмена.",

	--/ Options /--

	-- General options
	OPTIONS_GENERAL_HEADER = "General", -- (NEW)
	OPTIONS_GENERAL_WELCOME_NAME = "Приветственное сообщение",
	OPTIONS_GENERAL_WELCOME_DESC = "Включает/выключает отображение приветственного сообщения.",
	OPTIONS_GENERAL_MINIMAPBUTTON_NAME = "Кнопка на миникарте",
	OPTIONS_GENERAL_MINIMAPBUTTON_DESC = "Включает/выключает отображение кнопки на миникарте.",
	OPTIONS_GENERAL_ADDONCOMPARTMENT_NAME = "Отсек аддонов",
	OPTIONS_GENERAL_ADDONCOMPARTMENT_DESC = "Включает/выключает отображение кнопки в отсеке аддонов.",

	OPTIONS_GENERAL_POPUPS_HEADER = "Всплывающие напоминания",
	OPTIONS_GENERAL_POPUPS_POSITION_NAME = "Положение",
	OPTIONS_GENERAL_POPUPS_POSITION_DESC = "Выберите, где на экране будут отображаться всплывающие напоминания.",
	OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE = "Pre-Expiration Reminder", -- (NEW)
	OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE_DESC = "Toggles whether pre-expiration reminders should show close to the consumable expiring.|n|n|cnWARNING_FONT_COLOR:Keep in mind that not all items support this (it will be displayed on the enable tooltip).|r", -- (NEW)
	OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE = "Insufficient Reminder", -- (NEW)
	OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE_DESC = "Toggles whether an insufficient quantity popup for next refresh should show.", -- (NEW)
	OPTIONS_GENERAL_POPUPS_TRACK_TOY_ITEM_CD_ENABLE = "Use Toy Cooldown", -- (NEW)
	OPTIONS_GENERAL_POPUPS_TRACK_TOY_ITEM_CD_ENABLE_DESC = "Toggles tracking toy cooldowns from the toy itself instead of its effect, ensuring the popup only appears when the toy can be used.|n|n|cnWARNING_FONT_COLOR:This only affects 'Cooldown Mismatch' toys.|r", -- (NEW)
	OPTIONS_GENERAL_POPUPS_IGNORES = "Сбросить проигнорированные напоминания",
	OPTIONS_GENERAL_POPUPS_IGNORES_TEXT = "Сбросить все всплывающие напоминания, проигнорированные в этой сессии, чтобы они снова стали видны.", -- (TEXT CHANGE IN ENGLISH)
	OPTIONS_GENERAL_POPUPS_ALERT_SOUND_DESC = "Выберите звук, который будет воспроизводиться при появлении всплывающего напоминания.", -- (TEXT CHANGE IN ENGLISH)
	OPTIONS_GENERAL_POPUPS_SOUND_ENABLE_DESC = "Включает/выключает воспроизведение звука при появлении всплывающего напоминания.",
	OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE = "Мигание панели задач",
	OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE_DESC = "Включает/выключает мигание панели задач при появлении всплывающего напоминания.",

	OPTIONS_GENERAL_ADDONINTEGRATIONS_HEADER = "Интеграция с аддонами",
	OPTIONS_GENERAL_MSP_STATUSCHECK_ENABLE = "Только в режиме \"в роли\"",
	OPTIONS_GENERAL_MSP_STATUSCHECK_DESC = "Показывать всплывающие окна только когда ваш персонаж отмечен как |cnGREEN_FONT_COLOR:в роли|r.|n|n|cnWARNING_FONT_COLOR:Обратите внимание, что для этого требуется работающий аддон для ролевого профиля (например, TRP, MRP, XRP).|r", -- (TEXT CHANGE IN ENGLISH)

	OPTIONS_GENERAL_ADDONINFO_HEADER = "Информация об аддоне",
	OPTIONS_GENERAL_ADDONINFO_VERSION = "|cnNORMAL_FONT_COLOR:Версия:|r %s",
	OPTIONS_GENERAL_ADDONINFO_AUTHOR = "|cnNORMAL_FONT_COLOR:Автор:|r %s",
	OPTIONS_GENERAL_ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Сборка:|r %s",
	OPTIONS_GENERAL_ADDONINFO_BUILD_OUTDATED = title .. " не оптимизирован для текущей сборки игры.|n|n|cnWARNING_FONT_COLOR:Если вы заметите неожиданное поведение, это может быть причиной.|r", -- (TEXT CHANGE IN ENGLISH)
	OPTIONS_GENERAL_ADDONINFO_BUILD_CURRENT = title .. " оптимизирован для вашей текущей сборки игры.|n|n|cnGREEN_FONT_COLOR:Всё должно работать как ожидается.|r", -- (TEXT CHANGE IN ENGLISH)
	OPTIONS_GENERAL_BLUESKY_SHILL_DESC = "Подписывайтесь на меня в Bluesky!",

	-- Generic
	OPTIONS_SLIDER_TEXT = "Установить желаемое количество в стопке для |cnGREEN_FONT_COLOR:%s|r.|n|nНапоминания будут появляться, пока не будет достигнуто желаемое количество в стопке.",
	OPTIONS_DESIRED_STACKS = "Желаемые стопки",
	OPTIONS_TITLE_EXTRA = "|n|nПримечание: При входе в игру напоминания будут показаны только для расходуемых предметов, у которых активные стопки меньше, чем желаемое количество.", -- (TEXT CHANGE IN ENGLISH)

	OPTIONS_LEGENDA_PRE_EXPIRATION_NAME = "Pre-Expiration Support", -- (NEW)
	OPTIONS_LEGENDA_PRE_EXPIRATION_DESC = "This consumable supports pre-expiration reminders and will notify you shortly before it expires when the pre-expiration reminder option is enabled.", -- (NEW)
	OPTIONS_LEGENDA_NON_REFRESHABLE_NAME = "Non-Refreshable", -- (NEW)
	OPTIONS_LEGENDA_NON_REFRESHABLE_DESC = "Refreshing this consumable early will waste the stack without renewing its effect or timer.", -- (NEW)
	OPTIONS_LEGENDA_STACKS_NAME = "Stack Count Support", -- (NEW)
	OPTIONS_LEGENDA_STACKS_DESC = "This consumable supports setting a desired stack count and will remind you when your current stacks are below that number.", -- (NEW)
	OPTIONS_LEGENDA_NO_AURA_NAME = "Tracking Limitations", -- (NEW)
	OPTIONS_LEGENDA_NO_AURA_DESC = "This consumable is harder to track and may occasionally cause irregularities.", -- (NEW)
	OPTIONS_LEGENDA_COOLDOWN_NAME = "Cooldown Mismatch", -- (NEW)
	OPTIONS_LEGENDA_COOLDOWN_DESC = "This consumable/toy has a longer cooldown than its effect duration, which may cause the reminder popup to appear while the refresh button is still on cooldown.|n|n|cnWARNING_FONT_COLOR:This can be mitigated by enabling 'Use Toy Cooldown' in the General menu.|r", -- (NEW)

	-- Appearance
	OPTIONS_TAB_APPEARANCE_TITLE = "Appearance", -- (NEW)
	OPTIONS_TAB_APPEARANCE_INSTRUCTION = "These options control all reminders for consumables/toys that alter your appearance.", -- (NEW)

	-- Effect
	OPTIONS_TAB_EFFECT_TITLE = "Эффект",
	OPTIONS_TAB_EFFECT_INSTRUCTION = "Эти настройки управляют всеми напоминаниями о расходуемых предметах, которые создают эффект.",

	-- Handheld
	OPTIONS_TAB_HANDHELD_TITLE = "Handheld", -- (NEW)
	OPTIONS_TAB_HANDHELD_INSTRUCTION = "These options control all reminders for consumables/toys that make the character hold something.", -- (NEW)

	-- Placement
	OPTIONS_TAB_PLACEMENT_TITLE = "Placement", -- (NEW)
	OPTIONS_TAB_PLACEMENT_INSTRUCTION = "These options control all reminders for consumables/toys that can be placed on the ground.", -- (NEW)

	-- Prism
	OPTIONS_TAB_PRISM_TITLE = "Prism", -- (NEW)
	OPTIONS_TAB_PRISM_INSTRUCTION = "These options control all reminders for prism consumables/toys to alter your appearance.", -- (NEW)

	-- Size
	OPTIONS_TAB_SIZE_TITLE = "Размер",
	OPTIONS_TAB_SIZE_INSTRUCTION = "Эти настройки управляют всеми напоминаниями о расходуемых предметах, которые изменяют размер персонажа.",

	--/ Addon Compartment /--
	ADDON_COMPARTMENT_DESC = "|cnGREEN_FONT_COLOR:ЛКМ: Открыть настройки|nПКМ: Открыть профили|r",

	-- Profiles
	OPTIONS_PROFILES_HEADER = "Profiles", -- (NEW)
	OPTIONS_PROFILES_INSTRUCTION = "Settings under the General tab are global, while all consumable settings are profile-specific.", -- (NEW)
	OPTIONS_PROFILES_RESETBUTTON_NAME = "Reset Profile", -- (NEW)
	OPTIONS_PROFILES_RESETBUTTON_DESC = "Reset the current profile to its default settings.", -- (NEW)
	OPTIONS_PROFILES_CURRENTPROFILE = "Current Profile: %s", -- (NEW)
	OPTIONS_PROFILES_EXISTINGPROFILES_NAME = "Existing Profiles", -- (NEW)
	OPTIONS_PROFILES_EXISTINGPROFILES_DESC = "Select one of your available profiles.", -- (NEW)
	OPTIONS_PROFILES_NEWPROFILE_NAME = "New Profile", -- (NEW)
	OPTIONS_PROFILES_NEWPROFILE_DESC = "Enter a name for the new profile and press Enter.", -- (NEW)
	OPTIONS_PROFILES_COPYFROM_NAME = "Copy From", -- (NEW)
	OPTIONS_PROFILES_COPYFROM_DESC = "Copy settings from the selected profile into your current profile.", -- (NEW)
	OPTIONS_PROFILES_DELETEPROFILE_NAME = "Delete Profile", -- (NEW)
	OPTIONS_PROFILES_DELETEPROFILE_DESC = "Delete the selected profile from the database.", -- (NEW)
};

SIPPYCUP.L_RURU = L;
