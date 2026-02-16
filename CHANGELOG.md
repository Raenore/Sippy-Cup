# Changelog

All notable changes to this project will be documented in this file.

## [0.7.0] - 2026-02-xx  
Major patch as we move further into the Midnight pre-patch, with improved Prism (Projecting & Reflecting) support and additional secret-related fixes.  

### Added
- Proper Prism support! ([#86](https://github.com/Raenore/Sippy-Cup/pull/86))  
  - Both prism types now track properly, unlike the previous implementation.  
  - Both Projecting and Reflecting Prism have separate pre-expiration timers that you can adjust.  
  - Projection Prism works with all quality variants. It will prioritize Gold, then Silver, and finally Bronze quality.   
- If an option requires a party, this will now be mentioned on the refresh button while it is disabled (until a party is formed).  
- If an option is channeled and gets interrupted, the button will properly re-enable so you can refresh it again.  

### Changed  
- Updated Spanish translation thanks to [Romanv](https://bsky.app/profile/romanv88.bsky.social) ([#85](https://github.com/Raenore/Sippy-Cup/pull/85)).  
- Sippy Cup will now fully bail out in Battlegrounds. Supporting auras/buffs there is too complex (due to Midnight's secrets) and has no real RP value ([#83](https://github.com/Raenore/Sippy-Cup/pull/83)).  
- The system that tracks dirty bag states (for proper item counts) and buff events has been rewritten to be more efficient. No user-facing changes. ([#86](https://github.com/Raenore/Sippy-Cup/pull/86))  

### Fixed  
- Fixed additional spellID secrets ([#84](https://github.com/Raenore/Sippy-Cup/pull/84)).  

## [0.6.1] - 2026-02-11  
Second pre-patch for Midnight, fixing some UI issues and introducing a Spanish translation!  

### Added  
- Added a "new feature indicator", a small blue pip/diamond to notify users of new features ([#79](https://github.com/Raenore/Sippy-Cup/pull/79)).  
- Added Spanish translation thanks to [Romanv](https://bsky.app/profile/romanv88.bsky.social) ([#80](https://github.com/Raenore/Sippy-Cup/pull/80)).  
- Added two new handheld consumables: [Overbaked Donut](https://www.wowhead.com/item=268115) and [Simple Cup](https://www.wowhead.com/item=267486).  

### Changed  
- Updated the TOC for Patch 12.0.1.  

## [0.6.0] - 2026-01-20  
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

## Full Changelog  
The complete changelog, including older versions, can always be found on [Sippy Cup's GitHub Wiki](https://github.com/Raenore/Sippy-Cup/wiki/Full-Changelog).  
