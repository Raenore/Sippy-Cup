-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0
-- Traduction Romanv

local title = C_AddOns.GetAddOnMetadata("SippyCup", "Title");
local L;

L = {
	--/ Welcome message /--
	WELCOMEMSG_VERSION = "Preparado con |cnGREEN_FONT_COLOR:%s|r sabor (|cnWHITE_FONT_COLOR:%s|r)!",
	WELCOMEMSG_OPTIONS = "Opciones disponibles a través del comando: |cnGREEN_FONT_COLOR:/sc|r o |cnGREEN_FONT_COLOR:/sippycup|r",

	--/ Popup dialog /--
	POPUP_ON_COOLDOWN_TEXT = "En tiempo de espera",
	POPUP_IN_FLIGHT_TEXT = "Desactivado para evitar el desmontaje durante el vuelo.",
	POPUP_NOT_IN_PARTY_TEXT = "Disabled as item requires a party.", -- (NEW)
	POPUP_FOOD_BUFF_TEXT = "Desaparece una vez que se aplica el beneficio de comida. ¡No te muevas!",
	POPUP_NOT_IN_INVENTORY_TEXT = "No hay en el inventario",
	POPUP_NOT_ENOUGH_IN_INVENTORY_TEXT = "No es suficiente (%d Faltante)",
	POPUP_INSUFFICIENT_NEXT_REFRESH_TEXT = "insuficiente (%d / %d) para la próxima actualización.",
	POPUP_LOW_STACK_COUNT_TEXT = "¡Poca cantidad de stacks!",
	POPUP_NOT_ACTIVE_TEXT = "¡No está activo!",
	POPUP_EXPIRING_SOON_TEXT = "¡Expira pronto!",
	POPUP_IGNORE_TT = "Bloquea los recordatorios para este consumible/juguete hasta tu próxima sesión.",
	POPUP_LINK = "|n|nPresiona |cnGREEN_FONT_COLOR:CTRL-C|r para copiar lo resaltado, luego pégalo en tu navegador web con |cnGREEN_FONT_COLOR:CTRL-V|r.",
	COPY_SYSTEM_MESSAGE = "Copiado al portapapeles.",
	POPUP_RELOAD_TITLE = "Reiniciar interfaz",
	POPUP_RELOAD_WARNING = "¿Reiniciar la interfaz ahora para aplicar los cambios?",

	--/ Options /--

	-- General options
	OPTIONS_GENERAL_HEADER = "General",
	OPTIONS_GENERAL_WELCOME_NAME = "Mensaje de inicio",
	OPTIONS_GENERAL_WELCOME_DESC = "Activa o desactiva la visualización del mensaje de bienvenida.",
	OPTIONS_GENERAL_MINIMAPBUTTON_NAME = "Botón del minimapa",
	OPTIONS_GENERAL_MINIMAPBUTTON_DESC = "Activa o desactiva la visualización del botón del minimapa.",
	OPTIONS_GENERAL_ADDONCOMPARTMENT_NAME = "Compartimento adicional",
	OPTIONS_GENERAL_ADDONCOMPARTMENT_DESC = "Activa o desactiva la visualización del botón del compartimento adicional.",
	OPTIONS_GENERAL_NEW_FEATURE_NOTIFICATION_NAME = "Nuevo indicador",
	OPTIONS_GENERAL_NEW_FEATURE_NOTIFICATION_DESC = "Activa o desactiva la indicación de nuevas funciones mediante un icono.|n|nEl icono permanecerá hasta la próxima versión menor; por ejemplo, una característica añadida en la versión 0.6.1 mantendrá su indicador hasta la versión 0.7.0.|n|n|cnWARNING_FONT_COLOR:Esta opción requiere que se reinicie la interfaz de usuario para que surta efecto.|r",

	OPTIONS_GENERAL_POPUPS_HEADER = "Ventanas emergentes de recordatorio",
	OPTIONS_GENERAL_POPUPS_POSITION_NAME = "Posición",
	OPTIONS_GENERAL_POPUPS_POSITION_DESC = "Selecciona dónde aparecerán las ventanas emergentes de recordatorio en tu pantalla.",
	OPTIONS_GENERAL_POPUPS_POSITION_TOP = "Arriba (Default)",
	OPTIONS_GENERAL_POPUPS_POSITION_CENTER = "Medio",
	OPTIONS_GENERAL_POPUPS_POSITION_BOTTOM = "Abajo",
	OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE = "Recordatorio pre-expiración",
	OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE_DESC = "Activa o desactiva la visualización de recordatorios poco antes de que el consumible/juguete expire.|n|n|cnWARNING_FONT_COLOR:No todas las opciones admiten esta función; consulta la información sobre herramientas cuando esté habilitada.|r",
	OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_LEAD_TIMER = "Tiempo previo a la expiración",
	OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_LEAD_TIMER_TEXT = "Establece el tiempo deseado, en minutos, antes de que se muestre la ventana emergente de recordatorio de pre-expiración (por defecto: 1 minuto).|n|n|cnWARNING_FONT_COLOR:Si una opción no admite el tiempo elegido, el valor predeterminado será 1 minuto, o 15 segundos si no se admite 1 minuto.|r",
	OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE = "Recordatorio insuficiente",
	OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE_DESC = "Activa o desactiva la visualización de una ventana emergente cuando no hay suficiente cantidad para la siguiente actualización.",
	OPTIONS_GENERAL_POPUPS_TRACK_TOY_ITEM_CD_ENABLE = "Usar tiempo de reutilización",
	OPTIONS_GENERAL_POPUPS_TRACK_TOY_ITEM_CD_ENABLE_DESC = "Activa o desactiva el seguimiento de los tiempos de reutilización del juguete desde el propio juguete en lugar de desde su efecto, asegurandose de que la ventana emergente solo aparezca cuando se pueda utilizar el juguete.|n|n|cnWARNING_FONT_COLOR:Esto solo afecta a los juguetes con 'Desajuste del tiempo de reutilización'.|r",
	OPTIONS_GENERAL_POPUPS_IGNORES = "Restablecer ventanas",
	OPTIONS_GENERAL_POPUPS_IGNORES_TEXT = "Restablece todas las ventanas emergentes de recordatorio ignoradas durante esta sesión, haciéndolas visibles de nuevo.",
	OPTIONS_GENERAL_POPUPS_ALERT_SOUND_DESC = "Elige el sonido que se reproducirá cuando aparezca una ventana emergente de recordatorio.",
	OPTIONS_GENERAL_POPUPS_SOUND_ENABLE_DESC = "Activa o desactiva la reproducción de un sonido cuando aparece una ventana emergente de recordatorio.",
	OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE = "Parpadeo",
	OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE_DESC = "Activa o desactiva el parpadeo de la barra de acción cuando aparece una ventana emergente de recordatorio.",
	OPTIONS_GENERAL_ADDONINTEGRATIONS_HEADER = "Integraciones de complementos",
	OPTIONS_GENERAL_MSP_STATUSCHECK_ENABLE = "Solamente \"En el personaje\"",
	OPTIONS_GENERAL_MSP_STATUSCHECK_DESC = "Muestra ventanas emergentes solo cuando tu personaje esté marcado como |cnGREEN_FONT_COLOR:En el personaje|r.|n|n|cnWARNING_FONT_COLOR:Requiere un complemento de perfil RP (e.g., TRP, MRP, XRP) para que funcione.|r",
	OPTIONS_GENERAL_ADDONINFO_HEADER = "Información sobre el complemento",
	OPTIONS_GENERAL_ADDONINFO_VERSION = "|cnNORMAL_FONT_COLOR:Versión:|r %s",
	OPTIONS_GENERAL_ADDONINFO_AUTHOR = "|cnNORMAL_FONT_COLOR:Autor:|r %s",
	OPTIONS_GENERAL_ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Build:|r %s",
	OPTIONS_GENERAL_ADDONINFO_BUILD_OUTDATED = title .. " no está optimizado para esta versión del juego.|n|n|cnWARNING_FONT_COLOR:Esto puede provocar un comportamiento inesperado.|r",
	OPTIONS_GENERAL_ADDONINFO_BUILD_CURRENT = title .. " está optimizado para esta versión del juego.|n|n|cnGREEN_FONT_COLOR:Todas las características deberían funcionar según lo previsto.|r",
	OPTIONS_GENERAL_BLUESKY_SHILL_DESC = "¡Sígueme en Bluesky!",

	-- Generic
	OPTIONS_SLIDER_TEXT = "Establezca el número de unidades deseado para |cnGREEN_FONT_COLOR:%s|r.|n|nLos recordatorios continuarán hasta que se alcance el número deseado de unidades.",
	OPTIONS_DESIRED_STACKS = "Unidades deseadas",
	OPTIONS_TITLE_EXTRA = "|n|nAl iniciar sesión, aparecerá una ventana emergente con los consumibles/juguetes rastreados con unidades activas. Si la opción 'Solo cuando \"En el personaje\"' está activada, también te recordará las unidades inactivas.",
	OPTIONS_LEGENDA_PRE_EXPIRATION_NAME = "Soporte previo a la expiración",
	OPTIONS_LEGENDA_PRE_EXPIRATION_DESC = "Este consumible/juguete admite recordatorios previos a la expiración y te avisará poco antes de que expire cuando la opción de recordatorio previo a la expiración esté activada.",
	OPTIONS_LEGENDA_NON_REFRESHABLE_NAME = "No renovable",
	OPTIONS_LEGENDA_NON_REFRESHABLE_DESC = "Renovar este consumible/juguete antes de tiempo desperdiciará el item sin renovar su efecto o temporizador.",
	OPTIONS_LEGENDA_STACKS_NAME = "Soporte para recuento de unidades",
	OPTIONS_LEGENDA_STACKS_DESC = "Este consumible/juguete permite establecer el número deseado de unidades y te avisará cuando tus unidades actuales estén por debajo de ese número.",
	OPTIONS_LEGENDA_NO_AURA_NAME = "Limitaciones de seguimiento",
	OPTIONS_LEGENDA_NO_AURA_DESC = "Este consumible/juguete es más difícil de rastrear y en ocasiones puede causar irregularidades.",
	OPTIONS_LEGENDA_COOLDOWN_NAME = "Desajuste del tiempo de reutilización",
	OPTIONS_LEGENDA_COOLDOWN_DESC = "Este consumible/juguete tiene un tiempo de reutilización más largo que la duración de su efecto, lo que puede provocar que aparezca una ventana emergente de recordatorio mientras el botón de actualización aún está en tiempo de reutilización.|n|n|cnWARNING_FONT_COLOR:Esto se puede mitigar activando 'Usar tiempo de reutilización de juguetes' en el menú General.|r",

	-- Appearance
	OPTIONS_TAB_APPEARANCE_TITLE = "Apariencia",
	OPTIONS_TAB_APPEARANCE_INSTRUCTION = "Estas opciones controlan todos los recordatorios para los consumibles/juguetes que alteran tu apariencia.",

	-- Effect
	OPTIONS_TAB_EFFECT_TITLE = "Efecto",
	OPTIONS_TAB_EFFECT_INSTRUCTION = "Estas opciones controlan todos los recordatorios para los consumibles/juguetes que aplican un efecto visual.",

	-- Handheld
	OPTIONS_TAB_HANDHELD_TITLE = "De mano",
	OPTIONS_TAB_HANDHELD_INSTRUCTION = "Estas opciones controlan todos los recordatorios para los consumibles/juguetes que hacen que tu personaje sostenga un objeto.",

	-- Placement
	OPTIONS_TAB_PLACEMENT_TITLE = "Colocación",
	OPTIONS_TAB_PLACEMENT_INSTRUCTION = "Estas opciones controlan todos los recordatorios para los consumibles/juguetes que se colocan en el suelo.",

	-- Prism
	OPTIONS_TAB_PRISM_TITLE = "Prismas",
	OPTIONS_TAB_PRISM_INSTRUCTION = "Estas opciones controlan todos los recordatorios para los consumibles/juguetes prismáticos que cambian tu apariencia.",
	OPTIONS_TAB_PRISM_TIMER = "%s - Timer", -- (NEW)
	OPTIONS_TAB_PRISM_TIMER_TEXT = "Set the desired time, in minutes, before the prism pre-expiration reminder popup should be shown (default: %d minutes).|n|n|cnWARNING_FONT_COLOR:If an option does not support the chosen time, it will default to %d minutes.|r", -- (NEW)

	-- Size
	OPTIONS_TAB_SIZE_TITLE = "Tamaño",
	OPTIONS_TAB_SIZE_INSTRUCTION = "Estas opciones controlan todos los recordatorios para los consumibles/juguetes que cambian el tamaño de tu personaje.",

	--/ Addon Compartment /--
	ADDON_COMPARTMENT_DESC = "|cnGREEN_FONT_COLOR:Click: abrir opciones|nClick derecho: abrir perfiles|r",

	-- Profiles
	OPTIONS_PROFILES_HEADER = "Perfiles",
	OPTIONS_PROFILES_INSTRUCTION = "Los ajustes de la pestaña General son globales, mientras que todos los ajustes de consumibles/juguetes son específicos del perfil.",
	OPTIONS_PROFILES_RESETBUTTON_NAME = "Restablecer perfil",
	OPTIONS_PROFILES_RESETBUTTON_DESC = "Restablece el perfil actual a su configuración predeterminada.",
	OPTIONS_PROFILES_CURRENTPROFILE = "Perfil actual: %s",
	OPTIONS_PROFILES_EXISTINGPROFILES_NAME = "Perfiles existentes",
	OPTIONS_PROFILES_EXISTINGPROFILES_DESC = "Selecciona uno de tus perfiles disponibles.",
	OPTIONS_PROFILES_NEWPROFILE_NAME = "Nuevo perfil",
	OPTIONS_PROFILES_NEWPROFILE_DESC = "Introduce un nombre para el nuevo perfil y presiona Enter.",
	OPTIONS_PROFILES_COPYFROM_NAME = "Copiar desde",
	OPTIONS_PROFILES_COPYFROM_DESC = "Copia la configuración del perfil seleccionado en tu perfil actual.",
	OPTIONS_PROFILES_DELETEPROFILE_NAME = "Eliminar perfil",
	OPTIONS_PROFILES_DELETEPROFILE_DESC = "Elimina el perfil seleccionado de la base de datos.",
};

SIPPYCUP.L_ESES = L;
