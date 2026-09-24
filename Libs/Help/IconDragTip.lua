--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

local L = ns:GetLocale()

--[[-----------------------------------------------------------------------------
LibIconPicker_IconDragTipMixin
@see Help.xml
-------------------------------------------------------------------------------]]
--- @class LibIconPicker_IconDragTipMixin : Frame
--- @field Text FontString
--- @field CloseButton Button
--- @field Arrow Frame
LibIconPicker_IconDragTipMixin = {}; local o = LibIconPicker_IconDragTipMixin

--
--- @class LibIconPicker_IconDragTip : LibIconPicker_IconDragTipMixin
--

function o:OnLoad()
    self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10)
    self.Text:SetText(L['Selected Icon::DragHint'])
    self.CloseButton:SetScript("OnClick", function() self:Dismiss() end)
end

function o:ShowOnce()
    if ns:GetHelpTips().DragTip then return end
    self:SetHeight(self.Text:GetHeight() + 32)
    self:Show()
end

function o:Dismiss()
    self:Hide()
    ns:GetHelpTips().DragTip = true
end
