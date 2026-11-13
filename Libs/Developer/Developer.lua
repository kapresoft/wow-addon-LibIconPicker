--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

-- The old GetAddOnEnableState requires the second arg 'character'
local GetAddOnEnableState = C_AddOns.GetAddOnEnableState or GetAddOnEnableState
local LoadAddOn = C_AddOns.LoadAddOn or LoadAddOn
local EnableAddOn = C_AddOns.EnableAddOn or EnableAddOn

local libName = 'Developer'
local tr = ns.tr

--[[-------------------------------------------------------------------
Developer
---------------------------------------------------------------------]]
--- @class Developer
local o = {}; lipd = o

--- Get LibIconPicker instance
--- The global var `LibIconPicker` is available if the addon is already loaded.
--- @return LibIconPicker?
function o:LIP()
  if LibIconPicker then return LibIconPicker end

  EnableAddOn(libName, UnitName('player'))
  local status, msg = LoadAddOn(libName)
  if not status then
    tr(('LoadAddOn(%q) failed with status=%s; msg=%s'):format(libName, status, msg))
    return nil
  end

  return LibIconPicker
end

--- Pulses the found-icon outline on a visible list icon.
--- Open the icon picker first.
--- ### Example:
--- ```lua
--- lipd:PulseIcon(3, 4)
--- ```
--- @param row number? @Visible row, default 1
--- @param col number? @Default 1
function o:PulseIcon(row, col)
  local selector = ns.O.IconSelector
  if not (selector and selector:IsShown()) then return print('Open the icon picker first.') end
  local rowFrame = selector.ScrollFrame.buttons[row or 1]
  local button = rowFrame and rowFrame[col or 1]
  if not (button and button:IsShown()) then return print('No visible icon there.') end
  button:PlayFoundPulse()
  print('Pulsing icon', button:GetIcon())
end

C_Timer.After(1, function() tr(libName, 'loaded', 'isDev=', ns:IsDev()) end)
