--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local LibStub = LibStub

local silent = true

--@do-not-package@
if ns:IsDev() then silent = false end
--@end-do-not-package@

--- Locale name is ns.name (LibIconPicker) so it won't conflict with
--- main addon if embedded.
local L = LibStub('AceLocale-3.0'):NewLocale(ns.name, 'enUS', true, silent);

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
