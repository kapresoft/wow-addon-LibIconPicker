--- @type LibIconPickerNamespace
local ns = select(2, ...)
local O = ns.O

--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- @alias IconSelector IconSelector_Mixin | Frame
--- @alias IconScrollFrame _IconScrollFrame | ScrollFrame

--- @class FirstRow
--- @field IconTypeDropdown Frame
--- @field Label FontString

--- @class _IconScrollFrame
--- @field scrollChild ScrollChild
--- @field scrollBar Slider
--- @field buttons table<number, IconButton>

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip = GameTooltip
local HybridScrollFrame_Update = HybridScrollFrame_Update
local HybridScrollFrame_GetOffset = HybridScrollFrame_GetOffset
local HybridScrollFrame_CreateButtons = HybridScrollFrame_CreateButtons

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local L = O.AceLocale:GetLocale(ns.addon)

local FIRST_ROW_HEIGHT = 80
local FIRST_ROW_HEIGHT_NO_TEXT_FIELD = 65

--- @type table<number, number>
local icons

--- @type FirstRow
local firstRow
--- @type Frame
local dropdown

--- @type IconScrollFrame
local scrollFrame
--- @type IconButton
local selectedIconBtn
local selectedIconID
--- @type LibIconPicker_Options
local selectorOptions = {
    showTextInput = false,
    textInput = { value = nil, label = nil },
    anchor = { point = 'CENTER', relativeTo = UIParent, relativePoint = 'CENTER', x = 0, y = 0 }
}
--- @type LibIconPicker_CallbackInfo
local callbackInfo

-- Settings
local ICON_SIZE = 32
local ICON_PAD = 6
local ICON_COLS = 10
local ROW_HEIGHT = ICON_SIZE + ICON_PAD

-- The button padding
local GRID_PADDING_LEFT = 0
local ROW_PADDING_LEFT = 5
local ROW_PADDING_TOP = 0

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
--- @class IconSelector_Mixin
--- @field private _lastOffset number
--- @field icons table<number, number>
--- @field ScrollFrame Frame
--- @field FirstRow FirstRow
--- @field HeaderTitle FontString
LibIconPicker_IconSelectorMixin = {}

--- @type IconSelector_Mixin | Frame
local S = LibIconPicker_IconSelectorMixin
local p = ns:Log('IconSelector')

--[[-----------------------------------------------------------------------------
Handlers
-------------------------------------------------------------------------------]]
--- @param self IconButton
local function OnClickIconItem(self)
    selectedIconBtn:SetIcon(self:GetIcon())
end

-- -----------------------------------------------------
-- Row Template Population (called by CreateButtons)
-- -----------------------------------------------------
--- @param self Frame The frame of the row
function S.OnLoadRow(self)
    self:SetHeight(ROW_HEIGHT)

    -- Each row gets 12 icon buttons
    for col = 1, ICON_COLS do
        --- @type IconButton
        local b = CreateFrame("Button", nil, self, "LibIconPicker_IconButtonTemplate")
        b:SetSize(ICON_SIZE, ICON_SIZE)

        if col == 1 then
            b:SetPoint("LEFT", self, "LEFT", GRID_PADDING_LEFT, 0)
        else
            b:SetPoint("LEFT", self[col-1], "RIGHT", ICON_PAD, 0)
        end
        b:SetScript("OnClick", OnClickIconItem)
        self[col] = b
    end
end

-- -----------------------------------------------------
-- Methods
-- -----------------------------------------------------
function S:OnLoad()

    firstRow        = self.FirstRow
    selectedIconBtn = firstRow.SelectedIconButton

    self.HeaderTitle:SetText(L['Icon Picker'])
    local maxText = ns.sformat('%s %s %s', L['Max'], 16, L['Characters'])
    local labelText = ns.sformat('%s (%s):', L['Name'], maxText)
    firstRow.Label:SetText(labelText)

    --- @type _IconScrollFrame
    scrollFrame = self.ScrollFrame

    C_Timer.After(1, function()
        p('Selected:', selectedIconBtn:GetIcon())
    end)

    self:SetBackdrop(ns.backdrops.modernDark)

    local scrollBar = scrollFrame.scrollBar
    scrollBar:HookScript("OnValueChanged", function()
        local offset = HybridScrollFrame_GetOffset(scrollFrame)
        -- Prevent redraw at the top or end of scroll: offset didn't change
        if offset == self._lastOffset then return end
        self._lastOffset = offset
        self:RedrawDelayed()
    end)

    scrollFrame:SetScript("OnMouseWheel", function(sf, delta)
        HybridScrollFrame_OnMouseWheel(sf, delta)
    end)
    ns.O.IconSelector = self

    self:OnInit()
end

--- @private
function S:OnInit()
    tinsert(UISpecialFrames, self:GetName())
    self:InitTooltips()
    self:InitIconTypeDropdown()
end

--- @return table<number, number>
function S:GetIcons()
    local selValue = UIDropDownMenu_GetSelectedValue(dropdown)
    return ns.iconDataProvider:GetIcons(selValue)
end

--- @param callback LibIconPicker_CallbackFn
--- @param opt LibIconPicker_Options|nil
function S:ShowDialog(callback, opt)
    if InCombatLockdown() then return end

    local icon = 134400
    if type(opt.icon) == 'number' then icon = opt.icon end
    selectedIconBtn:SetIcon(opt.icon)

    if type(callback) == 'function' then
        callbackInfo = { callback = callback, opt = opt }
    end
    if type(opt) == 'table' then
        selectorOptions.showTextInput = opt.showTextInput == true
    end
    self:OnToggleFirstRow()

    icons = self:GetIcons()
    self:InitGrid()

    local anchor = opt.anchor
    if anchor then
        anchor.x = type(anchor.x) == 'number' and anchor.x or 0
        anchor.y = type(anchor.y) == 'number' and anchor.y or 0
        self:ClearAllPoints()
        local fmt = 'ShowDialog::anchor point=%s, relativeTo=%s, relativePoint=%s, x=%s, y=%s'
        p(ns.sformat(fmt, tostring(anchor.point), tostring(anchor.x), tostring(anchor.y),
                         tostring(anchor.relativeTo), tostring(anchor.relativePoint)))
        self:SetPoint(anchor.point, anchor.relativeTo, anchor.relativePoint, anchor.x, anchor.y)
    end
    self:Show()
end

--- @private
function S:OnToggleFirstRow()
    local showTextInput = selectorOptions.showTextInput
    local firstRowHeight = FIRST_ROW_HEIGHT
    if not showTextInput then
        firstRowHeight = FIRST_ROW_HEIGHT_NO_TEXT_FIELD
        firstRow.Label:Hide()
        firstRow.EditBox:Hide()
    else
        firstRow.Label:Show()
        firstRow.EditBox:Show()
    end
    firstRow:SetHeight(firstRowHeight)
end

--- @private
function S:OnClickClose() self:Hide() end

--- @private
function S:OnClickOkay()
    print(self:GetName() .. '::', 'OK clicked')
    if callbackInfo then
        local fn = callbackInfo.callback
        local icon = selectedIconBtn:GetIcon()
        fn({ iconID =  icon })
        return self:Hide()
    end
    self:Hide()
end

--- @private
function S:OnClickCancel()
    print(self:GetName() .. '::', 'Cancel clicked')
    self:Hide()
end

-- -----------------------------------------------------
-- Initialization
-- -----------------------------------------------------
--- @private
function S:InitGrid()
    if not scrollFrame.buttons then
        HybridScrollFrame_CreateButtons(scrollFrame, "LibIconPicker_IconRowTemplate", ROW_HEIGHT, 0)
    end
    self:RedrawDelayed()
end

--- @private
function S:InitTooltips()
    selectedIconBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L['Selected Icon'])
        GameTooltip:AddLine(L['Selected Icon::Desc'], 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    selectedIconBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

--- @private
function S:InitIconTypeDropdown()
    dropdown = firstRow.IconTypeDropdown
    dropdown.owner = self

    UIDropDownMenu_SetSelectedValue(dropdown, "both")
    UIDropDownMenu_SetWidth(dropdown, 100, 35)
    UIDropDownMenu_SetText(dropdown, "All Icons")

    UIDropDownMenu_SetAnchor(dropdown, 18, 10, "TOPLEFT", dropdown, "BOTTOMLEFT")

    UIDropDownMenu_Initialize(dropdown, function(frame, level)
        local sel = UIDropDownMenu_GetSelectedValue(dropdown)

        local function add(text, value)
            local info    = UIDropDownMenu_CreateInfo()
            info.text     = text
            info.value    = value
            info.owner    = dropdown.owner
            info.func     = S.OnClick_IconTypeDropdown
            info.checked  = (sel == value)
            info.minWidth = 112
            UIDropDownMenu_AddButton(info, level)
        end

        local prov = ns.iconDataProvider
        add("All Icons", prov.BOTH)
        add("Items", prov.ITEMS)
        add("Spells", prov.SPELLS)

    end)

end

--- @param self UIDropDownMenuButton
function S.OnClick_IconTypeDropdown(self)
    UIDropDownMenu_SetSelectedValue(dropdown, self.value)
    S:OnIconTypeChanged(self.value)
end

--- @private
--- @param iconType "'spells'" | "'items'" | "'both'"
--- @see IconDataProvider#{SPELLS, ITEMS, BOTH}
function S:OnIconTypeChanged(iconType)
    -- 1) Fetch new icons
    icons = self:GetIcons()

    -- 2) Reset scroll position (critical)
    scrollFrame:SetVerticalScroll(0)
    HybridScrollFrame_SetOffset(scrollFrame, 0)
    scrollFrame.scrollBar:SetValue(0)

    self:RedrawDelayed()
end

--- @private
function S:ResetRowPoints(row, rowIndex)
    row:ClearAllPoints()
    if rowIndex == 1 then
        row:SetPoint("TOPLEFT", scrollFrame.scrollChild, "TOPLEFT", ROW_PADDING_LEFT, ROW_PADDING_TOP)
    else
        row:SetPoint("TOPLEFT", scrollFrame.buttons[rowIndex-1], "BOTTOMLEFT", 0, 0)
    end
end

function S:RedrawDelayed()
    C_Timer.After(0.01, function() self:Redraw() end)
end

-- -----------------------------------------------------
-- Virtual Scroll Update
-- -----------------------------------------------------
--- @private
function S:Redraw()
    local total = #icons
    local rows = math.ceil(total / ICON_COLS)

    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local visibleRows = #scrollFrame.buttons

    for rowIndex = 1, visibleRows do
        local row = scrollFrame.buttons[rowIndex]

        self:ResetRowPoints(row, rowIndex)

        local virtualRow = rowIndex + offset

        if virtualRow > rows then
            row:Hide()
        else
            row:Show()

            for col = 1, ICON_COLS do
                local index = ((virtualRow - 1) * ICON_COLS) + col
                --- @type IconButton
                local b = row[col]

                if not b then break end
                if index <= total then
                    local tex = icons[index]
                    b:SetIcon(tex)
                    b:Show()
                else
                    b:Hide()
                end
            end
        end
    end

    local contentHeight = rows * ROW_HEIGHT
    scrollFrame.scrollChild:SetHeight(contentHeight)
    local selectedType = UIDropDownMenu_GetSelectedValue(dropdown)
    p(ns.sformat("Redraw:: total=%s, type=%s, offset=%s", total, selectedType, offset))

    HybridScrollFrame_Update(
            scrollFrame,
            contentHeight,
            scrollFrame:GetHeight()
    )
end
