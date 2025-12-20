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
LibIconPicker = {}; local A = LibIconPicker
local p = ns:Log('A')

function A:Open()
    local opt = { type = 'item', showTextInput = true, }
    ns.O.IconSelector:ShowDialog(function(sel)
        p('Selected:', sel.iconID)
    end, opt)
end
function A:Open2()
    local opt = { type = 'item', showTextInput = false, }
    ns.O.IconSelector:ShowDialog(function(sel)
        p('Selected:', sel.iconID)
    end, opt)
end

C_Timer.After(.5, function()
    A:Open2()
end)




