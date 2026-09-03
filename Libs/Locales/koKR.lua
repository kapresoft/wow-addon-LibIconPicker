--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

local L = ns:NewLocale('koKR'); if not L then return end

--[[-----------------------------------------------------------------------------
Localized Texts
-------------------------------------------------------------------------------]]
L['General']       = '일반'
L['Icon Picker']   = '아이콘 선택'
L['Name']          = '이름'
L['Max']           = '최대'
L['Characters']    = '글자'
L['Selected Icon'] = '선택된 아이콘'
L['Selected Icon::Desc'] = '가장 최근에 선택한 아이콘을 표시합니다. 이전 선택은 이 세션 동안 기억됩니다.'
L['All Icons']     = '모든 아이콘'
L['Items']         = '아이템'
L['Spells']        = '주문'
