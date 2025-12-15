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
L['General'] = true
