--- @type LibIconPickerNamespace
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GameTooltip = GameTooltip
local HybridScrollFrame_Update = HybridScrollFrame_Update
local HybridScrollFrame_GetOffset = HybridScrollFrame_GetOffset
local HybridScrollFrame_CreateButtons = HybridScrollFrame_CreateButtons

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
--- @class IconSelector_Mixin
--- @field icons table<number, number>
--- @field scrollFrame Frame
--- @field firstRow Frame
--- @field selectedIconButton Button
LibIconPicker_IconSelectorMixin = {}
--[[-----------------------------------------------------------------------------
Alias
-------------------------------------------------------------------------------]]
--- @alias IconSelector IconSelector_Mixin | Frame

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @type IconSelector_Mixin | Frame
local S = LibIconPicker_IconSelectorMixin
local p = ns:Log('IconSelector')

local L = ns.O.AceLocale:GetLocale(ns.addon)
local FIRST_ROW_HEIGHT = 80
local FIRST_ROW_HEIGHT_NO_TEXT_FIELD = 65


--- @type Frame
local firstRow

--- @type IconButton
local selectedIconBtn
local selectedIconID
--- @type LibIconPickerOptions
local selectorOptions = {
    showTextInput = false,
    textInput = { value = nil, label = 'Enter Name (Max 16 Characters):'}
}

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
Handlers
-------------------------------------------------------------------------------]]
--- @param self IconButton
local function OnClickIconItem(self)
    selectedIconBtn:SetIcon(self:GetIcon())
end

-- -----------------------------------------------------
-- ROW TEMPLATE POPULATION (called by CreateButtons)
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

function S:InitTooltips()
    local button = self.SelectedIconButton
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L['Selected Icon'])
        GameTooltip:AddLine(L['Selected Icon::Desc'], 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

-- -----------------------------------------------------
-- PUBLIC API
-- -----------------------------------------------------
function S:OnLoad()

    firstRow        = self.FirstRow
    selectedIconBtn = firstRow.SelectedIconButton

    self.HeaderTitle:SetText("Icon Picker")

    --- @type ScrollFrame
    self.scrollFrame = self.ScrollBox
    --- @type Button
    self.SelectedIconButton = self.FirstRow.SelectedIconButton
    C_Timer.After(1, function()
        p('Selected:', self.SelectedIconButton.icon:GetTexture())
    end)

    self:SetBackdrop(ns.backdrops.modernDark)

    local scrollBar = self.scrollFrame.scrollBar
    scrollBar:HookScript("OnValueChanged", function()
        C_Timer.After(0, function()
            self:Redraw()
        end)
    end)

    self.scrollFrame:SetScript("OnMouseWheel", function(sf, delta)
        HybridScrollFrame_OnMouseWheel(sf, delta)
    end)
    ns.O.IconSelector = self
    firstRow.Label:SetText("Name:")

    tinsert(UISpecialFrames, self:GetName())
    self:InitTooltips()
end

--- @param callback LibIconChooserCallbackFn
--- @param opt LibIconPickerOptions|nil
function S:ShowDialog(callback, opt)
    if InCombatLockdown() then return end

    if type(LIB_ICON_ID) == 'number' then
        selectedIconBtn:SetIcon(LIB_ICON_ID)
    end

    if type(callback) == 'function' then
        self.callbackInfo = { callback = callback, opt = opt }
    end
    if type(opt) == 'table' then
        if type(opt.showTextInput) == 'boolean' then
            selectorOptions.showTextInput = opt.showTextInput
        end
        if pformat then
            p('selectorOptions:', pformat(opt))
        end
    end

    self:_ToggleFirstRow()

    -- reload icons
    self.icons = ns.iconDataProvider:GetIcons()
    self:InitGrid()
    self:Show()
end

--- @private
function S:_ToggleFirstRow()
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

function S:OnClickClose() self:Hide() end

function S:OnClickOkay()
    print(self:GetName() .. '::', 'OK clicked')
    if self.callbackInfo then
        local fn = self.callbackInfo.callback
        local icon = selectedIconBtn:GetIcon()
        LIB_ICON_ID = icon
        fn({ iconID =  icon })
        return self:Hide()
    end
    self:Hide()
end
function S:OnClickCancel()
    print(self:GetName() .. '::', 'Cancel clicked')
    self:Hide()
end

-- -----------------------------------------------------
-- GRID INITIALIZATION
-- -----------------------------------------------------
function S:InitGrid()
    if not self.scrollFrame.buttons then
        HybridScrollFrame_CreateButtons(self.scrollFrame, "LibIconPicker_IconRowTemplate", ROW_HEIGHT, 0)
    end
    self:Redraw()
end

function S:ResetRowPoints(row, rowIndex)
    row:ClearAllPoints()
    if rowIndex == 1 then
        row:SetPoint("TOPLEFT", self.scrollFrame.scrollChild, "TOPLEFT", ROW_PADDING_LEFT, ROW_PADDING_TOP)
    else
        row:SetPoint("TOPLEFT", self.scrollFrame.buttons[rowIndex-1], "BOTTOMLEFT", 0, 0)
    end
end

-- -----------------------------------------------------
-- VIRTUAL SCROLL UPDATE
-- -----------------------------------------------------
function S:Redraw()
    local icons = self.icons
    local total = #icons
    local rows = math.ceil(total / ICON_COLS)

    local offset = HybridScrollFrame_GetOffset(self.scrollFrame)
    local visibleRows = #self.scrollFrame.buttons

    for rowIndex = 1, visibleRows do
        local row = self.scrollFrame.buttons[rowIndex]

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
    self.scrollFrame.scrollChild:SetHeight(contentHeight)

    p('total:', total, 'offset:', offset, 'visibleRows:', visibleRows,
      'cHeight:', contentHeight, 'rows:', rows)

    HybridScrollFrame_Update(
            self.scrollFrame,
            contentHeight,
            self.scrollFrame:GetHeight()
    )
end
