--- @type LibIconPickerNamespace
local ns = select(2, ...)

--- @class IconDataProvider
ns.iconDataProvider = {}
local S = ns.iconDataProvider
local p = ns:Log('IconSelectorProvider')
local provider = nil


-- -----------------------------------------------------
-- Initialize unified provider on first use
-- -----------------------------------------------------
--- @param whichIcon IconTypeFilter
local function EnsureProvider(whichIcon)
    --if provider then return end

    local requestedTypes = {}
    if not (whichIcon == 'spell' or whichIcon == 'item') then
        requestedTypes = IconDataProvider_GetAllIconTypes()
    elseif 'spell' == whichIcon then
        table.insert(requestedTypes, IconDataProviderIconType.Spell)
    elseif 'item' == whichIcon then
        table.insert(requestedTypes, IconDataProviderIconType.Item)
    end

    -- ## SEE: IconDataProvider.lua#IconDataProviderMixin:Init(type, extraIconsOnly, requestedIconTypes)
    -- type: IconDataProviderExtraType.Spellbook or IconDataProviderExtraType.Equipment
    -- extraIconsOnly: true means only return player items/equip
    provider = CreateAndInitFromMixin(
            IconDataProviderMixin, IconDataProviderExtraType.Spellbook, false, requestedTypes)
end

-- -----------------------------------------------------
-- Return unified icon list
-- -----------------------------------------------------
--- @param whichIcon IconTypeFilter
function S:GetIcons(whichIcon)
    EnsureProvider(whichIcon)

    local icons = {}
    local total = provider:GetNumIcons()
    p('totalIcons:', total)
    for i = 1, total do
        icons[i] = provider:GetIconByIndex(i)
    end

    return icons
end
