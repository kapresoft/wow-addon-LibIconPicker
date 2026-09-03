--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

local L = ns:NewLocale('ptBR'); if not L then return end

--[[-----------------------------------------------------------------------------
Localized Texts
-------------------------------------------------------------------------------]]
L['General']       = 'Geral'
L['Icon Picker']   = 'Seletor de ícones'
L['Name']          = 'Nome'
L['Max']           = 'Máx'
L['Characters']    = 'Caracteres'
L['Selected Icon'] = 'Ícone selecionado'
L['Selected Icon::Desc'] = 'Mostra o ícone selecionado mais recentemente. Sua escolha anterior é lembrada durante esta sessão.'
L['All Icons']     = 'Todos os ícones'
L['Items']         = 'Itens'
L['Spells']        = 'Feitiços'
