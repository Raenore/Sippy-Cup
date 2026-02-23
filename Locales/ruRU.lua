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
    POPUP_ON_COOLDOWN_TEXT = "Перезарядка",
	POPUP_IN_FLIGHT_TEXT = "Отключено, чтобы избежать спешивания во время полета.",
	POPUP_NOT_IN_PARTY_TEXT = "Отключено, так как предмет требует нахождения в группе.",
	POPUP_FOOD_BUFF_TEXT = "Исчезнет после получения эффекта от еды. Не двигайтесь!",
	POPUP_NOT_IN_INVENTORY_TEXT = "Нет в сумках",
	POPUP_NOT_ENOUGH_IN_INVENTORY_TEXT = "Недостаточно (не хватает: %d)",
    POPUP_INSUFFICIENT_NEXT_REFRESH_TEXT = "недостаточно (%d / %d) для следующего обновления.",
    POPUP_LOW_STACK_COUNT_TEXT = "Мало стаков!",
	POPUP_NOT_ACTIVE_TEXT = "не активно!",
	POPUP_EXPIRING_SOON_TEXT = "скоро истекает!",
    POPUP_IGNORE_TT = "Блокирует напоминания для этого предмета/игрушки до конца текущей сессии.",
	POPUP_LINK = "|n|nНажмите |cnGREEN_FONT_COLOR:CTRL-C|r, чтобы скопировать выделенное, затем вставьте в браузер с помощью |cnGREEN_FONT_COLOR:CTRL-V|r.",
	COPY_SYSTEM_MESSAGE = "Скопировано в буфер обмена.",
	POPUP_RELOAD_TITLE = "Перезагрузка интерфейса",
	POPUP_RELOAD_WARNING = "Перезагрузить интерфейс сейчас, чтобы применить изменения?",

	--/ Options /--

	-- General options
    OPTIONS_GENERAL_HEADER = "Общие",
	OPTIONS_GENERAL_WELCOME_NAME = "Приветственное сообщение",
	OPTIONS_GENERAL_WELCOME_DESC = "Включает/выключает отображение приветственного сообщения.",
	OPTIONS_GENERAL_MINIMAPBUTTON_NAME = "Кнопка на миникарте",
	OPTIONS_GENERAL_MINIMAPBUTTON_DESC = "Включает/выключает отображение кнопки на миникарте.",
	OPTIONS_GENERAL_ADDONCOMPARTMENT_NAME = "Отсек аддонов",
	OPTIONS_GENERAL_ADDONCOMPARTMENT_DESC = "Включает/выключает отображение кнопки в отсеке аддонов.",
    OPTIONS_GENERAL_NEW_FEATURE_NOTIFICATION_NAME = "Индикатор новинок",
	OPTIONS_GENERAL_NEW_FEATURE_NOTIFICATION_DESC = "Включает или отключает отображение иконки рядом с новыми функциями.|n|nИконка будет отображаться до выхода следующей минорной версии. Например, функция, добавленная в 0.6.1, будет помечена до версии 0.7.0.|n|n|cnWARNING_FONT_COLOR:Для применения этой настройки требуется перезагрузка интерфейса.|r",

	OPTIONS_GENERAL_POPUPS_HEADER = "Всплывающие напоминания",
	OPTIONS_GENERAL_POPUPS_POSITION_NAME = "Положение",
	OPTIONS_GENERAL_POPUPS_POSITION_DESC = "Выберите, где на экране будут отображаться всплывающие напоминания.",
	OPTIONS_GENERAL_POPUPS_POSITION_TOP = "Сверху (по умолчанию)",
	OPTIONS_GENERAL_POPUPS_POSITION_CENTER = "По центру",
	OPTIONS_GENERAL_POPUPS_POSITION_BOTTOM = "Снизу",
	OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE = "Напоминание об истечении",
	OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE_DESC = "Определяет, показывать ли напоминания незадолго до окончания действия расходуемого предмета.|n|n|cnWARNING_FONT_COLOR:Учтите, что не все предметы поддерживают эту функцию (информация будет в подсказке при включении).|r",
	OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_LEAD_TIMER = "Время до напоминания",
	OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_LEAD_TIMER_TEXT = "Укажите время (в минутах) до истечения эффекта, когда должно появиться окно напоминания (по умолчанию: 1 минута).|n|n|cnWARNING_FONT_COLOR:Если предмет не поддерживает выбранное время, будет использовано значение в 1 минуту (или 15 секунд, если 1 минута недоступна).|r",
	OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE = "Напоминание о нехватке",
	OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE_DESC = "Определяет, показывать ли всплывающее окно при недостаточном количестве ресурсов для следующего обновления.",
	OPTIONS_GENERAL_POPUPS_TRACK_TOY_ITEM_CD_ENABLE = "Кулдаун игрушек",
	OPTIONS_GENERAL_POPUPS_TRACK_TOY_ITEM_CD_ENABLE_DESC = "Включает отслеживание перезарядки самой игрушки, а не её эффекта. Это гарантирует, что окно появится только тогда, когда игрушку действительно можно использовать.|n|n|cnWARNING_FONT_COLOR:Это касается только игрушек с несовпадающим временем действия и перезарядки.|r",
	OPTIONS_GENERAL_POPUPS_IGNORES = "Сбросить проигнорированные напоминания",
	OPTIONS_GENERAL_POPUPS_IGNORES_TEXT = "Сбрасывает список игнорируемых в этой сессии напоминаний, делая их снова видимыми.",
	OPTIONS_GENERAL_POPUPS_ALERT_SOUND_DESC = "Выберите звук, который будет проигрываться при появлении всплывающего окна напоминания.",
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
	OPTIONS_GENERAL_ADDONINFO_BUILD_OUTDATED = title .. " не оптимизирован для этой версии игры.|n|n|cnWARNING_FONT_COLOR:Это может привести к непредвиденным ошибкам.|r",
	OPTIONS_GENERAL_ADDONINFO_BUILD_CURRENT = title .. " оптимизирован для текущей версии игры.|n|n|cnGREEN_FONT_COLOR:Все функции должны работать исправно.|r",
	OPTIONS_GENERAL_BLUESKY_SHILL_DESC = "Подписывайтесь на меня в Bluesky!",

	-- Generic
	OPTIONS_SLIDER_TEXT = "Установить желаемое количество в стопке для |cnGREEN_FONT_COLOR:%s|r.|n|nНапоминания будут появляться, пока не будет достигнуто желаемое количество в стопке.",
	OPTIONS_DESIRED_STACKS = "Желаемые стопки",
	OPTIONS_TITLE_EXTRA = "|n|nПри входе в игру появится окно для отслеживаемых предметов/игрушек с активными стаками. Если включена опция «Только в образе», аддон также напомнит вам о недостающих стаках.",

	OPTIONS_LEGENDA_PRE_EXPIRATION_NAME = "Поддержка напоминаний об истечении",
	OPTIONS_LEGENDA_PRE_EXPIRATION_DESC = "Этот расходуемый предмет поддерживает напоминания. Вы получите уведомление незадолго до окончания его действия, если включена соответствующая опция.",
	OPTIONS_LEGENDA_NON_REFRESHABLE_NAME = "Не обновляемое",
	OPTIONS_LEGENDA_NON_REFRESHABLE_DESC = "Досрочное использование этого предмета потратит заряд, но не обновит длительность или эффект.",
	OPTIONS_LEGENDA_STACKS_NAME = "Поддержка количества стаков",
	OPTIONS_LEGENDA_STACKS_DESC = "Для этого предмета можно задать нужное количество стаков. Аддон напомнит вам, когда их станет меньше указанного числа.",
	OPTIONS_LEGENDA_NO_AURA_NAME = "Ограничения отслеживания",
	OPTIONS_LEGENDA_NO_AURA_DESC = "Этот предмет сложно отследить, что может иногда приводить к неточностям в работе индикаторов.",
	OPTIONS_LEGENDA_COOLDOWN_NAME = "Несовпадение кулдауна",
	OPTIONS_LEGENDA_COOLDOWN_DESC = "Перезарядка этого предмета/игрушки дольше, чем длительность эффекта. Окно напоминания может появиться, пока кнопка использования еще на кулдауне.|n|n|cnWARNING_FONT_COLOR:Это можно исправить, включив опцию «Кулдаун игрушек» в общем меню.|r",

	-- Appearance
	OPTIONS_TAB_APPEARANCE_TITLE = "Внешний вид",
	OPTIONS_TAB_APPEARANCE_INSTRUCTION = "Эти настройки управляют всеми напоминаниями для предметов и игрушек, изменяющих облик вашего персонажа.",

	-- Effect
	OPTIONS_TAB_EFFECT_TITLE = "Эффект",
	OPTIONS_TAB_EFFECT_INSTRUCTION = "Эти настройки управляют всеми напоминаниями о расходуемых предметах, которые создают эффект.",

	-- Handheld
	OPTIONS_TAB_HANDHELD_TITLE = "В руках",
	OPTIONS_TAB_HANDHELD_INSTRUCTION = "Эти настройки управляют напоминаниями для предметов и игрушек, которые персонаж держит в руках.",

	-- Placement
	OPTIONS_TAB_PLACEMENT_TITLE = "Размещаемое",
	OPTIONS_TAB_PLACEMENT_INSTRUCTION = "Эти настройки управляют напоминаниями для предметов и игрушек, которые устанавливаются на землю.",

	-- Prism
	OPTIONS_TAB_PRISM_TITLE = "Призма",
	OPTIONS_TAB_PRISM_INSTRUCTION = "Эти настройки управляют напоминаниями для призм, изменяющих ваш внешний вид.",
	OPTIONS_TAB_PRISM_TIMER = "%s — таймер",
	OPTIONS_TAB_PRISM_TIMER_TEXT = "Укажите время (в минутах) до истечения эффекта призмы, когда должно появиться окно напоминания (по умолчанию: %d мин.).|n|n|cnWARNING_FONT_COLOR:Если предмет не поддерживает выбранное время, будет использовано значение по умолчанию (%d мин.).|r",

	-- Size
	OPTIONS_TAB_SIZE_TITLE = "Размер",
	OPTIONS_TAB_SIZE_INSTRUCTION = "Эти настройки управляют всеми напоминаниями о расходуемых предметах, которые изменяют размер персонажа.",

	--/ Addon Compartment /--
	ADDON_COMPARTMENT_DESC = "|cnGREEN_FONT_COLOR:ЛКМ: Открыть настройки|nПКМ: Открыть профили|r",

	-- Profiles
	OPTIONS_PROFILES_HEADER = "Профили",
	OPTIONS_PROFILES_INSTRUCTION = "Настройки во вкладке «Общие» являются глобальными, в то время как настройки расходуемых предметов привязаны к конкретному профилю.",
	OPTIONS_PROFILES_RESETBUTTON_NAME = "Сбросить профиль",
	OPTIONS_PROFILES_RESETBUTTON_DESC = "Сбросить настройки текущего профиля до значений по умолчанию.",
	OPTIONS_PROFILES_CURRENTPROFILE = "Текущий профиль: %s",
	OPTIONS_PROFILES_EXISTINGPROFILES_NAME = "Существующие профили",
	OPTIONS_PROFILES_EXISTINGPROFILES_DESC = "Выберите один из доступных профилей.",
	OPTIONS_PROFILES_NEWPROFILE_NAME = "Новый профиль",
	OPTIONS_PROFILES_NEWPROFILE_DESC = "Введите имя для нового профиля и нажмите Enter.",
	OPTIONS_PROFILES_COPYFROM_NAME = "Копировать из",
	OPTIONS_PROFILES_COPYFROM_DESC = "Скопировать настройки из выбранного профиля в текущий.",
	OPTIONS_PROFILES_DELETEPROFILE_NAME = "Удалить профиль",
	OPTIONS_PROFILES_DELETEPROFILE_DESC = "Удалить выбранный профиль из базы данных.",
};

SIPPYCUP.L_RURU = L;
