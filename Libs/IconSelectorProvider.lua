--- @type LibIconPickerNamespace
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
--- @class IconDataProvider
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
--- @param whichIcon IconTypeFilter
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
--- @param whichIcon IconTypeFilter
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
