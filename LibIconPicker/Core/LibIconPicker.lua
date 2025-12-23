--- @type LibIconPickerNamespace
local ns = select(2, ...)
local p = ns:Log('A')

--- @type LibStub
local LibStub = LibStub

-- LibIconPicker-1.0
local MAJOR, MINOR = "LibIconPicker-1.0", 1

--- @class LibIconPicker
local A = LibStub:NewLibrary(MAJOR, MINOR); if not A then return end
LibIconPicker = A

--- @param callback LibIconPicker_CallbackFn
--- @param options LibIconPicker_Options|nil
function A:Open(callback, options)
    assert(type(callback) == 'function', 'A callback function is required. Usage:: LibIconPicker(function(sel) end, options)')
    local opt = options or { type = 'both', showTextInput = false, }
    ns.O.IconSelector:ShowDialog(callback, opt)
end





