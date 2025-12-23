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

--- @param options LibIconPicker_Options|nil
function A:Open(options)
    local opt = options or { type = 'both', showTextInput = false, }
    ns.O.IconSelector:ShowDialog(function(sel)
        p('Selected:', sel.iconID)
    end, opt)
end





