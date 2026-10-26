--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

local L = ns:NewLocale('ruRU'); if not L then return end

--[[-----------------------------------------------------------------------------
Localized Texts
-------------------------------------------------------------------------------]]
L['General'] = 'Общее'
L['Icon Picker'] = 'Выбор значка'
L['Name'] = 'Имя'
L['Max'] = 'Макс'
L['Characters'] = 'Символов'
L['Selected Icon'] = 'Выбранный значок'
L['Selected Icon::Desc'] =
  'Показывает последний выбранный значок. Ваш предыдущий выбор запоминается в течение этой сессии.'
L['Selected Icon::DragHint'] =
  'Также можно перетащить сюда значок из книги заклинаний, сумок или откуда-нибудь ещё.'
L['All Icons'] = 'Все значки'
L['Items'] = 'Предметы'
L['Spells'] = 'Заклинания'
L['Recent Icons'] = 'Недавние значки'
L['No Recent Icons'] = 'Нет недавних значков'
L['Recent Icons::Tip'] =
  'Используйте недавно выбранный значок снова.'
