--- @type LibIconPickerNamespace
local ns     = select(2, ...)

--- @class IconDataProvider
ns.iconDataProvider = {}
local L = ns.iconDataProvider
local p = ns:Log('IconSelectorProvider')
local provider = nil


-- -----------------------------------------------------
-- Initialize unified provider on first use
-- -----------------------------------------------------
local function EnsureProvider()
    if provider then return end

    provider = CreateAndInitFromMixin(
            IconDataProviderMixin
            -- adding these will filter player-only spells/items
            -- true means only return player items/equip
            --,IconDataProviderExtraType.Spellbook, true
            --,IconDataProviderExtraType.Equipment, true
    )
end


-- -----------------------------------------------------
-- Return unified icon list
-- -----------------------------------------------------
function L:GetIcons()
    EnsureProvider()

    local icons = {}
    local total = provider:GetNumIcons()
    p('totalIcons:', total)
    for i = 1, total do
        icons[i] = provider:GetIconByIndex(i)
    end

    return icons
end
