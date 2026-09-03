--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local L = ns.O.AceLocale:NewLocale(ns.name, 'enUS', true, true); if not L then return end

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
L['All Icons']     = true
L['Items']         = true
L['Spells']        = true
