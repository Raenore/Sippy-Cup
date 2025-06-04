# Changelog

All notable changes to this project will be documented in this file.

## [0.1.1] - 2025-06-xx

### Added
- Added an option to display consumable popups only when you are flagged as “In Character” by a RP Profile addon (e.g., TRP, MRP, XRP). (see [#17](https://github.com/Raenore/Sippy-Cup/pull/17))
- When a user goes "In Character", Sippy Cup will do a full check and show a popup for all enabled consumables that are either missing or the wrong stack count. (see [#18](https://github.com/Raenore/Sippy-Cup/pull/18))

### Fixed
- Fixed an error where attempting to log out via the Main Menu, `/camp`, `/logout`, etc., would cause an error if a Sippy Cup popup was present (fixed in [#13](https://github.com/Raenore/Sippy-Cup/pull/13)).
- Fixed the Pause MisMatch timer check so that it is paused during loading screens, preventing false consumable removals when teleporting (fixed in [#14](https://github.com/Raenore/Sippy-Cup/pull/14)).

## [0.1.0] - 2025-05-31

### Added
- The whole project.
