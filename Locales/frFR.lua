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
	POPUP_ON_COOLDOWN_TEXT = "En recharge",
	POPUP_IN_FLIGHT_TEXT = "Désactivé pour ne pas tomber de la monture durant le vol.",
	POPUP_FOOD_BUFF_TEXT = "Disappears once food buff is applied. Do not move!", -- (NEW)
	POPUP_NOT_IN_INVENTORY_TEXT = "Pas dans l'inventaire",
	POPUP_NOT_ENOUGH_IN_INVENTORY_TEXT = "Insuffisant (%d manquant)",
	POPUP_INSUFFICIENT_NEXT_REFRESH_TEXT = "Insuffisant (%d / %d) pour le prochain rafraîchissement.",
	POPUP_LOW_STACK_COUNT_TEXT = "Faible nombre de stacks !",
	POPUP_NOT_ACTIVE_TEXT = "Inactif !",
	POPUP_EXPIRING_SOON_TEXT = "Expire bientôt !",
	POPUP_IGNORE_TT = "Bloque les rappels pour ce consommable jusqu'à la prochaine session.",
	POPUP_LINK = "|n|nAppuyez sur |cnGREEN_FONT_COLOR:CTRL-C|r pour copier le texte surligné, puis copiez dans votre navigateur avec |cnGREEN_FONT_COLOR:CTRL-V|r.",
	COPY_SYSTEM_MESSAGE = "Copié dans le presse-papiers.",

	--/ Options /--

	-- General options
	OPTIONS_GENERAL_HEADER = "Général",
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
	OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE_DESC = "Active l'affichage des rappels pré-expiration juste avant que le consommable expire.|n|n|cnWARNING_FONT_COLOR:Tous les objets ne supportent pas cette option; voir l'infobulle quand activé.|r",
	OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE = "Rappel insuffisant",
	OPTIONS_GENERAL_POPUPS_INSUFFICIENT_REMINDER_ENABLE_DESC = "Active l'affichage d'un rappel lorsque la quantité de consommables est insuffisante pour le prochain rafraîchissement.",
	OPTIONS_GENERAL_POPUPS_IGNORES = "Réinitialiser fenêtres ignorées",
	OPTIONS_GENERAL_POPUPS_IGNORES_TEXT = "Réinitialise toutes les fenêtres de rappel ignorées durant cette session, les rendant à nouveau visibles.",
	OPTIONS_GENERAL_POPUPS_ALERT_SOUND_DESC = "Choisit quel son est joué lorsque la fenêtre de rappel est affichée.",
	OPTIONS_GENERAL_POPUPS_SOUND_ENABLE_DESC = "Active ou désactive si un son est joué lorsque la fenêtre de rappel est affichée.",
	OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE = "Flash barre des tâches",
	OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE_DESC = "Active ou désactive le flash sur la barre des tâches lorsque la fenêtre de rappel est affichée.",

	OPTIONS_GENERAL_ADDONINTEGRATIONS_HEADER = "Intégrations addon",
	OPTIONS_GENERAL_MSP_STATUSCHECK_ENABLE = "Seulement quand le personnage est joué",
	OPTIONS_GENERAL_MSP_STATUSCHECK_DESC = "N'affiche les fenêtres de rappel que lorsque votre personnage est indiqué comme |cnGREEN_FONT_COLOR:joué|r.|n|n|cnWARNING_FONT_COLOR:Ceci nécessite qu'un addon de profil RP (e.g., TRP, MRP, XRP) soit actif.|r",

	OPTIONS_GENERAL_ADDONINFO_HEADER = "Info de l'addon",
	OPTIONS_GENERAL_ADDONINFO_VERSION = "|cnNORMAL_FONT_COLOR:Version :|r %s",
	OPTIONS_GENERAL_ADDONINFO_AUTHOR = "|cnNORMAL_FONT_COLOR:Auteur :|r %s",
	OPTIONS_GENERAL_ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Build :|r %s",
	OPTIONS_GENERAL_ADDONINFO_BUILD_OUTDATED = title .. " n'est pas optimisé pour cette version du jeu.|n|n|cnWARNING_FONT_COLOR:Ceci peut causer des comportements inattendus.|r",
	OPTIONS_GENERAL_ADDONINFO_BUILD_CURRENT = title .. " est optimisé pour la version du jeu actuelle.|n|n|cnGREEN_FONT_COLOR:Toutes les fonctionnalités devraient fonctionner comme prévu.|r",
	OPTIONS_GENERAL_BLUESKY_SHILL_DESC = "Suivez-moi sur Bluesky!",

	-- Generic
	OPTIONS_SLIDER_TEXT = "Définit le nombre de stacks désirés pour |cnGREEN_FONT_COLOR:%s|r.|n|nLes rappels continueront de s'afficher jusqu'à ce que le nombre de stacks désirés soit atteint.",
	OPTIONS_DESIRED_STACKS = "Stacks désirés",
	OPTIONS_TITLE_EXTRA = "|n|nNote : Au login, une fenêtre apparaîtra pour les consommables suivis avec des stacks actifs. Si l'option \"Seulement quand le personnage est joué\" est activée, elle vous rappelera aussi pour les stacks inactifs.",
	OPTIONS_LEGENDA_PRE_EXPIRATION_NAME = "Gestion pré-expiration",
	OPTIONS_LEGENDA_PRE_EXPIRATION_DESC = "Ce consommable supporte les rappels pré-expiration et vous notifiera juste avant qu'il expire si l'option de rappel pré-expiration est activée.",
	OPTIONS_LEGENDA_NON_REFRESHABLE_NAME = "Non-rafraîchissable",
	OPTIONS_LEGENDA_NON_REFRESHABLE_DESC = "Rafraîchir ce consommable trop tôt le gaspille sans renouveler l'effet ou la durée.",
	OPTIONS_LEGENDA_STACKS_NAME = "Gestion nombre de stacks",
	OPTIONS_LEGENDA_STACKS_DESC = "Ce consommable supporte la définition d'un nombre de stacks désirés et vous rappelera lorsque vos stacks actuels sont en-dessous de ce nombre.",
	OPTIONS_LEGENDA_NO_AURA_NAME = "Limitations du suivi",
	OPTIONS_LEGENDA_NO_AURA_DESC = "Ce consommable est plus difficile à suivre et peut occasionnellement causer des irrégularités.",

	-- Appearance
	OPTIONS_CONSUMABLE_APPEARANCE_TITLE = "Apparence",
	OPTIONS_CONSUMABLE_APPEARANCE_INSTRUCTION = "Ces options contrôlent tous les rappels pour les consommables qui altèrent votre apparence.",

	-- Effect
	OPTIONS_CONSUMABLE_EFFECT_TITLE = "Effet",
	OPTIONS_CONSUMABLE_EFFECT_INSTRUCTION = "Ces options contrôlent tous les rappels pour les consommables qui appliquent un effet visuel.",

	-- Handheld
	OPTIONS_CONSUMABLE_HANDHELD_TITLE = "En main",
	OPTIONS_CONSUMABLE_HANDHELD_INSTRUCTION = "Ces options contrôlent tous les rappels pour les consommables qui font porter un objet à votre personnage.",

	-- Placement
	OPTIONS_CONSUMABLE_PLACEMENT_TITLE = "Placement",
	OPTIONS_CONSUMABLE_PLACEMENT_INSTRUCTION = "Ces options contrôlent tous les rappels pour les consommables qui sont placés au sol.",

	-- Prism
	OPTIONS_CONSUMABLE_PRISM_TITLE = "Prisme",
	OPTIONS_CONSUMABLE_PRISM_INSTRUCTION = "Ces options contrôlent tous les rappels pour les prismes consommables qui altèrent votre apparence.",

	-- Size
	OPTIONS_CONSUMABLE_SIZE_TITLE = "Taille",
	OPTIONS_CONSUMABLE_SIZE_INSTRUCTION = "Ces options contrôlent tous les rappels pour les consommables qui changent la taille de votre personnage.",

	--/ Addon Compartment /--
	ADDON_COMPARTMENT_DESC = "|cnGREEN_FONT_COLOR:Clic gauche : Ouvrir les options|nClic droit : Ouvrir les profils|r",

	-- Profiles
	OPTIONS_PROFILES_HEADER = "Profils",
	OPTIONS_PROFILES_INSTRUCTION = "Les paramètres dans l'onglet Général sont globaux, tandis que les paramètres de consommables sont spécifiques au profil.",
	OPTIONS_PROFILES_RESETBUTTON_NAME = "Réinitialiser profil",
	OPTIONS_PROFILES_RESETBUTTON_DESC = "Réinitialise le profil actuel avec les paramètres par défaut.",
	OPTIONS_PROFILES_CURRENTPROFILE = "Profil actuel : %s",
	OPTIONS_PROFILES_EXISTINGPROFILES_NAME = "Profils existants",
	OPTIONS_PROFILES_EXISTINGPROFILES_DESC = "Sélectionne un de vos profils disponibles.",
	OPTIONS_PROFILES_NEWPROFILE_NAME = "Nouveau profil",
	OPTIONS_PROFILES_NEWPROFILE_DESC = "Entrez un nom pour le nouveau profil et appuyez sur Entrée.",
	OPTIONS_PROFILES_COPYFROM_NAME = "Copier depuis",
	OPTIONS_PROFILES_COPYFROM_DESC = "Copie les paramètres du profil sélectionné dans votre profil actuel.",
	OPTIONS_PROFILES_DELETEPROFILE_NAME = "Supprimer profil",
	OPTIONS_PROFILES_DELETEPROFILE_DESC = "Supprime le profil sélectionné de la base de données.",
};

SIPPYCUP.L_FRFR = L;
