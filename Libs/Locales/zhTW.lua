--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

local L = ns:NewLocale('zhTW'); if not L then return end

--[[-----------------------------------------------------------------------------
Localized Texts
-------------------------------------------------------------------------------]]
L['General']       = '一般'
L['Icon Picker']   = '圖示選擇器'
L['Name']          = '名稱'
L['Max']           = '最大'
L['Characters']    = '字元'
L['Selected Icon'] = '已選圖示'
L['Selected Icon::Desc'] = '顯示最近選擇的圖示。您先前的選擇會在此次工作階段中保留。'
L['All Icons']     = '所有圖示'
L['Items']         = '物品'
L['Spells']        = '法術'
