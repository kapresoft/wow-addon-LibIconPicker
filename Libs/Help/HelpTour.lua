--[[-----------------------------------------------------------------------------
HelpTour: the icon picker's LibHelpTour controller.

Keeps the saved fields the picker used before the library, so existing users
don't see tours again.
@see TourList.lua
-------------------------------------------------------------------------------]]
--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end
local L = ns:GetLocale()
local TourList = ns.O.TourList
local HelpTourLib = LibStub('LibHelpTour-1.0')

ns.O.HelpTour = HelpTourLib:New({
  tours = TourList,
  dismissed = function() return ns:GetHelpTips() end,
  getBaseline = function() return ns:GetHelpTips().tourBaseline end,
  setBaseline = function(baseline) ns:GetHelpTips().tourBaseline = baseline end,
  text = function(textKey) return L[textKey] end,
})
