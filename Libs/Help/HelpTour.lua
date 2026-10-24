--[[-----------------------------------------------------------------------------
HelpTour: picks which tour step the icon picker's help tip shows.

One tour per session: the first eligible tour with unseen steps owns the
session until /reload, even after it finishes. A step's close button or
its action (CompleteStep) advances to the next step.
@see TourList.lua
-------------------------------------------------------------------------------]]
--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

--- @class LibIconPicker_HelpTourStep
--- @field key string                       @Key in LibIconPicker_HelpTips
--- @field textKey string                   @Locale key of the step text
--- @field anchor fun(host: Frame): Region? @Step is skipped while this is nil or hidden

--- @class LibIconPicker_HelpTourDef
--- @field id string
--- @field since number? @Feature tours only; nil means always eligible
--- @field steps LibIconPicker_HelpTourStep[]

--- @class LibIconPicker_HelpTourShowing
--- @field host Frame
--- @field tip LibIconPicker_HelpTip
--- @field step LibIconPicker_HelpTourStep

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @type LibIconPicker_HelpTourDef?
local sessionTour
--- @type LibIconPicker_HelpTourShowing?
local showing

--- @return LibIconPicker_HelpTips
local function Tips() return ns:GetHelpTips() end

--- @return number
local function HighestSince()
  local highest = 0
  for _, tour in ipairs(ns.O.TourList) do
    highest = math.max(highest, tour.since or 0)
  end
  return highest
end

--- Saved on the first open, so new users skip older feature tours.
--- @return number
local function Baseline()
  local tips = Tips()
  if not tips.tourBaseline then tips.tourBaseline = HighestSince() end
  return tips.tourBaseline
end

--- @param tour LibIconPicker_HelpTourDef
--- @return boolean
local function IsEligible(tour) return tour.since == nil or tour.since > Baseline() end

--- @param tour LibIconPicker_HelpTourDef
--- @return boolean
local function HasUnseenStep(tour)
  for _, step in ipairs(tour.steps) do
    if not Tips()[step.key] then return true end
  end
  return false
end

--- @param tour LibIconPicker_HelpTourDef
--- @param host Frame
--- @return number? @nil if every unseen step's anchor is missing or hidden
local function FirstShowableStep(tour, host)
  for index, step in ipairs(tour.steps) do
    if not Tips()[step.key] then
      local anchor = step.anchor(host)
      if anchor and anchor:IsVisible() then return index end
    end
  end
end

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class LibIconPicker_HelpTour
local o = {}; ns.O.HelpTour = o

--- @return LibIconPicker_HelpTourDef? @nil once no tour has unseen steps
function o:SessionTour()
  if sessionTour then return sessionTour end
  -- Save now; IsEligible skips it for tours without since
  Baseline()
  for _, tour in ipairs(ns.O.TourList) do
    if IsEligible(tour) and HasUnseenStep(tour) then
      sessionTour = tour
      break
    end
  end
  return sessionTour
end

--- Call once the host is shown; shows its next step or hides the tip.
--- @param host Frame
--- @param tip LibIconPicker_HelpTip
function o:OnHostShown(host, tip)
  local tour = self:SessionTour()
  local index = tour and FirstShowableStep(tour, host)
  if not index then
    showing = nil
    tip:Hide()
    return
  end
  local step = tour.steps[index]
  showing = { host = host, tip = tip, step = step }
  tip.onClose = function() self:CompleteStep(step.key) end
  tip:ShowStep(step.textKey, step.anchor(host), index, #tour.steps)
end

--- Marks a step done, e.g. when the user does what it points at;
--- advances if it's the step on screen.
--- @param key string
function o:CompleteStep(key)
  Tips()[key] = true
  if not (showing and showing.step.key == key) then return end
  self:OnHostShown(showing.host, showing.tip)
end
