--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

local L = ns:NewLocale('zhCN'); if not L then return end

--[[-----------------------------------------------------------------------------
Localized Texts
-------------------------------------------------------------------------------]]
L['General']       = '常规'
L['Icon Picker']   = '图标选择器'
L['Name']          = '名称'
L['Max']           = '最大'
L['Characters']    = '字符'
L['Selected Icon'] = '已选图标'
L['Selected Icon::Desc'] = '显示最近选择的图标。您之前的选择会在本次会话中保留。'
L['All Icons']     = '所有图标'
L['Items']         = '物品'
L['Spells']        = '法术'
