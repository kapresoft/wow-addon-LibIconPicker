--- @type string
local addon
--- @type LibIconPickerNamespace
local ns
addon, ns = ...

ns.addon = addon
ns.sformat = string.format

-- LibIconPicker-1.0
local MAJOR, MINOR = "LibIconPicker-1.0", 1

--- @type LibStub
local LibStub  = LibStub

--[[-----------------------------------------------------------------------------
Type: DebugSettings
Override in DeveloperSetup to enable
-------------------------------------------------------------------------------]]
--- @class LibIconPickerSettings
--- @field developer boolean if true: enables developer mode
local settings = {
    developer = false,
}; ns.settings    = settings

--[[-----------------------------------------------------------------------------
Namespace Methods
-------------------------------------------------------------------------------]]
--- @return boolean
function ns:IsDev() return ns.settings.developer == true end



