-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local L = SIPPYCUP.L;
SIPPYCUP.LinkDialog = {};

local function SetupEditBox(editBox, url)
	editBox:SetText(url or "");

	editBox:HighlightText();
	editBox:SetFocus();

	editBox:SetScript("OnEditFocusGained", function(self)
		self:HighlightText();
	end);

	editBox:SetScript("OnKeyDown", function(self, key)
		if key == "C" and IsControlKeyDown() then
			self:HighlightText();
			UIErrorsFrame:AddMessage(L.COPY_SYSTEM_MESSAGE, YELLOW_FONT_COLOR:GetRGB());
			RunNextFrame(function()
				self:GetParent():Hide();
			end);
		elseif key == "ESCAPE" then
			self:GetParent():Hide();
		end
	end);
end

StaticPopupDialogs["SIPPYCUP_LINK_DIALOG"] = {
	text = SIPPYCUP.AddonMetadata.title .. L.POPUP_LINK,
	button1 = CANCEL,
	hasEditBox = true,
	editBoxWidth = 320,
	OnShow = function(self, data)
		local editBox = self.EditBox;
		SetupEditBox(editBox, data);
	end,
	timeout = false,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

---CreateExternalLinkDialog displays a dialog with an external link.
---@param url string The URL to be displayed in the dialog.
function SIPPYCUP.LinkDialog.CreateExternalLinkDialog(url)
	local dialog = StaticPopup_Show("SIPPYCUP_LINK_DIALOG", nil, nil, url);
	if dialog then
		dialog:ClearAllPoints();
		dialog:SetPoint("CENTER", UIParent, "CENTER");
	end
end
