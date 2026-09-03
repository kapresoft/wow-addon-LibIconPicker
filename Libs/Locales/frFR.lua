--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

local L = ns:NewLocale('frFR'); if not L then return end

--[[-----------------------------------------------------------------------------
Localized Texts
-------------------------------------------------------------------------------]]
L['General']       = 'Général'
L['Icon Picker']   = "Sélecteur d'icônes"
L['Name']          = 'Nom'
L['Max']           = 'Max'
L['Characters']    = 'Caractères'
L['Selected Icon'] = 'Icône sélectionnée'
L['Selected Icon::Desc'] = "Affiche l'icône sélectionnée le plus récemment. Votre choix précédent est mémorisé pour cette session."
L['All Icons']     = 'Toutes les icônes'
L['Items']         = 'Objets'
L['Spells']        = 'Sorts'
