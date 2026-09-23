--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

local L = ns:NewLocale('deDE'); if not L then return end

--[[-----------------------------------------------------------------------------
Localized Texts
-------------------------------------------------------------------------------]]
L['General']       = 'Allgemein'
L['Icon Picker']   = 'Symbolauswahl'
L['Name']          = 'Name'
L['Max']           = 'Max'
L['Characters']    = 'Zeichen'
L['Selected Icon'] = 'Ausgewähltes Symbol'
L['Selected Icon::Desc'] = 'Zeigt das zuletzt ausgewählte Symbol an. Deine vorherige Wahl wird für diese Sitzung gespeichert. Ziehe einen Gegenstand, Zauber, ein Makro oder Reittier hierher, um dessen Symbol zu verwenden.'
L['All Icons']     = 'Alle Symbole'
L['Items']         = 'Gegenstände'
L['Spells']        = 'Zauber'
