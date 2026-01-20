# Changelog

All notable changes to this project will be documented in this file.

## [0.6.0] - 2026-01-xx  
Major patch following the release of Midnight, which introduces addon restrictions and tighter limitations that mostly affect combat-related situations.   
Given that Sippy Cup never officially supported combat situations, these restrictions pose almost no true problems for the addon. However, there are some notable changes and additions in this release.  

### Added  
- Reminder popups that are active on your screen will disappear when combat starts and reappear once combat ends. ([#72](https://github.com/Raenore/Sippy-Cup/pull/72))  
- Initial Toys support! A large number of RP toys have been added to Sippy Cup. ([#72](https://github.com/Raenore/Sippy-Cup/pull/72))  
  - Toys tracking is more complex than consumables. If you encounter issues, please create an issue report on [the addon's GitHub page](https://github.com/Raenore/Sippy-Cup/issues).  
  - New "Use Toy Cooldown" option: Addresses the new "Cooldown Mismatch" situation introduced by toys. Some toys/consumables have a longer cooldown than their effect duration, which may trigger reminder popups prematurely. Enabling this option will have Sippy Cup check the item/toy itself and only trigger a reminder popup when it is available again (enabled by default).  
- Added a TRP toolbar button to quickly open the Sippy Cup options window. This button can be enabled or disabled through TRP’s Toolbar settings page. ([#75](https://github.com/Raenore/Sippy-Cup/pull/75))  
- Added a customizable **Pre-Expiration Lead Time** option, allowing users to define how long before the pre-expiration reminder popup should appear (default: 1 minute). ([#76](https://github.com/Raenore/Sippy-Cup/pull/76))  
  - If a consumable does not support the selected lead time, it will fall back to 1 minute, or 15 seconds if 1 minute is not supported.  

### Changed  
- If you add, update, or remove a consumable's count during combat, Sippy Cup will attempt to reconcile these changes after combat. There is a chance some changes may be missed due to combat restrictions, so keep this in mind when managing consumables during combat. ([#72](https://github.com/Raenore/Sippy-Cup/pull/72))  
- Settings page scrollbars (both Blizzard and ElvUI variants) have been updated to more modern and proper ones. ([#72](https://github.com/Raenore/Sippy-Cup/pull/72))  

### Fixed  
- Fixed a rare error related to missing reminder popup data. ([#78](https://github.com/Raenore/Sippy-Cup/pull/78))  

## [0.5.0] - 2025-08-25  
Major patch following the 0.4.0 internal optimizations, targeting further internal reworks and streamlining for performance.  

### Added  
- Added additional internal states to ensure Sippy Cup correctly tracks when certain data is available and ready to be used. No user-facing changes. ([#62](https://github.com/Raenore/Sippy-Cup/pull/62))  

### Changed  
- Improved MSP-related code (addons like TRP, MRP, XRP, etc.) to handle edge cases where, on login, Sippy Cup incorrectly thought the player was IC. ([#63](https://github.com/Raenore/Sippy-Cup/pull/63))  
- Optimized the code that checks for auras and spell cast tracking to improve performance ([#66](https://github.com/Raenore/Sippy-Cup/pull/66)).  
- Rewrote Sippy Cup's events and state system to be more robust, which should improve long-term performance ([#67](https://github.com/Raenore/Sippy-Cup/pull/67)).  

### Fixed  
- Fixed an issue where the refresh button remained disabled after being clicked with zero items left in the bag ([#65](https://github.com/Raenore/Sippy-Cup/pull/65)).  

## Full Changelog  
The complete changelog, including older versions, can always be found on [Sippy Cup's GitHub Wiki](https://github.com/Raenore/Sippy-Cup/wiki/Full-Changelog).  
