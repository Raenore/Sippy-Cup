# Changelog

All notable changes to this project will be documented in this file.

## [0.3.0] - 2025-08-xx
This version might as well be a 1.0 release, as everything has been touched and reworked from the ground up.

### Added
- New config/settings page built from scratch, tailored to the addon's needs ([#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Fully rewritten custom popup system replacing StaticPopups, tentatively named *FlexiblePopups* ([#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- **Insufficient Reminder**: Shows a popup when the user lacks enough of a tracked consumable to meet the desired stack count for the next refresh ([#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Flyway-style database patching system to safely rename and invalidate outdated SavedVariables ([#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Popups now support a **Bottom** position and will stack upward instead of downward ([#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Initial support for **Prism-type** consumables (e.g., Reflecting Prism, Projection Prism) ([#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Popup icons now show tooltips on hover, with support for count addons to quickly check item quantities ([#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Added multi-build support, allowing the addon to parse multiple client flavors and versions for compatibility ([#34](https://github.com/Raenore/Sippy-Cup/pull/34)).

### Changed
- Updated TOC for Patch 11.2.0 ([#32](https://github.com/Raenore/Sippy-Cup/pull/32)).
- Optimized MSP integration with no user-facing changes ([#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Item names are now fetched directly from the game instead of being hard-coded into the addon files, enabling automatic localization in all supported languages ([#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Sound alerts are now throttled to prevent spam when multiple popups trigger at once ([#31](https://github.com/Raenore/Sippy-Cup/pull/31)).

### Fixed
- Addressed an issue caused by Blizzard renaming `editBox` to `EditBox` ([#32](https://github.com/Raenore/Sippy-Cup/pull/32)).

### Removed
- Removed the popup icon toggle option, as new custom popups always display the item icon ([#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Removed several workarounds related to StaticPopups, including those for the Main Menu logout button and ElvUI’s AFK screen ([#31](https://github.com/Raenore/Sippy-Cup/pull/31)).
- Removed Ace3 libraries and implemented lightweight custom alternatives, reducing the addon's size significantly ([#31](https://github.com/Raenore/Sippy-Cup/pull/31)).

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
