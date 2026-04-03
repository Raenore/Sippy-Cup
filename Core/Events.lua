-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

---@class SippyCupEvents : Frame
local Events = CreateFrame("Frame");

---RefreshStackSizes Helper to refresh stack sizes with MSP-aware logic.
---@return nil
local function refreshStackSizes()
	SC.Options.RefreshStackSizes(SC.MSP.IsEnabled() and SC.Database:GetGlobalSetting("MSPStatusCheck"));
end

---EnableRefreshButtonsForCast Re-enables disabled refresh buttons for a given cast spell.
---@param spellID number
---@return nil
local function enableRefreshButtonsForCast(spellID)
	if not SC.Database.castAuraToProfile[spellID] then
		return;
	end

	SC.Popups.ForEachActivePopup(function(popup)
		if popup.templateType == "SippyCup_RefreshPopupTemplate"
			and popup.RefreshButton
			and not popup.RefreshButton:IsEnabled()
		then
			popup.RefreshButton:Enable();
		end
	end);
end

local function OnLoadingScreenStarted()
	SC.Globals.States.loadingScreen = true;

	if not SC.Globals.States.addonReady then
		return;
	end

	SC.Timers:StopContinuousCheck();
end

---@return boolean stacksRefreshed
local function OnLoadingScreenEnded()
	SC.Utils.Log("INFO", "OnLoadingScreenEnded");
	SC.Globals.States.loadingScreen = false;
	local stacksRefreshed = false;

	local inPvp = C_RestrictedActions.IsAddOnRestrictionActive(Enum.AddOnRestrictionType.PvPMatch)
		or C_PvP.IsActiveBattlefield();

	if not SC.Globals.States.addonReady then
		return;
	end

	-- Do nothing when you are on a PvP-enabled map (Arenas, BGs, etc.)
	if inPvp then
		SC.Globals.States.pvpMatch = true;
		SC.Popups.HideAllRefreshPopups();
		return;
	end

	SC.Timers:StartContinuousCheck();
	SC.Popups.HandleDeferredActions(SC.Popups.BlockReason.LOADING);

	local leftPvpMatch = SC.Globals.States.pvpMatch;

	-- If we just came out of a PvP-enabled map, show deferred popups and refresh stacks.
	if leftPvpMatch then
		SC.Globals.States.pvpMatch = false;
		SC.Popups.HandleDeferredActions(SC.Popups.BlockReason.COMBAT);
		refreshStackSizes();
		stacksRefreshed = true;
	end

	-- isFullUpdate can pass through loading screens (but our code can't), so handle it now.
	if SC.Globals.States.hasSeenFullUpdate then
		SC.Globals.States.hasSeenFullUpdate = false;
		SC.Auras.CheckAllActiveOptions();
	end

	return stacksRefreshed;
end

---Set up event handler to call methods on Events by event name.
---Guard here covers all handlers except PLAYER_ENTERING_WORLD.
Events:SetScript("OnEvent", function(self, event, ...)
	if not SC or not SC.Database then return; end

	-- All events except PLAYER_ENTERING_WORLD require addonReady
	if event ~= "PLAYER_ENTERING_WORLD" and not SC.Globals.States.addonReady then
		return;
	end

	if self[event] then
		self[event](self, event, ...);
	end
end);

-- Player combat state
Events:RegisterEvent("PLAYER_REGEN_DISABLED");
Events:RegisterEvent("PLAYER_REGEN_ENABLED");

-- World / loading state
Events:RegisterEvent("PLAYER_ENTERING_WORLD");
Events:RegisterEvent("PLAYER_LEAVING_WORLD");
Events:RegisterEvent("ZONE_CHANGED_NEW_AREA");

-- Inventory
Events:RegisterEvent("BAG_UPDATE_DELAYED");

-- Addon restriction state
Events:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED");

-- Player unit events
Events:RegisterUnitEvent("UNIT_AURA", "player");
Events:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");
Events:RegisterUnitEvent("UNIT_SPELLCAST_RETICLE_CLEAR", "player");
Events:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player");

---PLAYER_REGEN_DISABLED Stops continuous checks when entering combat and defers all active popups.
function Events:PLAYER_REGEN_DISABLED()
	-- PvP Matches don't support most of Sippy Cup's options (aura checking etc.).
	if SC.Globals.States.pvpMatch then
		return;
	end

	-- Combat is entered when regen is disabled.
	SC.Timers:StopContinuousCheck();
	SC.Popups.DeferAllRefreshPopups(SC.Popups.BlockReason.COMBAT);
end

---PLAYER_REGEN_ENABLED Restarts continuous checks and handles deferred combat actions after leaving combat.
function Events:PLAYER_REGEN_ENABLED()
	-- PvP Matches don't support most of Sippy Cup's options (aura checking etc.).
	if SC.Globals.States.pvpMatch then
		return;
	end

	-- Combat is left when regen is enabled.
	SC.Timers:StartContinuousCheck();
	-- Show 'combat' popups deferred by DeferAllRefreshPopups (reason 1).
	SC.Popups.HandleDeferredActions(SC.Popups.BlockReason.COMBAT);
	refreshStackSizes();
end

---PLAYER_ENTERING_WORLD Handles player entering world or UI reload; triggers loading screen end logic if reloading.
---@param event string Event name (ignored)
---@param isInitialLogin boolean Whenever the character logs in.
---@param isReloadingUi boolean Whether UI is reloading
function Events:PLAYER_ENTERING_WORLD(event, isInitialLogin, isReloadingUi)
	SC.Utils.Log("INFO", event, isInitialLogin, isReloadingUi);

	-- Adapt saved variables structures between versions
	SC.Flyway.ApplyPatches();

	local inPvp = C_RestrictedActions.IsAddOnRestrictionActive(Enum.AddOnRestrictionType.PvPMatch)
		or C_PvP.IsActiveBattlefield();

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
		SC.Utils.Write(SC.Localization.WELCOMEMSG_VERSION:format(
			SC.Database:GetProfileName(),
			SC.Globals.addon_version
		));
		SC.Utils.Write(SC.Localization.WELCOMEMSG_OPTIONS);
	end

	SC.Globals.States.addonReady = true;

	-- ZONE_CHANGED_NEW_AREA fires on isInitialLogin, but not on isReloadingUi
	if isReloadingUi then
		-- Reloading fires PLAYER_ENTERING_WORLD when reload is done, data is fine.
		local stacksRefreshed = OnLoadingScreenEnded();
		if not stacksRefreshed then
			refreshStackSizes();
		end
	end
end

---PLAYER_LEAVING_WORLD Handles leaving the world; triggers loading screen start logic.
function Events:PLAYER_LEAVING_WORLD(event)
	SC.Utils.Log("INFO", event);
	OnLoadingScreenStarted();
end

---ZONE_CHANGED_NEW_AREA Handles zone changes and triggers loading screen end logic if needed.
function Events:ZONE_CHANGED_NEW_AREA(event)
	SC.Utils.Log("INFO", event);
	OnLoadingScreenEnded();
end

---BAG_UPDATE_DELAYED Handles delayed bag updates and triggers item update processing.
function Events:BAG_UPDATE_DELAYED()
	SC.Bags.BagUpdateDelayed();
end

---ADDON_RESTRICTION_STATE_CHANGED Handles PvP match restriction state changes.
function Events:ADDON_RESTRICTION_STATE_CHANGED(_, type, state) -- luacheck: no unused (type)
	if type == Enum.AddOnRestrictionType.PvPMatch
		and (state == Enum.AddOnRestrictionState.Activating or state == Enum.AddOnRestrictionState.Active)
		and C_PvP.IsActiveBattlefield()
	then
		SC.Globals.States.pvpMatch = true;

		SC.Timers:StopContinuousCheck();
		SC.Popups.HideAllRefreshPopups();
	elseif type == Enum.AddOnRestrictionType.PvPMatch
		and state == Enum.AddOnRestrictionState.Inactive
		and not C_PvP.IsActiveBattlefield()
	then
		if SC.Globals.States.pvpMatch then
			SC.Globals.States.pvpMatch = false;
		end

		SC.Timers:StartContinuousCheck();
		SC.Popups.HandleDeferredActions(SC.Popups.BlockReason.COMBAT);
		-- We also fire a refresh, because in BGs/combat options might have changed.
		refreshStackSizes();
	end
end

---UNIT_AURA Handles player aura updates, flags bag desync, and triggers aura conversion.
---@param event string Event name (ignored)
---@param unitTarget string Unit affected, automatically "player" through RegisterUnitEvent.
---@param updateInfo any Update data passed to aura conversion
function Events:UNIT_AURA(_, unitTarget, updateInfo) -- luacheck: no unused (unitTarget)
	if InCombatLockdown() or C_Secrets and C_Secrets.ShouldAurasBeSecret() or SC.Globals.States.pvpMatch then
		return;
	end

	SC.Auras.Convert(SC.Auras.Sources.UNIT_AURA, updateInfo);
end

---UNIT_SPELLCAST_SUCCEEDED Handles successful player spell casts; checks consumables/toys that don't trigger UNIT_AURA.
---@param event string Event name (ignored)
---@param unitTarget string Unit that cast the spell, automatically "player" through RegisterUnitEvent.
---@param _, _ Ignored parameters
---@param spellID number Spell identifier
function Events:UNIT_SPELLCAST_SUCCEEDED(_, unitTarget, _, spellID) -- luacheck: no unused (unitTarget)
	-- Necessary to handle items that don't fire UNIT_AURA.
	SC.Items.CheckNoAuraSingleOption(nil, spellID);
end

---UNIT_SPELLCAST_RETICLE_CLEAR Re-enables the refresh button if a prism cast was cancelled.
function Events:UNIT_SPELLCAST_RETICLE_CLEAR(_, unitTarget, _, spellID) -- luacheck: no unused (unitTarget)
	if InCombatLockdown() or not canaccessvalue(spellID) then
		return;
	end

	enableRefreshButtonsForCast(spellID);
end

---UNIT_SPELLCAST_INTERRUPTED Re-enables the refresh button if a prism cast was interrupted.
function Events:UNIT_SPELLCAST_INTERRUPTED(_, unitTarget, _, spellID) -- luacheck: no unused (unitTarget)
	if InCombatLockdown() or not canaccessvalue(spellID) then
		return;
	end

	enableRefreshButtonsForCast(spellID);
end

SC.Events = Events;
