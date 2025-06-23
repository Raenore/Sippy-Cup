# Changelog

All notable changes to this project will be documented in this file.

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
