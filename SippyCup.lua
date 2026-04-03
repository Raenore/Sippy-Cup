-- Copyright The Sippy Cup Authors
-- Inspired by Eavesdropper
-- SPDX-License-Identifier: Apache-2.0

function SC.Init()
	EventUtil.ContinueOnPlayerLogin(function()
		-- Automatically set preferred locale (respects GAME_LOCALE)
		SC.Localization:SetCurrentLocale(SC.Localization:GetPreferredLocale(), true);

		-- DB must be ready first
		SC.Database:Init();
		-- Then Options
		SC.Options.Setup(function()
			-- With options ready, we init the Config Frame
			SC.Settings:Init();
		end);

		-- Register slash commands
		SLASH_SIPPYCUP1, SLASH_SIPPYCUP2 = "/sc", "/sippycup";
		SlashCmdList["SIPPYCUP"] = function(msg)
			if not SC.SettingsFrame then return; end
			msg = (msg:match("^%s*(.-)%s*$") or ""):lower();

			if msg == "auras" and SC.Globals.IS_DEV_BUILD then
				SC.Auras.DebugEnabledAuras();
			else
				SC.Settings:ShowSettings();
			end
		end
	end);
end

EventUtil.ContinueOnAddOnLoaded("SippyCup", SC.Init);
