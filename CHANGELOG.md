# Changelog

All notable changes to this project will be documented in this file.  

## [0.9.0] - 2026-10-13
Feature update adding early support for World of Warcraft Forever.

### Added
- Added early support for **World of Warcraft Forever**, alongside Standard.  
  - On Forever, items that don't exist there are left out of the settings, and categories with no items are greyed out with a tooltip explaining why.  
- Added 6 new toys ([#132](https://github.com/Raenore/Sippy-Cup/pull/132)):  
  - [Vrykul Drinking Horn](https://www.wowhead.com/item=69775)
  - ["Purple Phantom" Contender's Costume](https://www.wowhead.com/item=116889)
  - ["Night Demon" Contender's Costume](https://www.wowhead.com/item=116888)
  - ["Snowy Owl" Contender's Costume](https://www.wowhead.com/item=116891)
  - ["Santo's Sun" Contender's Costume](https://www.wowhead.com/item=116890)
  - ["Blooming Rose" Contender's Costume](https://www.wowhead.com/item=116856)

### Changed
- Updated the TOC for Patch 12.1.5.  

## [0.8.3] - 2026-09-12
Minor patch adding a Shadowlands toy and fixing several issues related to secrets in combat and other hidden-aura moments.

### Added
- Added 1 new toy ([#123](https://github.com/Raenore/Sippy-Cup/pull/123)):  
  - [Guise of the Changeling](https://www.wowhead.com/item=187155)

### Fixed  
- Fixed additional situations involving secrets in combat (and other moments where aura data is hidden, like Challenge Mode) that could cause incorrect tracking or refresh popups, thanks to [TenaarFeiri](https://github.com/TenaarFeiri) for reporting the original issue ([#125](https://github.com/Raenore/Sippy-Cup/pull/125), [#127](https://github.com/Raenore/Sippy-Cup/pull/127), [#128](https://github.com/Raenore/Sippy-Cup/pull/128), [#129](https://github.com/Raenore/Sippy-Cup/pull/129)).  

## [0.8.2] - 2026-08-12  
Minor patch adding a new toy, updating support for Patch 12.1.0, and resolving ElvUI integration issues.  

### Added
- Added 1 new toy ([#120](https://github.com/Raenore/Sippy-Cup/pull/120)):  
  - [Cursed Badge of the Soulcoilers](https://www.wowhead.com/item=280419)

### Changed  
- Updated the TOC to support WoW 12.1.0 ([#121](https://github.com/Raenore/Sippy-Cup/pull/121)).  

### Fixed  
- Fixed ElvUI styling for the popup's new Aura Icon ([#118](https://github.com/Raenore/Sippy-Cup/pull/118)).  

## [0.8.1] - 2026-08-03  
Small hotfix fixing the new feature indicators for the changed options.

### Fixed  
- Resolved a small issue where new feature indicators would not show up for the 0.8.x changes ([#103](https://github.com/Raenore/Sippy-Cup/pull/103)).  

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

## Full Changelog  
The complete changelog, including older versions, can always be found on [Sippy Cup's GitHub Wiki](https://github.com/Raenore/Sippy-Cup/wiki/Full-Changelog).  

[unreleased]: https://github.com/Raenore/Sippy-Cup/compare/0.9.0...HEAD
[0.9.0]: https://github.com/Raenore/Sippy-Cup/compare/0.8.3...0.9.0
[0.8.3]: https://github.com/Raenore/Sippy-Cup/compare/0.8.2...0.8.3
[0.8.2]: https://github.com/Raenore/Sippy-Cup/compare/0.8.1...0.8.2
[0.8.1]: https://github.com/Raenore/Sippy-Cup/compare/0.8.0...0.8.1
[0.8.0]: https://github.com/Raenore/Sippy-Cup/compare/0.7.4...0.8.0
