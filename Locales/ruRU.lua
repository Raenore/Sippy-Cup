-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0
-- Перевод ZamestoTV
local title = C_AddOns.GetAddOnMetadata("SippyCup", "Title");
local L = LibStub("AceLocale-3.0"):NewLocale("SippyCup", "ruRU", false);
if not L then return; end

--/ Welcome message /--
L.WELCOMEMSG_VERSION = "Приготовлено с душой |cnGREEN_FONT_COLOR:%s|r!";
L.WELCOMEMSG_OPTIONS = "Настройки доступны через |cnGREEN_FONT_COLOR:/sc|r или |cnGREEN_FONT_COLOR:/sippycup|r.";

--/ Consumable names /--
L.ARCHIVISTS_CODEX = "Кодекс архивариуса";
L.ASHEN_LINIMENT = "Пепельная мазь";
L.DARKMOON_FIREWATER = "Огненная вода Новолуния";
L.ELIXIR_OF_GIANT_GROWTH = "Эликсир увеличения";
L.ELIXIR_OF_TONGUES = "Лингвистическое зелье";
L.FIREWATER_SORBET = "Шербет из огненной воды";
L.FLICKERING_FLAME_HOLDER = "Держатель мерцающего пламени";
L.GIGANTIC_FEAST = "Пир для великанов";
L.INKY_BLACK_POTION = "Чернильно-черное зелье";
L.NOGGENFOGGER_SELECT_DOWN = "Особый эликсир Гогельмогеля Уменьшающий";
L.NOGGENFOGGER_SELECT_UP = "Особый эликсир Гогельмогеля Увеличивающий";
L.PROVIS_WAX = "Воск из провиза";
L.PYGMY_OIL = "Карломасло";
L.RADIANT_FOCUS = "Сияющее средоточие";
L.SACREDITES_LEDGER = "Учетная книга сакралита";
L.SMALL_FEAST = "Пир для карликов";
L.SPARKBUG_JAR = "Банка с искрожуками";
L.STINKY_BRIGHT_POTION = "Яркое вонючее зелье";
L.SUNGLOW = "Солнечное сияние";
L.TATTERED_ARATHI_PRAYER_SCROLL = "Потрепанный молитвенный свиток арати";
L.WINTERFALL_FIREWATER = "Огненная вода Зимней Спячки";

--/ Popup dialog /--
L.POPUP_LACKING_TEXT = "не найден в вашем инвентаре.";
L.POPUP_LACKING_TEXT_AMOUNT = "недостаточно в вашем инвентаре.";
L.POPUP_TEXT = "не соответствует желаемому количеству в стопке!";
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
L.OPTIONS_SLIDER_TEXT = "Установить желаемое количество в стопке для |cnGREEN_FONT_COLOR:%s|r.|n|nНапоминания будут появляться, пока не будет достигнуто желаемое количество в стопке.";
L.OPTIONS_DESIRED_STACKS = "|cnWHITE_FONT_COLOR:Желаемые стопки|r";
L.OPTIONS_TITLE_EXTRA = "|n|nПримечание: При входе в игру напоминания будут показаны только для расходуемых предметов, у которых активные стопки меньше, чем желаемое количество.";

-- Effect
L.OPTIONS_CONSUMABLE_EFFECT_TITLE = "Эффект";
L.OPTIONS_CONSUMABLE_EFFECT_INSTRUCTION = "Эти настройки управляют всеми напоминаниями о расходуемых предметах, которые создают эффект.";

-- Size
L.OPTIONS_CONSUMABLE_SIZE_TITLE = "Размер";
L.OPTIONS_CONSUMABLE_SIZE_INSTRUCTION = "Эти настройки управляют всеми напоминаниями о расходуемых предметах, которые изменяют размер персонажа.";

--/ Addon Compartment /--
L.ADDON_COMPARTMENT_DESC = "|cnGREEN_FONT_COLOR:ЛКМ: Открыть настройки|nПКМ: Открыть профили|r";
