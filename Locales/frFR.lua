-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0
-- Traduction Solanya

local title = C_AddOns.GetAddOnMetadata("SippyCup", "Title");
local L;

L = {
	--/ Welcome message /--
	WELCOMEMSG_VERSION = "Préparé à la saveur |cnGREEN_FONT_COLOR:%s|r (|cnWHITE_FONT_COLOR:%s|r)!",
	WELCOMEMSG_OPTIONS = "Options accessibles via |cnGREEN_FONT_COLOR:/sc|r ou |cnGREEN_FONT_COLOR:/sippycup|r.",

	--/ Popup dialog /--
	POPUP_ON_COOLDOWN_TEXT = "actuellement en recharge.", -- (TEXT CHANGE IN ENGLISH)
	POPUP_IN_FLIGHT_TEXT = "Disabled to prevent dismount during flight.", -- (NEW)
	POPUP_NOT_IN_INVENTORY_TEXT = "introuvable dans votre inventaire.", -- (TEXT CHANGE IN ENGLISH)
	POPUP_NOT_ENOUGH_IN_INVENTORY_TEXT = "insuffisant dans votre inventaire.|n(%d manquant)", -- (TEXT CHANGE IN ENGLISH)
	POPUP_INSUFFICIENT_NEXT_REFRESH_TEXT = "insuffisant (%d / %d) pour le prochain rafraîchissement.", -- (TEXT CHANGE IN ENGLISH)
	POPUP_LOW_STACK_COUNT_TEXT = "en-dessous du nombre de stacks voulus !", -- (TEXT CHANGE IN ENGLISH)
	POPUP_NOT_ACTIVE_TEXT = "n'est pas actif !",
	POPUP_EXPIRING_SOON_TEXT = "expire bientôt !",
	POPUP_IGNORE_TT = "bloque les rappels jusqu'à la prochaine session.", -- (TEXT CHANGE IN ENGLISH)
	POPUP_LINK = "|n|nAppuyez sur |cnGREEN_FONT_COLOR:CTRL-C|r pour copier le texte surligné, puis copiez dans votre navigateur avec |cnGREEN_FONT_COLOR:CTRL-V|r.",
	COPY_SYSTEM_MESSAGE = "Copié dans le presse-papiers.",

	--/ Options /--

	-- General options
	OPTIONS_GENERAL_HEADER = "General", -- (NEW)
	OPTIONS_GENERAL_WELCOME_NAME = "Message au démarrage",
	OPTIONS_GENERAL_WELCOME_DESC = "Affiche ou cache le message d'accueil.",
	OPTIONS_GENERAL_MINIMAPBUTTON_NAME = "Bouton minicarte",
	OPTIONS_GENERAL_MINIMAPBUTTON_DESC = "Affiche ou cache le bouton de la minicarte.",
	OPTIONS_GENERAL_ADDONCOMPARTMENT_NAME = "Compartiment d'addon",
	OPTIONS_GENERAL_ADDONCOMPARTMENT_DESC = "Affiche ou cache le bouton dans le compartiment d'addon.",

	OPTIONS_GENERAL_POPUPS_HEADER = "Fenêtre de rappel",
	OPTIONS_GENERAL_POPUPS_POSITION_NAME = "Position",
	OPTIONS_GENERAL_POPUPS_POSITION_DESC = "Sélectionne où vous souhaitez que les fenêtres de rappel s'affichent sur votre écran.",
	OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE = "Rappel pré-expiration",
	OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE_DESC = "Active l'affiche des rappels pré-expiration lorsque le consommable est sur le point d'expirer.|n|n|cnWARNING_FONT_COLOR:Gardez en tête que tous les objets ne supportent pas cette option (le support est affiché dans l'infobulle d'activation du consommable).|r", -- (TEXT CHANGE IN ENGLISH)
	OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE = "Rappel insuffisant",
	OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE_DESC = "Active l'affichage d'un rappel lorsque la quantité de consommables est insuffisante pour le prochain rafraîchissement.",
	OPTIONS_GENERAL_POPUPS_IGNORES = "Réinitialiser fenêtres ignorées",
	OPTIONS_GENERAL_POPUPS_IGNORES_TEXT = "Réinitialise toutes les fenêtres de rappel ignorées durant cette session afin qu'elles soient à nouveau visibles.", -- (TEXT CHANGE IN ENGLISH)
	OPTIONS_GENERAL_POPUPS_ALERT_SOUND_DESC = "Choisit quel son est joué lorsque la fenêtre de rappel est affichée.", -- (TEXT CHANGE IN ENGLISH)
	OPTIONS_GENERAL_POPUPS_SOUND_ENABLE_DESC = "Active ou désactive si un son est joué lorsque la fenêtre de rappel est affichée.", -- (TEXT CHANGE IN ENGLISH)
	OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE = "Flash barre des tâches",
	OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE_DESC = "Active ou désactive le flash sur la barre des tâches lorsque la fenêtre de rappel est affichée.",

	OPTIONS_GENERAL_ADDONINTEGRATIONS_HEADER = "Intégrations addon",
	OPTIONS_GENERAL_MSP_STATUSCHECK_ENABLE = "Seulement quand le personnage est joué",
	OPTIONS_GENERAL_MSP_STATUSCHECK_DESC = "N'affiche les fenêtres de rappel que lorsque votre personnage est indiqué comme |cnGREEN_FONT_COLOR:joué|r.|n|n|cnWARNING_FONT_COLOR:Notez que ceci nécessite qu'un addon de profil RP (e.g., TRP, MRP, XRP) soit actif.|r", -- (TEXT CHANGE IN ENGLISH)

	OPTIONS_GENERAL_ADDONINFO_HEADER = "Info de l'addon",
	OPTIONS_GENERAL_ADDONINFO_VERSION = "|cnNORMAL_FONT_COLOR:Version :|r %s",
	OPTIONS_GENERAL_ADDONINFO_AUTHOR = "|cnNORMAL_FONT_COLOR:Auteur :|r %s",
	OPTIONS_GENERAL_ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Build :|r %s",
	OPTIONS_GENERAL_ADDONINFO_BUILD_OUTDATED = title .. " n'est pas optimisé pour cette version du jeu.|n|n|cnWARNING_FONT_COLOR:Si vous rencontrez un comportement inattendu, ceci peut en être la cause.|r", -- (TEXT CHANGE IN ENGLISH)
	OPTIONS_GENERAL_ADDONINFO_BUILD_CURRENT = title .. " est optimisé pour la version du jeu actuelle.|n|n|cnGREEN_FONT_COLOR:Tout devrait fonctionner comme prévu.|r", -- (TEXT CHANGE IN ENGLISH)
	OPTIONS_GENERAL_BLUESKY_SHILL_DESC = "Suivez-moi sur Bluesky!",

	-- Generic
	OPTIONS_SLIDER_TEXT = "Définit le nombre de stacks désirés pour |cnGREEN_FONT_COLOR:%s|r.|n|nLes rappels continueront de s'afficher jusqu'à ce que le nombre de stacks désirés soit atteint.",
	OPTIONS_DESIRED_STACKS = "Stacks désirés",
	OPTIONS_TITLE_EXTRA = "|n|nNote : Au login, seuls les consommables qui ont des stacks actifs inférieurs au nombre désiré afficheront une fenêtre de rappel.", -- (TEXT CHANGE IN ENGLISH)

	OPTIONS_LEGENDA_PRE_EXPIRATION_NAME = "Pre-Expiration Support", -- (NEW)
	OPTIONS_LEGENDA_PRE_EXPIRATION_DESC = "This consumable supports pre-expiration reminders and will notify you shortly before it expires when the pre-expiration reminder option is enabled.", -- (NEW)
	OPTIONS_LEGENDA_NON_REFRESHABLE_NAME = "Non-Refreshable", -- (NEW)
	OPTIONS_LEGENDA_NON_REFRESHABLE_DESC = "Refreshing this consumable early will waste the stack without renewing its effect or timer.", -- (NEW)
	OPTIONS_LEGENDA_STACKS_NAME = "Stack Count Support", -- (NEW)
	OPTIONS_LEGENDA_STACKS_DESC = "This consumable supports setting a desired stack count and will remind you when your current stacks are below that number.", -- (NEW)
	OPTIONS_LEGENDA_NO_AURA_NAME = "Tracking Limitations", -- (NEW)
	OPTIONS_LEGENDA_NO_AURA_DESC = "This consumable is harder to track and may occasionally cause irregularities.", -- (NEW)

	-- Appearance
	OPTIONS_CONSUMABLE_APPEARANCE_TITLE = "Apparence",
	OPTIONS_CONSUMABLE_APPEARANCE_INSTRUCTION = "Ces options contrôlent tous les rappels pour les consommables qui altèrent votre apparence.",

	-- Effect
	OPTIONS_CONSUMABLE_EFFECT_TITLE = "Effet",
	OPTIONS_CONSUMABLE_EFFECT_INSTRUCTION = "Ces options contrôlent tous les rappels pour les consommables qui ont un effet.", -- (TEXT CHANGE IN ENGLISH)

	-- Handheld
	OPTIONS_CONSUMABLE_HANDHELD_TITLE = "En main",
	OPTIONS_CONSUMABLE_HANDHELD_INSTRUCTION = "Ces options contrôlent tous les rappels pour les consommables qui font porter quelque chose à votre personnage.", -- (TEXT CHANGE IN ENGLISH)

	-- Placement
	OPTIONS_CONSUMABLE_PLACEMENT_TITLE = "Placement",
	OPTIONS_CONSUMABLE_PLACEMENT_INSTRUCTION = "Ces options contrôlent tous les rappels pour les consommables qui peuvent être placés au sol.", -- (TEXT CHANGE IN ENGLISH)

	-- Prism
	OPTIONS_CONSUMABLE_PRISM_TITLE = "Prisme",
	OPTIONS_CONSUMABLE_PRISM_INSTRUCTION = "Ces options contrôlent tous les rappels pour les prismes consommables qui altèrent votre apparence.",

	-- Size
	OPTIONS_CONSUMABLE_SIZE_TITLE = "Taille",
	OPTIONS_CONSUMABLE_SIZE_INSTRUCTION = "Ces options contrôlent tous les rappels pour les consommables qui changent la taille d'un personnage.", -- (TEXT CHANGE IN ENGLISH)

	--/ Addon Compartment /--
	ADDON_COMPARTMENT_DESC = "|cnGREEN_FONT_COLOR:Clic gauche : Ouvrir les options|nClic droit : Ouvrir les profils|r",

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

SIPPYCUP.L_FRFR = L;
