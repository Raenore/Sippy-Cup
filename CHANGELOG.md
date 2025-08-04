# Changelog

All notable changes to this project will be documented in this file.

## [0.3.0] - 2025-08-xx

### Added
- New config/settings page built from scratch, tailored to the addon's needs (see [#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Fully rewritten custom popup system replacing StaticPopups (tentatively called FlexiblePopups) (see [#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- "Insufficient Reminder": Shows a popup when the user lacks enough of a tracked consumable to meet the desired stack count for the next refresh (see [#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Flyway-style database patching system to safely rename and invalidate outdated SavedVariables (see [#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Popups now support a "Bottom" position and will stack upward instead of downward (see [#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Initial support for prism-type consumables (Reflecting Prism, Projection Prism) (see [#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Popup icons now show tooltips on hover, including support for count addons to quickly check item counts (see [#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Added multi-build support, allowing the addon to parse multiple client flavors and versions for compatibility (see [#34](https://github.com/Raenore/Sippy-Cup/pull/34)).

### Changed
- Update TOC for 11.2.0 (see [#32](https://github.com/Raenore/Sippy-Cup/pull/32)).
- Optimized MSP integration with no user-facing changes (see [#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Item names are now fetched from the game instead of locale files, enabling automatic localization in all languages (see [#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Sound alerts are now throttled to avoid spamming when multiple popups trigger at the same time (see [#31](https://github.com/Raenore/Sippy-Cup/pull/31)).

### Fixed
- Fixed an issue caused by Blizzard renaming `editBox` to `EditBox` (fixed in [#32](https://github.com/Raenore/Sippy-Cup/pull/32)).

### Removed
- Removed the popup icon toggle option, since new custom popups always show the item icon (see [#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Removed multiple workarounds related to StaticPopups, including handling the Main Menu logout button and the ElvUI AFK screen (see [#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Removed Ace3 libraries and implemented custom alternatives, reducing the addon size 'significantly' (see [#31](https://github.com/Raenore/Sippy-Cup/pull/31)).

## [0.2.2] - 2025-06-24

### Fixed
- Fixed an issue regarding aura changes during loading screens (fixed in [#29](https://github.com/Raenore/Sippy-Cup/pull/29)).
- Fixed rebuilding the AuraMap not checking instanceIDs thoroughly enough (fixed in [#29](https://github.com/Raenore/Sippy-Cup/pull/29)).
- Fixed the MismatchDB check not accounting for changed instanceIDs on some zone changes (fixed in [#29](https://github.com/Raenore/Sippy-Cup/pull/29)).

## [0.2.1] - 2025-06-23

### Added
- Allow pre-expiration reminders for some stackable consumables when they are at max stack (see [#27](https://github.com/Raenore/Sippy-Cup/pull/27)).

## [0.2.0] - 2025-06-23

### Added
- Added pre-expiration reminders for consumables to alert users before consumables expire (see [#25](https://github.com/Raenore/Sippy-Cup/pull/25)).
- Support for non-trackable consumables, allowing reminders to be used for non-aura items (see [#25](https://github.com/Raenore/Sippy-Cup/pull/25)).
- MSP fix-up regarding toggling OOC/IC and some incorrect edge cases (see [#25](https://github.com/Raenore/Sippy-Cup/pull/25)).
- Various enhancements to the consumable reminder and tracking system (see [#25](https://github.com/Raenore/Sippy-Cup/pull/25)).

### Changed
- Update TOC for 11.1.7.

### Fixed
- Fixed an issue in the Russian translation where the `IGNORE` GlobalString was mistakenly translated as well (fixed in [#23](https://github.com/Raenore/Sippy-Cup/pull/23)).

## [0.1.2] - 2025-06-06

### Added
- Russian translation added thanks to [Hubbotu](https://github.com/Hubbotu), with proofreading by Lord_Papalus and another anonymous user on Discord (see [#21](https://github.com/Raenore/Sippy-Cup/pull/21) and [#22](https://github.com/Raenore/Sippy-Cup/pull/22)).

### Fixed
- Fixed some errors in regards to the "In Character" integration not properly firing when it should (fixed in [#19](https://github.com/Raenore/Sippy-Cup/pull/19)).

## [0.1.1] - 2025-06-05

### Added
- Added an option to display consumable popups only when you are flagged as “In Character” by a RP Profile addon (e.g., TRP, MRP, XRP). (see [#17](https://github.com/Raenore/Sippy-Cup/pull/17))
- When a user goes "In Character", Sippy Cup will do a full check and show a popup for all enabled consumables that are either missing or the wrong stack count. (see [#18](https://github.com/Raenore/Sippy-Cup/pull/18))

### Fixed
- Fixed an error where attempting to log out via the Main Menu, `/camp`, `/logout`, etc., would cause an error if a Sippy Cup popup was present (fixed in [#13](https://github.com/Raenore/Sippy-Cup/pull/13)).
- Fixed the Pause MisMatch timer check so that it is paused during loading screens, preventing false consumable removals when teleporting (fixed in [#14](https://github.com/Raenore/Sippy-Cup/pull/14)).

## [0.1.0] - 2025-05-31

### Added
- The whole project.
