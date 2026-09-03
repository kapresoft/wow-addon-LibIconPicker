--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

local L = ns:NewLocale('itIT'); if not L then return end

--[[-----------------------------------------------------------------------------
Localized Texts
-------------------------------------------------------------------------------]]
L['General']       = 'Generale'
L['Icon Picker']   = 'Selettore icone'
L['Name']          = 'Nome'
L['Max']           = 'Max'
L['Characters']    = 'Caratteri'
L['Selected Icon'] = 'Icona selezionata'
L['Selected Icon::Desc'] = "Mostra l'icona selezionata più di recente. La scelta precedente viene ricordata per questa sessione."
L['All Icons']     = 'Tutte le icone'
L['Items']         = 'Oggetti'
L['Spells']        = 'Incantesimi'
