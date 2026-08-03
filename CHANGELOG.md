# Changelog

All notable changes to this project will be documented in this file.  

## [0.8.0] - 2026-08-03 
Major architectural overhaul focused on codebase modernization, improved stability, and more reliable addon initialization.  

### Added
- Added confirmation popups for profile actions to prevent accidental clicks ([#100](https://github.com/Raenore/Sippy-Cup/pull/100)).  
  - "New," "Copy From," "Reset," and "Delete" profile options now ask for confirmation before any changes are made.  
- You can now rename existing profiles in the profile switching dropdown by clicking the small gear icon when hovering over them ([#100](https://github.com/Raenore/Sippy-Cup/pull/100)).  
- Added a "Disable in Combat Instances" option (enabled by default), so Sippy Cup stays quiet while you're in a combat-enabled instance ([#104](https://github.com/Raenore/Sippy-Cup/pull/104)).  
- Added a "Show Aura Icon" option to refresh popups (disabled by default), showing the aura's own icon separately from the consumable/toy's icon. This is handy since a consumable/toy's link doesn't always match the aura it actually grants ([#104](https://github.com/Raenore/Sippy-Cup/pull/104)).  
- Added a dedicated Minimap Options dropdown, gathering all minimap-related settings in one place ([#104](https://github.com/Raenore/Sippy-Cup/pull/104)).  
- Added 5 new toys ([#108](https://github.com/Raenore/Sippy-Cup/pull/108), [#110](https://github.com/Raenore/Sippy-Cup/pull/110) and [#111](https://github.com/Raenore/Sippy-Cup/pull/111)):
  - [Spitzy](https://www.wowhead.com/item=156871)
  - [Lightning-Blessed Spire](https://www.wowhead.com/item=246227) (BFA TW)
  - [Sea-Blessed Shrine](https://www.wowhead.com/item=245942) (BFA TW)
  - [Lightveil Rune Reader](https://www.wowhead.com/item=276374)
  - [Technomancer's Scrying Matrix](https://www.wowhead.com/item=276375)

### Changed  
- **Sippy Cup is now licensed under GNU GPLv3** instead of Apache 2.0 (as required by our relicensing process) ([#112](https://github.com/Raenore/Sippy-Cup/pull/112)).   
  - The core change is that GPLv3 strictly disallows closed-source variants. It ensures the software remains completely free and open for users, while protecting the codebase from being locked behind proprietary walls.
  - Sippy Cup was made to be forever free and maintained by whoever might take over after me and to achieve that future forks or derivatives should be (legally) required to remain open-source forever.
- Performed a large-scale internal refactor of the addon’s structure to improve long-term stability and performance ([#103](https://github.com/Raenore/Sippy-Cup/pull/103)).  
- Updated the addon’s startup sequence to ensure all systems initialize in a more reliable and predictable order during login and area transitions ([#103](https://github.com/Raenore/Sippy-Cup/pull/103)).  
- Refactored the Settings interface to be more modular, allowing for easier maintenance and future updates to the configuration menu ([#103](https://github.com/Raenore/Sippy-Cup/pull/103)).  
- Replaced the old MSP status check with a single "Popup Reminder Behavior" option, giving you more control over when reminder popups appear (Disabled, In-Character, Smart, or Always) ([#104](https://github.com/Raenore/Sippy-Cup/pull/104)).  
- Updated the TOC to support WoW 12.0.7 ([#104](https://github.com/Raenore/Sippy-Cup/pull/104)).  

### Fixed  
- Resolved a rare issue where tracking could occasionally break after switching profiles, which previously required a UI reload, logout, or game restart to fix ([#103](https://github.com/Raenore/Sippy-Cup/pull/103)).  
- Improved the reliability of the popup deferral system, ensuring notification popups are correctly hidden during combat or busy events and shown afterward ([#103](https://github.com/Raenore/Sippy-Cup/pull/103)).  
- Resolved an issue with item cooldown tracking when specific consumables or toys were identified by a single Item ID ([#103](https://github.com/Raenore/Sippy-Cup/pull/103)).  
- Fixed a display issue in the Settings menu where certain option labels wouldn't refresh correctly ([#104](https://github.com/Raenore/Sippy-Cup/pull/104)).  
- Fixed an issue with an internal data migration that could leave your settings in an inconsistent state ([#104](https://github.com/Raenore/Sippy-Cup/pull/104)).  

## [0.7.5] - 2026-04-23  
Minor patch to update the TOC version for Patch 12.0.5. The larger 0.8.0 overhaul is still in development and will be arriving at a later date.  

### Changed  
- Updated the TOC for Patch 12.0.5.  

## [0.7.4] - 2026-03-25  
Minor patch adding select Midnight consumables.  

### Added
- Added [Pango Plating](https://www.wowhead.com/item=268717) (Appearance) ([#96](https://github.com/Raenore/Sippy-Cup/pull/96)).  
- Added [Hexed Potatoad Mucus](https://www.wowhead.com/item=252265) (Appearance) and [Researcher's Shadowgraft](https://www.wowhead.com/item=250319) (Effect) ([#97](https://github.com/Raenore/Sippy-Cup/pull/97)).  

## [0.7.3] - 2026-03-05  
Minor patch adding select Ruby Feast (Dragonflight) consumables and resolving user-submitted bugs.  

### Added
- Added 3 new effect consumables from Dragonflight's Ruby Feast, with more to be added as testing continues ([#95](https://github.com/Raenore/Sippy-Cup/pull/95)).  

### Fixed  
- Fixed an issue where "insufficient reminders" would pop up randomly despite having sufficient consumables ([#93](https://github.com/Raenore/Sippy-Cup/pull/93)).  
- Fixed a rare occurrence where rapidly adding and removing prisms could cause the refresh popup to remain stuck ([#92](https://github.com/Raenore/Sippy-Cup/pull/92)).  

## [0.7.2] - 2026-02-28  
Minor patch that adds newly-added handheld items from Midnight.  

### Added
- Added 21 new handheld consumables found in Midnight's Arcantina.  

## [0.7.1] - 2026-02-24  
Minor patch to fix checking and unchecking global settings.  

### Fixed  
- Fixed global settings not checking or unchecking due to previous DB updates ([#90](https://github.com/Raenore/Sippy-Cup/pull/90)).  

## [0.7.0] - 2026-02-23  
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
- Updated Russian translation thanks to [Hubbotu](https://github.com/Hubbotu).  

### Fixed  
- Fixed additional spellID secrets ([#84](https://github.com/Raenore/Sippy-Cup/pull/84)).  
- Fixed a rare issue where certain settings would not save globally or per profile ([#89](https://github.com/Raenore/Sippy-Cup/pull/89)).  

## Full Changelog  
The complete changelog, including older versions, can always be found on [Sippy Cup's GitHub Wiki](https://github.com/Raenore/Sippy-Cup/wiki/Full-Changelog).  

[unreleased]: https://github.com/Raenore/Sippy-Cup/compare/0.8.0...HEAD
[0.8.0]: https://github.com/Raenore/Sippy-Cup/compare/0.7.4...0.8.0
[0.7.4]: https://github.com/Raenore/Sippy-Cup/compare/0.7.3...0.7.4
[0.7.3]: https://github.com/Raenore/Sippy-Cup/compare/0.7.2...0.7.3
[0.7.2]: https://github.com/Raenore/Sippy-Cup/compare/0.7.1...0.7.2
[0.7.1]: https://github.com/Raenore/Sippy-Cup/compare/0.7.0...0.7.1
[0.7.0]: https://github.com/Raenore/Sippy-Cup/compare/0.6.1...0.7.0
