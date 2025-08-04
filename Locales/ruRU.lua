-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0
-- Перевод ZamestoTV
local title = C_AddOns.GetAddOnMetadata("SippyCup", "Title");
local L = LibStub("AceLocale-3.0"):NewLocale("SippyCup", "ruRU", false);
if not L then return; end

--/ Welcome message /--
L.WELCOMEMSG_VERSION = "Приготовлено с душой |cnGREEN_FONT_COLOR:%s|r!";
L.WELCOMEMSG_OPTIONS = "Настройки доступны через |cnGREEN_FONT_COLOR:/sc|r или |cnGREEN_FONT_COLOR:/sippycup|r.";

--/ Popup dialog /--
L.POPUP_ON_COOLDOWN_TEXT = "currently on cooldown."; -- NEW
L.POPUP_NOT_IN_INVENTORY_TEXT = "не найден в вашем инвентаре."; -- (TEXT CHANGE IN ENGLISH)
L.POPUP_NOT_ENOUGH_IN_INVENTORY_TEXT = "недостаточно в вашем инвентаре.|n(%d missing)"; -- NEW (Ending)
L.POPUP_INSUFFICIENT_NEXT_REFRESH_TEXT = "insufficient (%d / %d) for next refresh."; -- NEW
L.POPUP_LOW_STACK_COUNT_TEXT = "не соответствует желаемому количеству в стопке!"; -- (TEXT CHANGE IN ENGLISH)
L.POPUP_NOT_ACTIVE_TEXT = "is not active!"; -- NEW
L.POPUP_EXPIRING_SOON_TEXT = "is expiring soon!"; -- NEW
L.POPUP_IGNORE_TT = "блокирует напоминания до следующей сессии."; -- (TEXT CHANGE IN ENGLISH)

L.POPUP_LINK = "|n|nНажмите |cnGREEN_FONT_COLOR:CTRL-C|r, чтобы скопировать выделенное, затем вставьте в браузер с помощью |cnGREEN_FONT_COLOR:CTRL-V|r.";
L.COPY_SYSTEM_MESSAGE = "Скопировано в буфер обмена.";

--/ Options /--

-- General options
L.OPTIONS_GENERAL_HEADER = "General"; -- (NEW)
L.OPTIONS_GENERAL_WELCOME_NAME = "Приветственное сообщение";
L.OPTIONS_GENERAL_WELCOME_DESC = "Включает/выключает отображение приветственного сообщения.";
L.OPTIONS_GENERAL_MINIMAPBUTTON_NAME = "Кнопка на миникарте";
L.OPTIONS_GENERAL_MINIMAPBUTTON_DESC = "Включает/выключает отображение кнопки на миникарте.";
L.OPTIONS_GENERAL_ADDONCOMPARTMENT_NAME = "Отсек аддонов";
L.OPTIONS_GENERAL_ADDONCOMPARTMENT_DESC = "Включает/выключает отображение кнопки в отсеке аддонов.";

L.OPTIONS_GENERAL_POPUPS_HEADER = "Всплывающие напоминания";
L.OPTIONS_GENERAL_POPUPS_POSITION_NAME = "Положение";
L.OPTIONS_GENERAL_POPUPS_POSITION_DESC = "Выберите, где на экране будут отображаться всплывающие напоминания.";
L.OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE = "Pre-Expiration Reminder"; -- NEW
L.OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE_DESC = "Toggles whether pre-expiration reminders should show close to the consumable expiring.|n|n|cnWARNING_FONT_COLOR:Keep in mind that not all items support this (it will be displayed on the enable tooltip).|r"; -- NEW
L.OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE = "Insufficient Reminder"; -- NEW
L.OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE_DESC = "Toggles whether an insufficient quantity popup for next refresh should show."; -- NEW
L.OPTIONS_GENERAL_POPUPS_IGNORES = "Сбросить проигнорированные напоминания";
L.OPTIONS_GENERAL_POPUPS_IGNORES_TEXT = "Сбросить все всплывающие напоминания, проигнорированные в этой сессии, чтобы они снова стали видны."; -- (TEXT CHANGE IN ENGLISH)
L.OPTIONS_GENERAL_POPUPS_ALERT_SOUND_DESC = "Выберите звук, который будет воспроизводиться при появлении всплывающего напоминания."; -- (TEXT CHANGE IN ENGLISH)
L.OPTIONS_GENERAL_POPUPS_SOUND_ENABLE_DESC = "Включает/выключает воспроизведение звука при появлении всплывающего напоминания.";
L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE = "Мигание панели задач";
L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE_DESC = "Включает/выключает мигание панели задач при появлении всплывающего напоминания.";

L.OPTIONS_GENERAL_ADDONINTEGRATIONS_HEADER = "Интеграция с аддонами";
L.OPTIONS_GENERAL_MSP_STATUSCHECK_ENABLE = "Только в режиме \"в роли\"";
L.OPTIONS_GENERAL_MSP_STATUSCHECK_DESC = "Показывать всплывающие окна только когда ваш персонаж отмечен как |cnGREEN_FONT_COLOR:в роли|r.|n|n|cnWARNING_FONT_COLOR:Обратите внимание, что для этого требуется работающий аддон для ролевого профиля (например, TRP, MRP, XRP).|r"; -- (TEXT CHANGE IN ENGLISH)

L.OPTIONS_GENERAL_ADDONINFO_HEADER = "Информация об аддоне";
L.OPTIONS_GENERAL_ADDONINFO_VERSION = "|cnNORMAL_FONT_COLOR:Версия:|r %s";
L.OPTIONS_GENERAL_ADDONINFO_AUTHOR = "|cnNORMAL_FONT_COLOR:Автор:|r %s";
L.OPTIONS_GENERAL_ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Сборка:|r %s";
L.OPTIONS_GENERAL_ADDONINFO_BUILD_OUTDATED = title .. " не оптимизирован для текущей сборки игры.|n|n|cnWARNING_FONT_COLOR:Если вы заметите неожиданное поведение, это может быть причиной.|r"; -- (TEXT CHANGE IN ENGLISH)
L.OPTIONS_GENERAL_ADDONINFO_BUILD_CURRENT = title .. " оптимизирован для вашей текущей сборки игры.|n|n|cnGREEN_FONT_COLOR:Всё должно работать как ожидается.|r"; -- (TEXT CHANGE IN ENGLISH)
L.OPTIONS_GENERAL_BLUESKY_SHILL_DESC = "Подписывайтесь на меня в Bluesky!";

-- Generic
L.OPTIONS_SLIDER_TEXT = "Установить желаемое количество в стопке для |cnGREEN_FONT_COLOR:%s|r.|n|nНапоминания будут появляться, пока не будет достигнуто желаемое количество в стопке.";
L.OPTIONS_DESIRED_STACKS = "Желаемые стопки";
L.OPTIONS_TITLE_EXTRA = "|n|nПримечание: При входе в игру напоминания будут показаны только для расходуемых предметов, у которых активные стопки меньше, чем желаемое количество."; -- (TEXT CHANGE IN ENGLISH)

L.OPTIONS_LEGENDA_PRE_EXPIRATION_NAME = "Pre-Expiration Support"; -- (NEW)
L.OPTIONS_LEGENDA_PRE_EXPIRATION_DESC = "This consumable supports pre-expiration reminders and will notify you shortly before it expires when the pre-expiration reminder option is enabled."; -- (NEW)
L.OPTIONS_LEGENDA_NON_REFRESHABLE_NAME = "Non-Refreshable"; -- (NEW)
L.OPTIONS_LEGENDA_NON_REFRESHABLE_DESC = "Refreshing this consumable early will waste the stack without renewing its effect or timer."; -- (NEW)
L.OPTIONS_LEGENDA_STACKS_NAME = "Stack Count Support"; -- (NEW)
L.OPTIONS_LEGENDA_STACKS_DESC = "This consumable supports setting a desired stack count and will remind you when your current stacks are below that number."; -- (NEW)
L.OPTIONS_LEGENDA_NO_AURA_NAME = "Tracking Limitations"; -- (NEW)
L.OPTIONS_LEGENDA_NO_AURA_DESC = "This consumable is harder to track and may occasionally cause irregularities."; -- (NEW)

-- Appearance
L.OPTIONS_CONSUMABLE_APPEARANCE_TITLE = "Appearance"; -- NEW
L.OPTIONS_CONSUMABLE_APPEARANCE_INSTRUCTION = "These options control all reminders for consumables that alter your appearance."; -- NEW

-- Effect
L.OPTIONS_CONSUMABLE_EFFECT_TITLE = "Эффект";
L.OPTIONS_CONSUMABLE_EFFECT_INSTRUCTION = "Эти настройки управляют всеми напоминаниями о расходуемых предметах, которые создают эффект.";

-- Handheld
L.OPTIONS_CONSUMABLE_HANDHELD_TITLE = "Handheld"; -- NEW
L.OPTIONS_CONSUMABLE_HANDHELD_INSTRUCTION = "These options control all reminders for consumables that make the character hold something."; -- NEW

-- Placement
L.OPTIONS_CONSUMABLE_PLACEMENT_TITLE = "Placement"; -- NEW
L.OPTIONS_CONSUMABLE_PLACEMENT_INSTRUCTION = "These options control all reminders for consumables that can be placed on the ground."; -- NEW

-- Prism
L.OPTIONS_CONSUMABLE_PRISM_TITLE = "Prism"; -- NEW
L.OPTIONS_CONSUMABLE_PRISM_INSTRUCTION = "These options control all reminders for prism consumables to alter your appearance."; -- NEW

-- Size
L.OPTIONS_CONSUMABLE_SIZE_TITLE = "Размер";
L.OPTIONS_CONSUMABLE_SIZE_INSTRUCTION = "Эти настройки управляют всеми напоминаниями о расходуемых предметах, которые изменяют размер персонажа.";

--/ Addon Compartment /--
L.ADDON_COMPARTMENT_DESC = "|cnGREEN_FONT_COLOR:ЛКМ: Открыть настройки|nПКМ: Открыть профили|r";

-- Profiles
L.OPTIONS_PROFILES_HEADER = "Profiles"; -- (NEW)
L.OPTIONS_PROFILES_INSTRUCTION = "Settings under the General tab are global, while all consumable settings are profile-specific."; -- (NEW)

L.OPTIONS_PROFILES_RESETBUTTON_NAME = "Reset Profile"; -- (NEW)
L.OPTIONS_PROFILES_RESETBUTTON_DESC = "Reset the current profile to its default settings."; -- (NEW)

L.OPTIONS_PROFILES_CURRENTPROFILE = "Current Profile: %s"; -- (NEW)

L.OPTIONS_PROFILES_EXISTINGPROFILES_NAME = "Existing Profiles"; -- (NEW)
L.OPTIONS_PROFILES_EXISTINGPROFILES_DESC = "Select one of your available profiles."; -- (NEW)

L.OPTIONS_PROFILES_NEWPROFILE_NAME = "New Profile"; -- (NEW)
L.OPTIONS_PROFILES_NEWPROFILE_DESC = "Enter a name for the new profile and press Enter."; -- (NEW)

L.OPTIONS_PROFILES_COPYFROM_NAME = "Copy From"; -- (NEW)
L.OPTIONS_PROFILES_COPYFROM_DESC = "Copy settings from the selected profile into your current profile."; -- (NEW)

L.OPTIONS_PROFILES_DELETEPROFILE_NAME = "Delete Profile"; -- (NEW)
L.OPTIONS_PROFILES_DELETEPROFILE_DESC = "Delete the selected profile from the database."; -- (NEW)
