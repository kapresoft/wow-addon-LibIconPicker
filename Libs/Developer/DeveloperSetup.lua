--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end
ns.settings.developer = true

local libName = 'DeveloperSetup'
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local sformat, upper, date = string.format, string.upper, date
local tr = ns.tr

