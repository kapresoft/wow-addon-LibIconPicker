--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end
ns.settings.developer = true

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local sformat, upper, date = string.format, string.upper, date


local pp = ns:Log('DevSetup')

C_Timer.After(0.5, function()
    pp('IsDev:', ns:IsDev())
end)
