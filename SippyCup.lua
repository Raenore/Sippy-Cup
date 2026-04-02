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
		SC.Options.Setup();

		-- Now safe to initialize everything else
		SC.Config.TryCreateConfigFrame();

		-- Register slash commands
		SLASH_SIPPYCUP1, SLASH_SIPPYCUP2 = "/sc", "/sippycup";
		SlashCmdList["SIPPYCUP"] = function(msg)
			msg = (msg:match("^%s*(.-)%s*$") or ""):lower();

			if msg == "auras" and SC.Globals.IS_DEV_BUILD then
				SC.Auras.DebugEnabledAuras();
			else
				SC.Config:OpenSettings();
			end
		end

		-- Adapt saved variables structures between versions
		SC.Flyway.ApplyPatches();

		local inPvp = C_RestrictedActions.IsAddOnRestrictionActive(Enum.AddOnRestrictionType.PvPMatch) or C_PvP.IsActiveBattlefield();
		if inPvp then
			SC.Globals.States.pvpMatch = true;
			SC.Popups.DeferAllRefreshPopups(1);
		end

		-- Prepare our MSP checks.
		SC.MSP.EnableIfAvailable(); -- True/False if enable successfully, we don't need that info right now.

		-- Unknown profile migration
		local realCharKey = SC.Utils.GetUnitName();
		if realCharKey then
			local db = SippyCupDB;
			if db.profiles["Unknown"] and not db.profileKeys[realCharKey] then
				db.profiles[realCharKey] = db.profiles["Unknown"];
				db.profiles["Unknown"] = nil;

				for key, profileName in pairs(db.profileKeys) do
					if profileName == "Unknown" then
						db.profileKeys[key] = realCharKey;
					end
				end

				SC.Globals.States.requiresReinit = true;
			end
		end

		-- Re-resolve active profile only if flyway or Unknown migration changed things.
		if SC.Globals.States.requiresReinit then
			SC.Globals.States.requiresReinit = false;
			SC.Database:ResolveActiveProfile(realCharKey);
		end

		SC.Minimap:SetupMinimapButtons();

		if SC.Database:GetGlobalSetting("WelcomeMessage") then
			SC.Utils.Write(SC.Localization.WELCOMEMSG_VERSION:format(SC.Database:GetProfileName(), SC.Globals.addon_version));
			SC.Utils.Write(SC.Localization.WELCOMEMSG_OPTIONS);
		end

		SC.Globals.States.addonReady = true;
	end);
end

EventUtil.ContinueOnAddOnLoaded("SippyCup", SC.Init);
