--- @type LibIconPickerNamespace
local ns = select(2, ...)
local O = ns.O

--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- @alias IconSelector IconSelector_Mixin | Frame
--- @alias IconScrollFrame _IconScrollFrame | ScrollFrame

------ @class FirstRow
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

--- @type FirstRow
local firstRow
--- @type IconScrollFrame
local scrollFrame
--- @type IconButton
local selectedIconBtn
local selectedIconID
--- @type LibIconPickerOptions
local selectorOptions = {
    showTextInput = false,
    textInput = { value = nil, label = nil }
}
--- @type CallbackInfo
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
        C_Timer.After(0, function()
            self:Redraw()
        end)
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

--- @param callback LibIconPickerCallbackFn
--- @param opt LibIconPickerOptions|nil
function S:ShowDialog(callback, opt)
    if InCombatLockdown() then return end

    if type(LIB_ICON_ID) == 'number' then
        selectedIconBtn:SetIcon(LIB_ICON_ID)
    end

    if type(callback) == 'function' then
        callbackInfo = { callback = callback, opt = opt }
    end
    if type(opt) == 'table' then
        if type(opt.showTextInput) == 'boolean' then
            selectorOptions.showTextInput = opt.showTextInput
        end
        if pformat then
            p('selectorOptions:', pformat(opt))
        end
    end

    self:OnToggleFirstRow()

    -- reload icons
    self.icons = ns.iconDataProvider:GetIcons()
    self:InitGrid()
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
        LIB_ICON_ID = icon
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
    self:Redraw()
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
    self.iconTypeDropDown = firstRow.IconTypeDropdown
    p('xx iconTypeDropDown:', type(self.iconTypeDropDown))
    local dropdown = self.iconTypeDropDown; dropdown.owner = self

    UIDropDownMenu_SetSelectedValue(dropdown, "both")
    UIDropDownMenu_SetWidth(dropdown, 100, 35)
    UIDropDownMenu_SetText(dropdown, "All Icons")

    UIDropDownMenu_SetAnchor(dropdown, 18, 10, "TOPLEFT", dropdown, "BOTTOMLEFT")

    UIDropDownMenu_Initialize(dropdown, function(frame, level)
        local info = UIDropDownMenu_CreateInfo()

        info.func = IconTypeDropdown_OnClick
        info.minWidth = 112

        info.text = "All Icons"
        info.value = "both"
        UIDropDownMenu_AddButton(info)

        info.text = "Items"
        info.value = "item"
        UIDropDownMenu_AddButton(info)

        info.text = "Spells"
        info.value = "spell"
        UIDropDownMenu_AddButton(info)
    end)

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

-- -----------------------------------------------------
-- Virtual Scroll Update
-- -----------------------------------------------------
--- @private
function S:Redraw()
    local icons = self.icons
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

    p('total:', total, 'offset:', offset, 'visibleRows:', visibleRows,
      'cHeight:', contentHeight, 'rows:', rows)

    HybridScrollFrame_Update(
            scrollFrame,
            contentHeight,
            scrollFrame:GetHeight()
    )
end
