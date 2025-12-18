--- @type string
local addon
--- @type LibIconPickerNamespace
local ns
addon, ns = ...

-- LibIconPicker-1.0
local MAJOR, MINOR = "LibIconPicker-1.0", 1

--- @type LibStub
local LibStub = LibStub

--- @class LibIconPicker
LibIconPicker = {}
local p = ns:Log('A')


C_Timer.After(1, function()
    p('loaded...')
end)
