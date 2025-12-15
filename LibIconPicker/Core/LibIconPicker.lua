--- @type string
local addon
--- @type LibIconPickerNamespace
local ns
addon, ns = ...

-- LibIconPicker-1.0
local MAJOR, MINOR = "LibIconPicker-1.0", 1

--- @type LibStub
local LibStub = LibStub


LibIconPicker = {}

C_Timer.After(0.5, function()
    print('xxx LibIconPicker::Core called...')
end)
