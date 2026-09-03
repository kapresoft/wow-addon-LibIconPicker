local LibStub = LibStub

--- @type string
local addon
--- @type LibIconPicker_PrivateNamespace
local parentNs
--- @type LibIconPicker_Namespace
local ns

addon, parentNs = ...

--- @type LibIconPicker_Namespace
ns = parentNs.LibIconPicker; if not ns then return end

local L = ns:GetLocale()

-- General
LIB_ICON_PICKER_TITLE = addon

