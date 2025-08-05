-- Copyright The Sippy Cup Authors
-- Inspired by Total RP 3
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.Flyway.Patches = {};

SIPPYCUP.Flyway.Patches["1"] = {
	run = function()
		if not SIPPYCUP.db then
			return;
		end

		local AuraIDByProfile = {
			archivistsCodex = 1213428;
			ashenLiniment = 357489;
			blubberyMuffin = 382761;
			collectiblePineappletiniMug = 1222839;
			darkmoonFirewater = 185562;
			decorativeYardFlamingo = 1213663;
			disposableHamburger = 1222835;
			disposableHotdog = 1222833;
			elixirOfGiantGrowth = 8212;
			elixirOfTongues = 2336;
			enchantedDust = 162906;
			firewaterSorbet = 398458;
			fleetingSands = 393977;
			flickeringFlameHolder = 454799;
			giganticFeast = 58468;
			greenDanceStick = 244014;
			halfEatenTakeout = 1222840;
			holyCandle = 443688;
			inkyBlackPotion = 185394;
			noggenfoggerSelectDown = 1218300;
			noggenfoggerSelectUp = 1218297;
			projectionPrism = 374957;
			provisWax = 368038;
			purpleDanceStick = 244015;
			pygmyOil = 53805;
			pygmyPotion = 53805;
			quicksilverSands = 393979;
			radiantFocus = 1213974;
			sacreditesLedger = 1214287;
			reflectingPrism = 163219;
			scrollOfInnerTruth = 279742;
			singleUseGrill = 1222834;
			smallFeast = 58479;
			snowInACone = 382729;
			sparkbugJar = 442106;
			stinkyBrightPotion = 404840;
			sunglow = 254544;
			tatteredArathiPrayerScroll = 1213975;
			temporallyLockedSands = 393989;
			wearySands = 393994;
			winterfallFirewater = 17038;
		};

		for profileName, profileData in pairs(SIPPYCUP.db.profiles) do
			local newProfile = {};

			for key, value in pairs(profileData) do
				-- Only process string keys (i.e. old profile names)
				if type(key) == "string" then
					local auraID = AuraIDByProfile[key];

					-- Case-insensitive fallback
					if not auraID then
						local lowerKey = key:lower();
						for profileKey, id in pairs(AuraIDByProfile) do
							if profileKey:lower() == lowerKey then
								auraID = id;
								break;
							end
						end
					end

					if auraID then
						-- Store/overwrite by auraID
						newProfile[auraID] = value;
					else
						-- retain unknown key entries (in case)
						newProfile[key] = value;
					end
				else
					-- Retain non-string keys (like existing auraIDs) without processing
					newProfile[key] = value;
				end
			end

			-- Replace old profile data with updated key mappings
			SIPPYCUP.db.profiles[profileName] = newProfile;
		end

		-- Reload current profile with new data, for reminders to show up.
		local profileName = SIPPYCUP.Database.GetCurrentProfileName();
		SIPPYCUP.Database.SetProfile(profileName);

		if SIPPYCUP.db.global.PopupIcon ~= nil then
			SIPPYCUP.db.global.PopupIcon = nil;
		end
	end,

	description = "Prepare 0.3.0, updated SV profiles to using AuraID/SpellID.",
};
