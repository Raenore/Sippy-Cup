-- Copyright The Sippy Cup Authors
-- SPDX-License-Identifier: Apache-2.0

SIPPYCUP.ElvUI = {};

function SIPPYCUP.ElvUI.SkinPopupFrame(frame)
	local E = ElvUI and ElvUI[1]
	if not E then return; end

	local S = E:GetModule("Skins")
	if not S then return; end

	if not frame or frame:IsForbidden() then return; end

	S:HandleFrame(frame)

	for _, child in ipairs({ frame:GetChildren() }) do
		if child:IsObjectType("Button") then
			S:HandleButton(child)
		end
	end

	S:HandleIcon(frame.ItemIcon)
end
