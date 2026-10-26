--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

local L = ns:NewLocale('frFR'); if not L then return end

--[[-----------------------------------------------------------------------------
Localized Texts
-------------------------------------------------------------------------------]]
L['General'] = 'Général'
L['Icon Picker'] = "Sélecteur d'icônes"
L['Name'] = 'Nom'
L['Max'] = 'Max'
L['Characters'] = 'Caractères'
L['Selected Icon'] = 'Icône sélectionnée'
L['Selected Icon::Desc'] =
  "Affiche l'icône sélectionnée le plus récemment. Votre choix précédent est mémorisé pour cette session."
L['Selected Icon::DragHint'] =
  "Vous pouvez aussi faire glisser une icône ici depuis votre grimoire, vos sacs ou n'importe où ailleurs."
L['All Icons'] = 'Toutes les icônes'
L['Items'] = 'Objets'
L['Spells'] = 'Sorts'
L['Recent Icons'] = 'Icônes récentes'
L['No Recent Icons'] = 'Aucune icône récente'
L['Recent Icons::Tip'] = 'Réutilisez une icône choisie récemment.'
