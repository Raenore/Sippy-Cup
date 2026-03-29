-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

local L = SIPPYCUP.L;
SIPPYCUP.LinkDialog = {};

-- Borrowed from Total RP 3
local function GetDialogEditBox(dialog)
	return dialog.GetEditBox and dialog:GetEditBox() or dialog.editBox;
end

local function SkinEditBox(editBox)
	local E = ElvUI and ElvUI[1];
	if not E then return; end
	local S = E:GetModule("Skins") if not S then return; end

	S:HandleEditBox(editBox);
end

local function SetupEditBox(editBox, url)
	editBox:SetText(url or "");

	editBox:HighlightText();
	editBox:SetFocus();

	editBox:SetScript("OnEditFocusGained", function(self)
		self:HighlightText();
	end);

	editBox:SetScript("OnKeyDown", function(self, key)
		if key == "ESCAPE" then
			self:GetParent():Hide();
		elseif key == "C" and IsControlKeyDown() then
			self:HighlightText();
			UIErrorsFrame:AddMessage(L.COPY_SYSTEM_MESSAGE, YELLOW_FONT_COLOR:GetRGB());
			RunNextFrame(function()
				self:GetParent():Hide();
			end);
		end
	end);
end

StaticPopupDialogs["SIPPYCUP_LINK_DIALOG"] = {
	text = SIPPYCUP.AddonMetadata.title .. L.POPUP_LINK,
	button1 = CANCEL,
	hasEditBox = true,
	editBoxWidth = 320,
	OnShow = function(self)
		local editBox = GetDialogEditBox(self);
		SkinEditBox(editBox);
		SetupEditBox(editBox, StaticPopupDialogs["SIPPYCUP_LINK_DIALOG"].url or "");
	end,
	timeout = false,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
};

---Displays a static popup dialog containing the given URL in a copyable editBox.
---@param url string
function SIPPYCUP.LinkDialog.CreateExternalLinkDialog(url)
	StaticPopupDialogs["SIPPYCUP_LINK_DIALOG"].url = url;
	local dialog = StaticPopup_Show("SIPPYCUP_LINK_DIALOG");
	if dialog then
		dialog:ClearAllPoints();
		dialog:SetPoint("CENTER", UIParent, "CENTER");
	end
end
