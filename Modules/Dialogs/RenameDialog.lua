-- Copyright The Sippy Cup Authors
-- Inspired by Eavesdropper
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.RenameDialog = {};

local MaxProfileNameLength = 32;

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
		if data and data.oldName and newName ~= data then
			SIPPYCUP.Database.RenameProfile(data.oldName, newName);
		end
	end,
	OnShow = function(self, data)
		local button1 = _G[self:GetName() .. "Button1"];
		if button1 then
			button1:Disable();
		end
		if data and data.oldName then
			self.EditBox:SetText(data.oldName or "");
			self.EditBox:HighlightText();
		end
		self.EditBox:SetFocus();
	end,
	EditBoxOnTextChanged = function(self, data)
		local popup = self:GetParent();
		local button1 = _G[popup:GetName() .. "Button1"];
		if not button1 then return; end

		local newName = string.trim(self:GetText());
		local currentName = data and data.oldName or "";
		local isDuplicate = SIPPYCUP.Database.ProfileExists(newName);
		local isSame = newName == currentName;

		button1:SetEnabled(newName ~= "" and not isDuplicate and not isSame);
	end,
	EditBoxOnEscapePressed = function(self)
		StaticPopup_Hide("SIPPYCUP_RENAME_PROFILE");
	end,
	EditBoxOnEnterPressed = function(self, data)
		local newName = string.trim(self:GetText());
		if data and data.oldName then
			local currentName = data.oldName or "";
			local isDuplicate = SIPPYCUP.Database.ProfileExists(newName);
			if newName ~= "" and not isDuplicate and newName ~= currentName then
				SIPPYCUP.Database.RenameProfile(data.oldName, newName);
				StaticPopup_Hide("SIPPYCUP_RENAME_PROFILE");
			end
		end
	end,
};

