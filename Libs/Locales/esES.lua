--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

local L = ns:NewLocale('esES'); if not L then return end

--[[-----------------------------------------------------------------------------
Localized Texts
-------------------------------------------------------------------------------]]
L['General']       = 'General'
L['Icon Picker']   = 'Selector de iconos'
L['Name']          = 'Nombre'
L['Max']           = 'Máx'
L['Characters']    = 'Caracteres'
L['Selected Icon'] = 'Icono seleccionado'
L['Selected Icon::Desc'] = 'Muestra el icono seleccionado más recientemente. Tu elección anterior se recuerda durante esta sesión. Arrastra aquí un objeto, hechizo, macro o montura para usar su icono.'
L['All Icons']     = 'Todos los iconos'
L['Items']         = 'Objetos'
L['Spells']        = 'Hechizos'
