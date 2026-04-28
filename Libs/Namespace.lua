-- if LibIconPicker exists, it's already been loaded
if LibIconPicker then return end

--- @type string
local addon

--- @class LibIconPicker_PrivateNamespace
--- @field LibIconPicker LibIconPicker_Namespace
local parentNs

--- @class LibIconPicker_Namespace
--- @field addon string The addon name; note that this may be different when embedded
--- @field name string The library name
--- @field O LibIconPicker_NamespaceObjects
--- @field backdrops table<string, table>
--- @field iconDataProvider LibIconPicker_IconDataProvider
local ns = {}; LIP_NS = ns

addon, parentNs = ...; parentNs.LibIconPicker = ns

--[[-----------------------------------------------------------------------------
Type: DebugSettings
Override in DeveloperSetup to enable
-------------------------------------------------------------------------------]]
--- @class LibIconPicker_Settings
--- @field developer boolean if true: enables developer mode
local settings = { developer = false }

--[[-----------------------------------------------------------------------------
NoOp Logger by Default
-------------------------------------------------------------------------------]]
local noop = function() end

--- @param name Name The log name
--- @return LibIconPicker_LogFn
function ns.log(name) return noop end

--[[-----------------------------------------------------------------------------
LibIconPicker_NamespaceObjects
-------------------------------------------------------------------------------]]
---@param o LibIconPicker_NamespaceObjects
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

  --[[-----------------------------------------------------------------------------
  Trace function: NoOp by default. This is enabled in DeveloperSetup (not deployed in release)
  -------------------------------------------------------------------------------]]
  --- @param prefix Name
  --- @param ... any
  function ns.tr(prefix, ...) end

end
