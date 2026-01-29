--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
--- @class LibIconPicker_IconDataProvider
ns.iconDataProvider = {}
local S = ns.iconDataProvider
local p = ns:Log('IconSelectorProvider')
local provider = nil

S.BOTH = 'both'
S.SPELLS = 'spells'
S.ITEMS = 'items'

-- -----------------------------------------------------
-- Initialize unified provider on first use
-- -----------------------------------------------------
--- @param whichIcon LibIconPicker_IconTypeFilter
local function EnsureProvider(whichIcon)
    --if provider then return end

    local requestedTypes = IconDataProvider_GetAllIconTypes()
    if S.SPELLS == whichIcon then
        requestedTypes = { IconDataProviderIconType.Spell }
    elseif S.ITEMS == whichIcon then
        requestedTypes = { IconDataProviderIconType.Item }
    end

    -- ## SEE: IconDataProvider.lua#IconDataProviderMixin:Init(type, extraIconsOnly, requestedIconTypes)
    -- type: IconDataProviderExtraType.Spellbook or IconDataProviderExtraType.Equipment
    -- extraIconsOnly: true means only return player items/equip
    provider = CreateAndInitFromMixin(
            IconDataProviderMixin, nil, false, requestedTypes)
end

-- -----------------------------------------------------
-- Return unified icon list
-- -----------------------------------------------------
--- @param whichIcon LibIconPicker_IconTypeFilter
--- @return table<number, number>
function S:GetIcons(whichIcon)
    EnsureProvider(whichIcon)

    --- @type table<number, number>
    local icons = {}
    local total = provider:GetNumIcons()
    for i = 1, total do
        icons[i] = provider:GetIconByIndex(i)
    end

    return icons
end
