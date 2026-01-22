--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
--- @type LibStub
local LibStub = LibStub

--- @type LibIconPickerNamespace
local ns = select(2, ...)

local silent = true

--@do-not-package@
if ns:IsDev() then silent = false end
--@end-do-not-package@

local L = LibStub('AceLocale-3.0'):NewLocale(ns.addon, 'enUS', true, silent);

--[[-----------------------------------------------------------------------------
Localized Texts
-------------------------------------------------------------------------------]]
L['General']       = true
L['Icon Picker']   = true
L['Name']          = true
L['Max']           = true
L['Characters']    = true
L['Selected Icon'] = true
L['Selected Icon::Desc'] = 'Shows the most recently selected icon. Your previous choice is remembered for this session.'
