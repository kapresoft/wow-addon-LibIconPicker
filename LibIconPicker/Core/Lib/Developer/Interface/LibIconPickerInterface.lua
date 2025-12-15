--[[-----------------------------------------------------------------------------
LibIconPickerNamespace
-------------------------------------------------------------------------------]]
--- @alias GameVersion string | "'classic'" | "'tbc_classic'" | "'wotlk_classic'" | "'cataclysm_classic'" | "'mop_classic'" | "'retail'"

--- @class LibIconPickerNamespace
--- @field addon Name The name of the addon
--- @field sformat fun(formatString:string, ...:vararg) String format function
--- @field gameVersion GameVersion
--- @field settings LibIconPickerSettings
local ns = {}

--- @return boolean
function ns:IsDev() end
