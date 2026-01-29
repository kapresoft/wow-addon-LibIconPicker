-- if LibIconPicker exists, it's already been loaded
if LibIconPicker then return end

--- @type string
local addon

--- @class PrivateNamespace
--- @field LibIconPicker LibIconPickerNamespace
local parentNs

--- @class LibIconPickerNamespace
--- @field addon string The addon name; note that this may be different when embedded
--- @field name string The library name
--- @field O NamespaceObjects
--- @field backdrops table<string, table>
--- @field iconDataProvider IconDataProvider
local ns = {}

addon, parentNs = ...; parentNs.LibIconPicker = ns


--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
LIP_NS = ns

--[[-----------------------------------------------------------------------------
Type: DebugSettings
Override in DeveloperSetup to enable
-------------------------------------------------------------------------------]]
--- @class LibIconPickerSettings
--- @field developer boolean if true: enables developer mode
local settings = { developer = false }

--[[-----------------------------------------------------------------------------
NamespaceObjects
-------------------------------------------------------------------------------]]
---@param o NamespaceObjects
local function NSO(o)
    o.AceLocale = LibStub("AceLocale-3.0")
end

--[[-----------------------------------------------------------------------------
Namespace Methods
-------------------------------------------------------------------------------]]
do
  ns.name     = 'LibIconPicker'
  ns.addon    = addon
  ns.sformat  = string.format
  ns.settings = settings
  ns.O        = {}; NSO(ns.O)
  
  --- @return boolean
  function ns:IsDev() return ns.settings.developer == true end

end


