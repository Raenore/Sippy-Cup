-- Copyright The Sippy Cup Authors
-- Inspired by Eavesdropper
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.ConfirmDialog = {};

StaticPopupDialogs["SIPPYCUP_CONFIRM_DIALOG"] = {
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		if StaticPopupDialogs["SIPPYCUP_CONFIRM_DIALOG"].onAccept then
			StaticPopupDialogs["SIPPYCUP_CONFIRM_DIALOG"].onAccept();
		end
	end,
	OnCancel = function()
	end,
	timeout = false,
	whileDead = true,
	hideOnEscape = true, -- does not work with enterClicksFirstButton
	showAlert = true,
	enterClicksFirstButton = true,
	escapeHides = true, -- required with enterClicksFirstButton
	preferredIndex = 3,
};

---Displays a reusable confirmation dialog with ACCEPT/CANCEL buttons.
---@param message string The confirmation message shown to the player.
---@param onAccept function Callback invoked when the player clicks ACCEPT or presses Enter.
function SIPPYCUP.ConfirmDialog:Show(message, onAccept)
	StaticPopupDialogs["SIPPYCUP_CONFIRM_DIALOG"].text = message;
	StaticPopupDialogs["SIPPYCUP_CONFIRM_DIALOG"].onAccept = onAccept;
	local dialog = StaticPopup_Show("SIPPYCUP_CONFIRM_DIALOG");
	if dialog then
		dialog:ClearAllPoints();
		dialog:SetPoint("CENTER", UIParent, "CENTER");
	end
end

