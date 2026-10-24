--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

local L = ns:GetLocale()

-- Arrow's inset from the tip's side edge.
local ARROW_INSET = 8
-- ArrowUp on the right clears the close button in that corner.
local ARROW_UP_RIGHT_INSET = 40
-- Half the GlowBox arrow art; centers the arrow over the target.
local ARROW_HALF_WIDTH = 26
-- How far the arrow overlaps into the tip's edge.
local ARROW_OVERLAP = 4
-- Tip edge to target edge; leaves room for the arrow.
local ARROW_GAP = 19
-- Text's left inset plus room for the close button.
local TEXT_PAD_X = 44
local TEXT_PAD_Y = 32

--[[-----------------------------------------------------------------------------
LibIconPicker_HelpTipMixin: the view; LibIconPicker_HelpTour decides what it shows.
@see Help.xml
-------------------------------------------------------------------------------]]
--- @class LibIconPicker_HelpTipMixin : Frame
--- @field Text FontString
--- @field Counter FontString  @Step position, e.g. 1/3; hidden on one-step tours
--- @field CloseButton Button
--- @field Arrow Frame         @Points down; shown while the tip is above its target
--- @field ArrowUp Frame       @Points up; shown while the tip is below its target
--- @field textMaxWidth number @Wrap width; Text's width from XML
--- @field onClose fun()?      @Set by LibIconPicker_HelpTour; runs on the close button
LibIconPicker_HelpTipMixin = {}; local o = LibIconPicker_HelpTipMixin

--
--- @class LibIconPicker_HelpTip : LibIconPicker_HelpTipMixin
--

function o:OnLoad()
  self.textMaxWidth = self.Text:GetWidth()
  self.CloseButton:SetScript('OnClick', function()
    if self.onClose then self.onClose() end
  end)
end

--- @param textKey string @Locale key of the step text
--- @param anchorTo Region
--- @param index number   @Step position in its tour
--- @param count number   @Steps in the tour; 1 hides the counter
function o:ShowStep(textKey, anchorTo, index, count)
  self.Text:SetText(L[textKey])
  self.Counter:SetFormattedText('%d/%d', index, count)
  self.Counter:SetShown(count > 1)
  -- Set here: the parent raises its level after our OnLoad.
  self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10)
  self:FitToText()
  self:PlaceAt(anchorTo)
  self:Show()
end

--- Short text shrinks the box; long text wraps at textMaxWidth.
function o:FitToText()
  local text = self.Text
  local width = math.min(text:GetUnboundedStringWidth(), self.textMaxWidth)
  text:SetWidth(width)
  self:SetSize(width + TEXT_PAD_X, text:GetHeight() + TEXT_PAD_Y)
end

--- Above anchorTo when it fits on screen, else below with the arrow flipped.
--- The tip opens away from the nearer screen edge.
--- @param anchorTo Region
function o:PlaceAt(anchorTo)
  local below = self:RoomAbove(anchorTo) < ARROW_GAP + self:GetHeight()
  local side = self:ArrowSide(anchorTo)
  local inset = (below and side == 'RIGHT') and ARROW_UP_RIGHT_INSET or ARROW_INSET
  self.Arrow:SetShown(not below)
  self.ArrowUp:SetShown(below)
  self:AnchorArrow(below and self.ArrowUp or self.Arrow, below, side, inset)

  local offset = inset + ARROW_HALF_WIDTH
  local x = side == 'LEFT' and -offset or offset
  self:ClearAllPoints()
  if below then
    self:SetPoint('TOP' .. side, anchorTo, 'BOTTOM', x, -ARROW_GAP)
  else
    self:SetPoint('BOTTOM' .. side, anchorTo, 'TOP', x, ARROW_GAP)
  end
end

--- @param arrow Frame
--- @param below boolean     @ArrowUp on the top edge, else Arrow on the bottom edge
--- @param side 'LEFT'|'RIGHT'
--- @param inset number      @From that side's edge
function o:AnchorArrow(arrow, below, side, inset)
  local x = side == 'LEFT' and inset or -inset
  arrow:ClearAllPoints()
  if below then
    arrow:SetPoint('BOTTOM' .. side, self, 'TOP' .. side, x, -ARROW_OVERLAP)
  else
    arrow:SetPoint('TOP' .. side, self, 'BOTTOM' .. side, x, ARROW_OVERLAP)
  end
end

--- @param anchorTo Region
--- @return 'LEFT'|'RIGHT' @Arrow side: the one nearer the screen edge the target is on
function o:ArrowSide(anchorTo)
  local anchorX = anchorTo:GetCenter() * anchorTo:GetEffectiveScale()
  local screenX = UIParent:GetCenter() * UIParent:GetEffectiveScale()
  return anchorX < screenX and 'LEFT' or 'RIGHT'
end

--- @param anchorTo Region
--- @return number @Space between anchorTo's top and the screen top, in this tip's units
function o:RoomAbove(anchorTo)
  local screenTop = UIParent:GetTop() * UIParent:GetEffectiveScale()
  local anchorTop = anchorTo:GetTop() * anchorTo:GetEffectiveScale()
  return (screenTop - anchorTop) / self:GetEffectiveScale()
end
