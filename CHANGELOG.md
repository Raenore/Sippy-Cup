# Changelog

All notable changes to this project will be documented in this file.

## [0.4.1] - 2025-08-xx  
First bugfix patch targeting the 0.4.0 internal rework, improving MSP handling and streamlining some startup code.  

### Added  
- Added additional internal states to ensure Sippy Cup correctly tracks when certain data is available and ready to be used. No user-facing changes ([#62](https://github.com/Raenore/Sippy-Cup/pull/62))  

### Changed  
- Improved MSP-related code (addons like TRP, MRP, XRP, etc.) to handle edge cases where, on login, Sippy Cup incorrectly thought the player was IC. ([#63](https://github.com/Raenore/Sippy-Cup/pull/63))  

### Fixed  
- Fixed an issue where the refresh button remained disabled after being clicked with zero items left in the bag ([#65](https://github.com/Raenore/Sippy-Cup/pull/65)).  

## [0.4.0] - 2025-08-10  
Major patch following the 0.3.0 rework release, introducing several new requested features, significant internal optimizations, and fixes for reported bugs.

### Added  
- When ignored popups are reset, Sippy Cup will try to fire the popups for consumables you have enabled reminders for. [#48](https://github.com/Raenore/Sippy-Cup/pull/48)  
- Ability to queue reminders that happen during combat and loading screens, and fire them at a time when it is more permissible and sensible for Sippy Cup to do so. [#52](https://github.com/Raenore/Sippy-Cup/pull/52)  
- Enabling "Pre-Expiration Reminders" now also takes into account currently activated consumables, so they also get a reminder popup; disabling it will hide all pre-expiration related popups. [#52](https://github.com/Raenore/Sippy-Cup/pull/52) and [#58](https://github.com/Raenore/Sippy-Cup/pull/58)  
- Added a proper state listener to improve the addon's reliability in knowing when data can be properly used. [#47](https://github.com/Raenore/Sippy-Cup/pull/47) and [#52](https://github.com/Raenore/Sippy-Cup/pull/52)  
- While in flight, Sippy Cup will no longer allow refreshing consumables to prevent dismounting accidents; spam protection on the Refresh button is improved, significantly reducing the chances of overusing an item. [#55](https://github.com/Raenore/Sippy-Cup/pull/55)  

### Changed  
- Adjusted how aura data is received from the game, which should resolve the random "your item is not active" popups that sometimes appeared after loading screens. [#43](https://github.com/Raenore/Sippy-Cup/pull/43)  
- Marked 11.2 as the only compatible version; 11.1.7 is no longer supported, as all live servers have updated. [#45](https://github.com/Raenore/Sippy-Cup/pull/45)  
- MSP-related code (addons like TRP, MRP, XRP, etc.) has been improved and simplified to work better and be less prone to errors. [#52](https://github.com/Raenore/Sippy-Cup/pull/52) and [#53](https://github.com/Raenore/Sippy-Cup/pull/53)  
- On login, reminders for missing popups or popups that will expire soon are now more robust and effective. [#52](https://github.com/Raenore/Sippy-Cup/pull/52)  
- The logic for toggling consumables in the settings has been improved. This may not be noticeable unless you have many consumables enabled at once. [#56](https://github.com/Raenore/Sippy-Cup/pull/56)  
- Updated the French translation with all recent changes (thanks to Solanya). The Russian translation remains outdated for now. [#60](https://github.com/Raenore/Sippy-Cup/pull/60)  

### Fixed  
- Resolved an issue caused by ignoring consumables through their reminder popup before the settings page had ever been opened. [#49](https://github.com/Raenore/Sippy-Cup/pull/49)  
- Fixed an issue where certain checkboxes, such as `Only when "In Character"`, could become stuck in a disabled state even when an MSP-compatible addon was loaded. [#51](https://github.com/Raenore/Sippy-Cup/pull/51)  
- Stack slider tooltip was not displaying the consumable name correctly; instead, it was showing the spell ID. [#52](https://github.com/Raenore/Sippy-Cup/pull/52)  
- Fixed potential skinning issues for ElvUI (if enabled) with the config menu. [#52](https://github.com/Raenore/Sippy-Cup/pull/52)  
- Fixed an issue where the settings window width could be smaller than the tabs it contained. [#54](https://github.com/Raenore/Sippy-Cup/pull/54)  

### Removed  
- Removed Ace3 as an optional dependency from the TOC. [#46](https://github.com/Raenore/Sippy-Cup/pull/46)  

## [0.3.1] - 2025-08-06  
First bugfix patch targeting the major 0.3.0 rework release.  

### Added
- Added a popup reason enum. This is a technical addition that will aid future documentation. No user-facing changes ([#36](https://github.com/Raenore/Sippy-Cup/pull/36)).  
- Pre-expiration reminders for stackable items now correctly display the stack as one below the maximum (e.g., 9/10) when only one more item is needed to refresh the timer ([#37](https://github.com/Raenore/Sippy-Cup/pull/37)).   

### Changed
- Improved stack calculation logic to reduce incorrect stack size reporting in certain cases ([#37](https://github.com/Raenore/Sippy-Cup/pull/37)).  
- Renamed `auraTrackable` to `noAuraTrackable` for clarity. No user-facing changes ([#38](https://github.com/Raenore/Sippy-Cup/pull/38)).  
- Optimized several functions for minor performance gains. No user-facing changes ([#42](https://github.com/Raenore/Sippy-Cup/pull/42)).  

### Fixed
- The Alert Sound dropdown now correctly enables or disables based on the "Toggle Sound" checkbox ([#35](https://github.com/Raenore/Sippy-Cup/pull/35)).  
- The Alert Sound dropdown is now scrollable when it contains more than 20 items ([#35](https://github.com/Raenore/Sippy-Cup/pull/35)).  
- Fixed an issue where pre-expiration reminder popups would not trigger in some cases ([#39](https://github.com/Raenore/Sippy-Cup/pull/39)).  

## [0.3.0] - 2025-08-05  
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

## Full Changelog  
The complete changelog, including older versions, can always be found on [Sippy Cup's GitHub Wiki](https://github.com/Raenore/Sippy-Cup/wiki/Full-Changelog).  
