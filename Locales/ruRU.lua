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
L.POPUP_COOLDOWN_TEXT = "currently on cooldown."; -- NEW
L.POPUP_LACKING_TEXT = "не найден в вашем инвентаре.";
L.POPUP_LACKING_TEXT_AMOUNT = "недостаточно в вашем инвентаре.|n(%d missing)"; -- NEW (Ending)
L.POPUP_LACKING_TEXT_NEXT_REFRESH = "insufficient (%d / %d) for next refresh."; -- NEW
L.POPUP_STACK_TEXT = "не соответствует желаемому количеству в стопке!";
L.POPUP_MISSING_TEXT = "is not active!"; -- NEW
L.POPUP_EXPIRING_SOON_TEXT = "is expiring soon!"; -- NEW
L.POPUP_IGNORE_TT = IGNORE .. "|r |cnWHITE_FONT_COLOR: блокирует напоминания до следующей сессии.|r";

L.POPUP_LINK = "|n|nНажмите |cnGREEN_FONT_COLOR:CTRL-C|r, чтобы скопировать выделенное, затем вставьте в браузер с помощью |cnGREEN_FONT_COLOR:CTRL-V|r.";
L.COPY_SYSTEM_MESSAGE = "Скопировано в буфер обмена.";

--/ Options /--

-- General options
L.OPTIONS_GENERAL_WELCOME_NAME = "Приветственное сообщение";
L.OPTIONS_GENERAL_WELCOME_DESC = "Включает/выключает отображение приветственного сообщения.";
L.OPTIONS_GENERAL_MINIMAPBUTTON_NAME = "Кнопка на миникарте";
L.OPTIONS_GENERAL_MINIMAPBUTTON_DESC = "Включает/выключает отображение кнопки на миникарте.";
L.OPTIONS_GENERAL_ADDONCOMPARTMENT_NAME = "Отсек аддонов";
L.OPTIONS_GENERAL_ADDONCOMPARTMENT_DESC = "Включает/выключает отображение кнопки в отсеке аддонов.";

L.OPTIONS_GENERAL_POPUPS_HEADER = "Всплывающие напоминания";
L.OPTIONS_GENERAL_POPUPS_POSITION_NAME = "Положение";
L.OPTIONS_GENERAL_POPUPS_POSITION_DESC = "Выберите, где на экране будут отображаться всплывающие напоминания.";
L.OPTIONS_GENERAL_POPUPS_ICON_ENABLE = "Значок во всплывающем окне";
L.OPTIONS_GENERAL_POPUPS_ICON_ENABLE_DESC = "Включает/выключает отображение значка расходуемого предмета во всплывающем напоминании.|n|n|cnWARNING_FONT_COLOR:Учтите, что включение этой опции сделает всплывающее окно выше.|r";
L.OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE = "Pre-Expiration Reminder"; -- NEW
L.OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE_DESC = "Toggles whether pre-expiration reminders should show close to the consumable expiring.|n|n|cnWARNING_FONT_COLOR:Keep in mind that not all items support this (it will be displayed on the enable tooltip).|r"; -- NEW
L.OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE = "Insufficient Reminder"; -- NEW
L.OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE_DESC = "Toggles whether an insufficient quantity popup for next refresh should show."; -- NEW
L.OPTIONS_GENERAL_POPUPS_IGNORES = "Сбросить проигнорированные напоминания";
L.OPTIONS_GENERAL_POPUPS_IGNORES_TEXT = "Сбросить все всплывающие напоминания, проигнорированные в этой сессии, чтобы они снова стали видны.";
L.OPTIONS_GENERAL_POPUPS_ALERT_SOUND_DESC = "Выберите звук, который будет воспроизводиться при появлении всплывающего напоминания.";
L.OPTIONS_GENERAL_POPUPS_SOUND_ENABLE_DESC = "Включает/выключает воспроизведение звука при появлении всплывающего напоминания.";
L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE = "Мигание панели задач";
L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE_DESC = "Включает/выключает мигание панели задач при появлении всплывающего напоминания.";

L.OPTIONS_GENERAL_ADDONINTEGRATIONS_HEADER = "Интеграция с аддонами";
L.OPTIONS_GENERAL_MSP_STATUSCHECK_ENABLE = "Только в режиме \"в роли\"";
L.OPTIONS_GENERAL_MSP_STATUSCHECK_DESC = "Показывать всплывающие окна только когда ваш персонаж отмечен как |cnGREEN_FONT_COLOR:в роли|r.|n|n|cnWARNING_FONT_COLOR:Обратите внимание, что для этого требуется работающий аддон для ролевого профиля (например, TRP, MRP, XRP).|r";

L.OPTIONS_GENERAL_ADDONINFO_HEADER = "Информация об аддоне";
L.OPTIONS_GENERAL_ADDONINFO_VERSION = "|cnNORMAL_FONT_COLOR:Версия:|r %s";
L.OPTIONS_GENERAL_ADDONINFO_AUTHOR = "|cnNORMAL_FONT_COLOR:Автор:|r %s";
L.OPTIONS_GENERAL_ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Сборка:|r %s";
L.OPTIONS_GENERAL_ADDONINFO_BUILD_OUTDATED = title .. " не оптимизирован для текущей сборки игры.|n|n|cnWARNING_FONT_COLOR:Если вы заметите неожиданное поведение, это может быть причиной.|r";
L.OPTIONS_GENERAL_ADDONINFO_BUILD_CURRENT = title .. " оптимизирован для вашей текущей сборки игры.|n|n|cnGREEN_FONT_COLOR:Всё должно работать как ожидается.|r";
L.OPTIONS_GENERAL_BLUESKY_SHILL_DESC = "Подписывайтесь на меня в Bluesky!";

-- Generic
L.OPTIONS_ENABLE_TEXT = "Включить напоминания о расходуемых предметах для |cnGREEN_FONT_COLOR:%s|r.";
L.OPTIONS_ENABLE_PREXPIRE_TEXT = "|n|nNote that this consumable |cnGREEN_FONT_COLOR:supports pre-expiration reminders|r. When this feature is enabled, it will remind you close to it expiring."; -- NEW
L.OPTIONS_ENABLE_PREXPIRE_MAXSTACKS_TEXT = "|n|nNote that this consumable |cnGREEN_FONT_COLOR:supports pre-expiration reminders on maximum stacks|r. When this feature is enabled, it will remind you close to it expiring."; -- NEW
L.OPTIONS_ENABLE_NON_REFRESHABLE_TEXT = "|n|n|cnWARNING_FONT_COLOR:Note that you should not refresh this consumable before it expires, as the stack will be lost without any effects.|r"; -- NEW
L.OPTIONS_ENABLE_NON_AURA_TEXT = "|n|n|cnWARNING_FONT_COLOR:Note that this consumable is harder to track, resulting in possible irregularities from time to time.|r"; -- NEW
L.OPTIONS_SLIDER_TEXT = "Установить желаемое количество в стопке для |cnGREEN_FONT_COLOR:%s|r.|n|nНапоминания будут появляться, пока не будет достигнуто желаемое количество в стопке.";
L.OPTIONS_DESIRED_STACKS = "|cnWHITE_FONT_COLOR:Желаемые стопки|r";
L.OPTIONS_TITLE_EXTRA = "|n|nПримечание: При входе в игру напоминания будут показаны только для расходуемых предметов, у которых активные стопки меньше, чем желаемое количество.";

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
