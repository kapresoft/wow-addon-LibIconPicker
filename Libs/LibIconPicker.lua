--- @type LibIconPickerNamespace
local ns = select(2, ...)
local d = ns.O.IconSelector
local p = ns:Log('A')
local GetAddOnMetadata = C_AddOns.GetAddOnMetadata or GetAddOnMetadata

--[[-----------------------------------------------------------------------------
Vars
-------------------------------------------------------------------------------]]
local GetAddOnInfo = C_AddOns.GetAddOnInfo or GetAddOnInfo

--- @type LibStub
local LibStub = LibStub


--[[-----------------------------------------------------------------------------
LibIconPicker
-------------------------------------------------------------------------------]]
-- LibIconPicker-1.0
local MAJOR, MINOR = "LibIconPicker-1.0", 1

--- @class LibIconPicker
local A = LibStub:NewLibrary(MAJOR, MINOR); if not A then return end
LibIconPicker = A

--- @param callback LibIconPicker_CallbackFn
--- @param options LibIconPicker_Options|nil
function A:Open(callback, options)
    assert(type(callback) == 'function', 'A callback function is required. Usage:: LibIconPicker(function(sel) end, options)')
    local opt = options or { type = 'both', showTextInput = false, }
    d:ShowDialog(callback, opt)
end

function A:Close() d:Hide() end

function A:Info()
    local interfaceVersion = GetAddOnMetadata("LibIconPicker", "Interface")
    local version = GetAddOnMetadata(ns.addon, "Version")
    local author  = GetAddOnMetadata(ns.addon, "Author")
    local relDate = GetAddOnMetadata(ns.addon, 'X-Github-Project-Last-Changed-Date')
    local repo = GetAddOnMetadata(ns.addon, 'X-Github-Repo')
    local cf = GetAddOnMetadata(ns.addon, 'X-CurseForge')
    local wowVersion, build, date, tocVersion = GetBuildInfo()

    local color1 = CreateColorFromHexString("ff32CF21")
    local color2 = CreateColorFromHexString('ffFBF879')
    local c1 = function(txt) return color1:WrapTextInColorCode(txt) end
    local c2 = function(txt) return color2:WrapTextInColorCode(txt) end
    local nameLabel, versionLabel = c2('Name:'), c2('Version:')
    print(ns.sformat('%s %s %s %s', nameLabel, c1(ns.addon), versionLabel, version))
    print(c2('Author:'), author)
    print(c2('Last-Changed-Date:'), c2(relDate))
    print(c2('Repo:'), repo)
    print(c2('Curse-Forge:'), cf)
    print(c2('Wow Client Version:'), wowVersion, c2('TOC:'), tocVersion)
end
