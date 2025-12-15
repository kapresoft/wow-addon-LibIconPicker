--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local sformat, upper, date = string.format, string.upper, date

--- @type LibIconPickerNamespace
local ns = select(2, ...)
ns.settings.developer = true

local pp = ns:Log('DevSetup')

C_Timer.After(0.5, function()
    pp('IsDev:', ns)
end)
