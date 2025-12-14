--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- @alias GameVersion string | "'classic'" | "'tbc_classic'" | "'wotlk_classic'" | "'cataclysm_classic'" | "'mop_classic'" | "'retail'"

--- @class Namespace : Kapresoft_Base_Namespace
--- @field gameVersion GameVersion

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- @type string
local addon
--- @type Namespace
local ns
addon, ns = ...


LIB_ICON_PICKER = {}

C_Timer.After(0.5, function()
    print('xxx LibIconPicker::Core called...')
end)
