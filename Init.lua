-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: GPL-3.0-or-later

---@class SC
SC = select(2, ...);

SC.Globals = {
	--@debug@
	-- Debug mode is enable when the add-on has not been packaged by Curse
	IS_DEV_BUILD = true;
	--@end-debug@

	--[===[@non-debug@
	-- Debug mode is disabled when the add-on has been packaged by Curse
	IS_DEV_BUILD = false;
	--@end-non-debug@]===]
};
