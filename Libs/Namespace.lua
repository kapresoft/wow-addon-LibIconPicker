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

  --- Registers a non-default locale. Always isDefault=false, silent=true.
  --- @see AceLocale-3.0.NewLocale
  --- @param locale string Name of the locale to register, e.g. 'deDE', 'frFR', etc.
  --- @return table<string, boolean|string>? locale Locale Table to add localizations to, or nil if the current locale is not required.
  function ns:NewLocale(locale)
    return ns.O.AceLocale:NewLocale(ns.name, locale, false, true)
  end

  --- @see AceLocale-3.0.GetLocale
  --- @return table<string, boolean|string> locale The locale table for the current language.
  function ns:GetLocale()
    return ns.O.AceLocale:GetLocale(ns.name, true)
  end

  --[[-----------------------------------------------------------------------------
  Trace function: NoOp by default. This is enabled in DeveloperSetup (not deployed in release)
  -------------------------------------------------------------------------------]]
  --- @param prefix Name
  --- @param ... any
  function ns.tr(prefix, ...) end

end
