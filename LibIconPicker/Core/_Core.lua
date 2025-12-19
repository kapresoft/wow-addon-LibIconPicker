--- @type string
local addon
--- @class LibIconPickerNamespace
--- @field O NamespaceObjects
--- @field backdrops table<string, table>
local ns
addon, ns = ...

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
Namespace Methods
-------------------------------------------------------------------------------]]

--- @param n LibIconPickerNamespace
local function NamespaceMethods(n)

    n.addon = addon
    n.sformat = string.format
    n.settings = settings
    n.O = {}

    --- @return boolean
    function n:IsDev() return ns.settings.developer == true end

end; NamespaceMethods(ns)





