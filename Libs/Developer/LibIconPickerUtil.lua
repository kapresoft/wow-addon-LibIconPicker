--[[-------------------------------------------------------------------
LibIconPickerUtil: This is just a template implementation on to
properly load the on-demand library.
---------------------------------------------------------------------]]

--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
local libName = 'LibIconPicker'
-- The old GetAddOnEnableState requires the second arg 'character'
local GetAddOnEnableState = C_AddOns.GetAddOnEnableState or GetAddOnEnableState
local LoadAddOn   = C_AddOns.LoadAddOn or LoadAddOn
local EnableAddOn = C_AddOns.EnableAddOn or EnableAddOn

--[[-------------------------------------------------------------------
New Library
---------------------------------------------------------------------]]
--- @class LibIconPicker_LibIconPickerUtil
local o = {}; ns.O.LibIconPickerUtil = o

--[[-------------------------------------------------------------------
Methods
---------------------------------------------------------------------]]
--- Get LibIconPicker instance
--- The global var `LibIconPicker` is available if the addon is already loaded.
--- @return LibIconPicker?
function o:Instance()
  if LibIconPicker then return LibIconPicker end
  
  EnableAddOn(libName, UnitName('player'))
  local status, msg = C_AddOns.LoadAddOn(libName)
  if not status then
    print(('LoadAddOn(%q) failed with status=%s; msg=%s'):format(libName, status, msg))
    return nil
  end
  
  return LibIconPicker
end



