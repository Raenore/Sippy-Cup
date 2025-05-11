-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local title = C_AddOns.GetAddOnMetadata("SippyCup", "Title");
local L = LibStub("AceLocale-3.0"):NewLocale("SippyCup", "frFR", false);
if not L then return; end

--/ Welcome message /--
L.WELCOMEMSG_VERSION = "Préparé à la saveur |cnGREEN_FONT_COLOR:%s|r!";
L.WELCOMEMSG_OPTIONS = "Options accessibles via |cnGREEN_FONT_COLOR:/sc|r ou |cnGREEN_FONT_COLOR:/sippycup|r.";

--/ Consumable names /--
L.ARCHIVISTS_CODEX = "Codex des archivistes";
L.ASHEN_LINIMENT = "Liniment cendreux";
L.DARKMOON_FIREWATER = "Eau-de-feu de Sombrelune";
L.ELIXIR_OF_GIANT_GROWTH = "Élixir de taille de géant";
L.ELIXIR_OF_TONGUES = "Élixir des langages";
L.FIREWATER_SORBET = "Sorbet d'eau-de-feu";
L.FLICKERING_FLAME_HOLDER = "Support de flamme vacillante";
L.GIGANTIC_FEAST = "Festin gigantesque";
L.INKY_BLACK_POTION = "Potion noire comme de l'encre";
L.NOGGENFOGGER_SELECT_DOWN = "Sélection rétrécissante de Brouillecaboche";
L.NOGGENFOGGER_SELECT_UP = "Sélection grandissante de Brouillecaboche";
L.PROVIS_WAX = "Cire de Provis";
L.PYGMY_OIL = "Huile de pygmée";
L.RADIANT_FOCUS = "Concentration rayonnante";
L.SACREDITES_LEDGER = "Registre de sacrédit";
L.SMALL_FEAST = "Petit festin";
L.SPARKBUG_JAR = "Jarre de lumiptères";
L.STINKY_BRIGHT_POTION = "Potion lumineuse puante";
L.SUNGLOW = "Soléclat";
L.TATTERED_ARATHI_PRAYER_SCROLL = "Parchemin de prière arathi en lambeaux";
L.WINTERFALL_FIREWATER = "Eau-de-feu des Tombe-hiver";

--/ Popup dialog /--
L.POPUP_ITEM_NAME = "|cnGREEN_FONT_COLOR:%s|r ";
L.POPUP_ITEM_ICON = "|TInterface\\Icons\\%s:%d|t |cnGREEN_FONT_COLOR:%s|r|n|n";

L.POPUP_LACKING_TEXT = "introuvable dans votre inventaire.";
L.POPUP_TEXT = "en-dessous du nombre de stacks voulus!";
L.POPUP_IGNORE_TT = IGNORE .. "|r |cnWHITE_FONT_COLOR:bloque les rappels jusqu'à la prochaine session.|r";

L.POPUP_BUTTON_REFRESH = REFRESH .. " (%dx)";
L.POPUP_LINK = "|n|nAppuyez sur |cnGREEN_FONT_COLOR:CTRL-C|r pour copier le texte surligné, puis copiez dans votre navigateur avec |cnGREEN_FONT_COLOR:CTRL-V|r.";
L.COPY_SYSTEM_MESSAGE = "Copié dans le presse-papiers.";

--/ Options /--

-- General options
L.OPTIONS_GENERAL_WELCOME_NAME = "Message au démarrage";
L.OPTIONS_GENERAL_WELCOME_DESC = "Affiche ou cache le message d'accueil.";
L.OPTIONS_GENERAL_MINIMAPBUTTON_NAME = "Bouton minicarte";
L.OPTIONS_GENERAL_MINIMAPBUTTON_DESC = "Affiche ou cache le bouton de la minicarte.";
L.OPTIONS_GENERAL_ADDONCOMPARTMENT_NAME = "Compartiment d'addon";
L.OPTIONS_GENERAL_ADDONCOMPARTMENT_DESC = "Affiche ou cache le bouton dans le compartiment d'addon.";

L.OPTIONS_GENERAL_POPUPS_HEADER = "Fenêtre de rappel";
L.OPTIONS_GENERAL_POPUPS_POSITION_NAME = "Position";
L.OPTIONS_GENERAL_POPUPS_POSITION_DESC = "Sélectionne où vous souhaitez que les fenêtres de rappel s'affichent sur votre écran.";
L.OPTIONS_GENERAL_POPUPS_ICON_ENABLE = "Icône";
L.OPTIONS_GENERAL_POPUPS_ICON_ENABLE_DESC = "Affiche ou cache l'icône du consommable dans la fenêtre de rappel.|n|n|cnWARNING_FONT_COLOR:Gardez en tête que l'activation de cette option augmente la hauteur de la fenêtre.|r";
L.OPTIONS_GENERAL_POPUPS_IGNORES = "Réinitialiser fenêtres ignorées";
L.OPTIONS_GENERAL_POPUPS_IGNORES_TEXT = "Réinitialise toutes les fenêtres de rappel ignorées durant cette session afin qu'elles soient à nouveau visibles.";
L.OPTIONS_GENERAL_POPUPS_ALERT_SOUND = SOUND;
L.OPTIONS_GENERAL_POPUPS_ALERT_SOUND_DESC = "Choisit quel son est joué lorsque la fenêtre de rappel est affichée.";
L.OPTIONS_GENERAL_POPUPS_SOUND_ENABLE = BINDING_NAME_TOGGLESOUND;
L.OPTIONS_GENERAL_POPUPS_SOUND_ENABLE_DESC = "Active ou désactive si un son est joué lorsque la fenêtre de rappel est affichée.";
L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE = "Flash barre des tâches";
L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE_DESC = "Active ou désactive le flash sur la barre des tâches lorsque la fenêtre de rappel est affichée.";


L.OPTIONS_GENERAL_ADDONINFO_HEADER = "Info de l'addon";
L.OPTIONS_GENERAL_ADDONINFO_VERSION = "|cnNORMAL_FONT_COLOR:Version :|r %s";
L.OPTIONS_GENERAL_ADDONINFO_AUTHOR = "|cnNORMAL_FONT_COLOR:Auteur :|r %s";
L.OPTIONS_GENERAL_ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Build :|r %s";
L.OPTIONS_GENERAL_ADDONINFO_BUILD_OUTDATED = title .. " n'est pas optimisé pour cette version du jeu.|n|n|cnWARNING_FONT_COLOR:Si vous rencontrez un comportement inattendu, ceci peut en être la cause.|r";
L.OPTIONS_GENERAL_ADDONINFO_BUILD_CURRENT = title .. " est optimisé pour la version du jeu actuelle.|n|n|cnGREEN_FONT_COLOR:Tout devrait fonctionner comme prévu.|r";
L.OPTIONS_GENERAL_BLUESKY_SHILL_DESC = "Suivez-moi sur Bluesky!";

-- Generic
L.OPTIONS_ENABLE_TEXT = "Active les rappels de consommable pour |cnGREEN_FONT_COLOR:%s|r.";
L.OPTIONS_SLIDER_TEXT = "Définit le nombre de stacks désirés pour |cnGREEN_FONT_COLOR:%s|r.|n|nLes rappels continueront de s'afficher jusqu'à ce que le nombre de stacks désirés soit atteint.";
L.OPTIONS_DESIRED_STACKS = "|cnWHITE_FONT_COLOR:Stacks désirés|r";
L.OPTIONS_TITLE_EXTRA = "|n|nNote : Au login, seuls les consommables qui ont des stacks actifs inférieurs au nombre désiré afficheront une fenêtre de rappel.";

-- Effect
L.OPTIONS_CONSUMABLE_EFFECT_TITLE = "Effet";
L.OPTIONS_CONSUMABLE_EFFECT_INSTRUCTION = "Ces options contrôlent tous les rappels pour les consommables qui ont un effet.";

-- Size
L.OPTIONS_CONSUMABLE_SIZE_TITLE = "Taille";
L.OPTIONS_CONSUMABLE_SIZE_INSTRUCTION = "Ces options contrôlent tous les rappels pour les consommables qui changent la taille d'un personnage.";

--/ Addon Compartment /--
L.ADDON_COMPARTMENT_DESC = "|cnGREEN_FONT_COLOR:Clic gauche : Ouvrir les options|nClic droit : Ouvrir les profils|r";
