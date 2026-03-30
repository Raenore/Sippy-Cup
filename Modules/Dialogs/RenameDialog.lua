-- Copyright The Sippy Cup Authors
-- Inspired by Eavesdropper
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.RenameDialog = {};

local MaxProfileNameLength = 32;

---Validates a proposed profile name against the current name.
---@param newName string
---@param oldName string
---@return boolean isValid
local function validateNewName(newName, oldName)
	if newName == "" then return false; end
	if newName == oldName then return false; end
	if SIPPYCUP.Database:ProfileExists(newName) then return false; end
	return true;
end

StaticPopupDialogs["SIPPYCUP_RENAME_PROFILE"] = {
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = true,
	maxLetters = MaxProfileNameLength,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	OnAccept = function(self, data)
		local newName = string.trim(self.EditBox:GetText());
		if data and data.oldName and newName ~= data.oldName then
			SIPPYCUP.Database:RenameProfile(data.oldName, newName);
		end
	end,
	OnShow = function(self, data)
		local button1 = _G[self:GetName() .. "Button1"];
		if button1 then
			button1:Disable();
		end
		if data and data.oldName then
			self.EditBox:SetText(data.oldName);
			self.EditBox:HighlightText();
		end
		self.EditBox:SetFocus();
	end,
	EditBoxOnTextChanged = function(self, data)
		local popup = self:GetParent();
		local button1 = _G[popup:GetName() .. "Button1"];
		if not button1 then return; end

		local newName = string.trim(self:GetText());
		local oldName = data and data.oldName or "";

		button1:SetEnabled(validateNewName(newName, oldName));
	end,
	EditBoxOnEscapePressed = function(self)
		StaticPopup_Hide("SIPPYCUP_RENAME_PROFILE");
	end,
	EditBoxOnEnterPressed = function(self, data)
		if not data or not data.oldName then return; end

		local newName = string.trim(self:GetText());
		if validateNewName(newName, data.oldName) then
			SIPPYCUP.Database:RenameProfile(data.oldName, newName);
			StaticPopup_Hide("SIPPYCUP_RENAME_PROFILE");
		end
	end,
};
