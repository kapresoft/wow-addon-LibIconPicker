--- @type LibStub
local LibStub = LibStub

--- @type string
local addon
--- @type PrivateNamespace
local parentNs
--- @type LibIconPickerNamespace
local ns

addon, parentNs = ...

ns = parentNs.LibIconPicker; if not ns then return end

local L = LibStub("AceLocale-3.0"):GetLocale(ns.name)

-- General
LIB_ICON_PICKER_TITLE = addon

