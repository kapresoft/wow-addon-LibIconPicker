--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

local L = ns:GetLocale()

--[[-----------------------------------------------------------------------------
LibIconPicker_HelpTipMixin
@see Help.xml
-------------------------------------------------------------------------------]]
--- @class LibIconPicker_HelpTipMixin : Frame
--- @field Text FontString
--- @field CloseButton Button
--- @field Arrow Frame
--- @field tipKey string  @LibIconPicker_HelpTips key, from KeyValues
--- @field textKey string @Locale key, from KeyValues
LibIconPicker_HelpTipMixin = {}; local o = LibIconPicker_HelpTipMixin

--
--- @class LibIconPicker_HelpTip : LibIconPicker_HelpTipMixin
--

function o:OnLoad()
  self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10)
  self.Text:SetText(L[self.textKey])
  self.CloseButton:SetScript('OnClick', function() self:Dismiss() end)
end

--- @return boolean @false if already dismissed
function o:ShowOnce()
  if ns:GetHelpTips()[self.tipKey] then return false end
  self:SetHeight(self.Text:GetHeight() + 32)
  self:Show()
  return true
end

function o:Dismiss()
  self:Hide()
  ns:GetHelpTips()[self.tipKey] = true
end
