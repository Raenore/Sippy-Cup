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
L.BLUBBERY_MUFFIN = "Muffin onctueux";
L.COLLECTIBLE_PINEAPPLETINI_MUG = "Mug de jus d’ananas de collection";
L.DARKMOON_FIREWATER = "Eau-de-feu de Sombrelune";
L.DECORATIVE_YARD_FLAMINGO = "Flamant de décoration de jardin";
L.DISPOSABLE_HAMBURGER = "Hamburger jetable";
L.DISPOSABLE_HOTDOG = "Hotdog jetable";
L.ELIXIR_OF_GIANT_GROWTH = "Élixir de taille de géant";
L.ELIXIR_OF_TONGUES = "Élixir des langages";
L.ENCHANTED_DUST = "Poussière enchantée";
L.FIREWATER_SORBET = "Sorbet d'eau-de-feu";
L.FLEETING_SANDS = "Sables fugaces";
L.FLICKERING_FLAME_HOLDER = "Support de flamme vacillante";
L.GIGANTIC_FEAST = "Festin gigantesque";
L.GREEN_DANCE_STICK = "Bâton lumineux vert";
L.HALF_EATEN_TAKEOUT = "Plat à emporter à moitié mangé";
L.HOLY_CANDLE = "Bougie sanctifiée";
L.INKY_BLACK_POTION = "Potion noire comme de l'encre";
L.NOGGENFOGGER_SELECT_DOWN = "Sélection rétrécissante de Brouillecaboche";
L.NOGGENFOGGER_SELECT_UP = "Sélection grandissante de Brouillecaboche";
L.PROVIS_WAX = "Cire de Provis";
L.PURPLE_DANCE_STICK = "Bâton lumineux violet";
L.PYGMY_OIL = "Huile de pygmée";
L.QUICKSILVER_SANDS = "Sables vif-argent";
L.RADIANT_FOCUS = "Concentration rayonnante";
L.SACREDITES_LEDGER = "Registre de sacrédit";
L.SCROLL_OF_INNER_TRUTH = "Parchemin de vérité profonde";
L.SINGLE_USE_GRILL = "Grill à usage unique";
L.SMALL_FEAST = "Petit festin";
L.SNOW_IN_A_CONE = "Cornet de neige";
L.SPARKBUG_JAR = "Jarre de lumiptères";
L.STINKY_BRIGHT_POTION = "Potion lumineuse puante";
L.SUNGLOW = "Soléclat";
L.TATTERED_ARATHI_PRAYER_SCROLL = "Parchemin de prière arathi en lambeaux";
L.TEMPORALLY_LOCKED_SANDS = "Sables bloqués temporellement";
L.WEARY_SANDS = "Sables éreintés";
L.WINTERFALL_FIREWATER = "Eau-de-feu des Tombe-hiver";

--/ Popup dialog /--
L.POPUP_COOLDOWN_TEXT = "currently on cooldown."; -- NEW
L.POPUP_LACKING_TEXT = "introuvable dans votre inventaire.";
L.POPUP_LACKING_TEXT_AMOUNT = "insuffisant dans votre inventaire.";
L.POPUP_STACK_TEXT = "en-dessous du nombre de stacks voulus!";
L.POPUP_MISSING_TEXT = "is not active!"; -- NEW
L.POPUP_EXPIRING_SOON_TEXT = "is expiring soon!"; -- NEW
L.POPUP_IGNORE_TT = IGNORE .. "|r |cnWHITE_FONT_COLOR:bloque les rappels jusqu'à la prochaine session.|r";
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
L.OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE = "Pre-Expiration Reminder"; -- NEW
L.OPTIONS_GENERAL_POPUPS_PRE_EXPIRATION_CHECKS_ENABLE_DESC = "Toggles whether pre-expiration reminders should show close to the consumable expiring.|n|n|cnWARNING_FONT_COLOR:Keep in mind that not all items support this (it will be displayed on the enable tooltip).|r"; -- NEW
L.OPTIONS_GENERAL_POPUPS_IGNORES = "Réinitialiser fenêtres ignorées";
L.OPTIONS_GENERAL_POPUPS_IGNORES_TEXT = "Réinitialise toutes les fenêtres de rappel ignorées durant cette session afin qu'elles soient à nouveau visibles.";
L.OPTIONS_GENERAL_POPUPS_ALERT_SOUND_DESC = "Choisit quel son est joué lorsque la fenêtre de rappel est affichée.";
L.OPTIONS_GENERAL_POPUPS_SOUND_ENABLE_DESC = "Active ou désactive si un son est joué lorsque la fenêtre de rappel est affichée.";
L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE = "Flash barre des tâches";
L.OPTIONS_GENERAL_POPUPS_FLASHTASKBAR_ENABLE_DESC = "Active ou désactive le flash sur la barre des tâches lorsque la fenêtre de rappel est affichée.";

L.OPTIONS_GENERAL_ADDONINTEGRATIONS_HEADER = "Intégrations addon";
L.OPTIONS_GENERAL_MSP_STATUSCHECK_ENABLE = "Seulement quand le personnage est joué";
L.OPTIONS_GENERAL_MSP_STATUSCHECK_DESC = "N'affiche les fenêtres de rappel que lorsque votre personnage est indiqué comme |cnGREEN_FONT_COLOR:joué|r.|n|n|cnWARNING_FONT_COLOR:Notez que ceci nécessite qu'un addon de profil RP (e.g., TRP, MRP, XRP) soit actif.|r";

L.OPTIONS_GENERAL_ADDONINFO_HEADER = "Info de l'addon";
L.OPTIONS_GENERAL_ADDONINFO_VERSION = "|cnNORMAL_FONT_COLOR:Version :|r %s";
L.OPTIONS_GENERAL_ADDONINFO_AUTHOR = "|cnNORMAL_FONT_COLOR:Auteur :|r %s";
L.OPTIONS_GENERAL_ADDONINFO_BUILD = "|cnNORMAL_FONT_COLOR:Build :|r %s";
L.OPTIONS_GENERAL_ADDONINFO_BUILD_OUTDATED = title .. " n'est pas optimisé pour cette version du jeu.|n|n|cnWARNING_FONT_COLOR:Si vous rencontrez un comportement inattendu, ceci peut en être la cause.|r";
L.OPTIONS_GENERAL_ADDONINFO_BUILD_CURRENT = title .. " est optimisé pour la version du jeu actuelle.|n|n|cnGREEN_FONT_COLOR:Tout devrait fonctionner comme prévu.|r";
L.OPTIONS_GENERAL_BLUESKY_SHILL_DESC = "Suivez-moi sur Bluesky!";

-- Generic
L.OPTIONS_ENABLE_TEXT = "Active les rappels de consommable pour |cnGREEN_FONT_COLOR:%s|r.";
L.OPTIONS_ENABLE_PREXPIRE_TEXT = "|n|nNote that this consumable |cnGREEN_FONT_COLOR:supports pre-expiration reminders|r. When this feature is enabled, it will remind you close to it expiring."; -- NEW
L.OPTIONS_ENABLE_NON_REFRESHABLE_TEXT = "|n|n|cnWARNING_FONT_COLOR:Note that you should not refresh this consumable before it expires, as the stack will be lost without any effects.|r"; -- NEW
L.OPTIONS_ENABLE_NON_STACKABLE_TEXT = "|n|n|cnWARNING_FONT_COLOR:Note that this consumable is harder to track, resulting in possible irregularities from time to time.|r"; -- NEW
L.OPTIONS_SLIDER_TEXT = "Définit le nombre de stacks désirés pour |cnGREEN_FONT_COLOR:%s|r.|n|nLes rappels continueront de s'afficher jusqu'à ce que le nombre de stacks désirés soit atteint.";
L.OPTIONS_DESIRED_STACKS = "|cnWHITE_FONT_COLOR:Stacks désirés|r";
L.OPTIONS_TITLE_EXTRA = "|n|nNote : Au login, seuls les consommables qui ont des stacks actifs inférieurs au nombre désiré afficheront une fenêtre de rappel.";

-- Appearance
L.OPTIONS_CONSUMABLE_APPEARANCE_TITLE = "Appearance"; -- NEW
L.OPTIONS_CONSUMABLE_APPEARANCE_INSTRUCTION = "These options control all reminders for consumables that alter your appearance."; -- NEW

-- Effect
L.OPTIONS_CONSUMABLE_EFFECT_TITLE = "Effet";
L.OPTIONS_CONSUMABLE_EFFECT_INSTRUCTION = "Ces options contrôlent tous les rappels pour les consommables qui ont un effet.";

-- Handheld
L.OPTIONS_CONSUMABLE_HANDHELD_TITLE = "Handheld"; -- NEW
L.OPTIONS_CONSUMABLE_HANDHELD_INSTRUCTION = "These options control all reminders for consumables that make the character hold something."; -- NEW

-- Placement
L.OPTIONS_CONSUMABLE_PLACEMENT_TITLE = "Placement"; -- NEW
L.OPTIONS_CONSUMABLE_PLACEMENT_INSTRUCTION = "These options control all reminders for consumables that can be placed on the ground."; -- NEW

-- Size
L.OPTIONS_CONSUMABLE_SIZE_TITLE = "Taille";
L.OPTIONS_CONSUMABLE_SIZE_INSTRUCTION = "Ces options contrôlent tous les rappels pour les consommables qui changent la taille d'un personnage.";

--/ Addon Compartment /--
L.ADDON_COMPARTMENT_DESC = "|cnGREEN_FONT_COLOR:Clic gauche : Ouvrir les options|nClic droit : Ouvrir les profils|r";
