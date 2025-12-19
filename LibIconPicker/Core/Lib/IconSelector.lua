--- @type LibIconPickerNamespace
local ns = select(2, ...)

local LSM = LibStub("LibSharedMedia-3.0")
local emptyTexture = [[Interface\Addons\LibIconPicker\Core\Assets\ui-button-empty]]

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local HybridScrollFrame_Update = HybridScrollFrame_Update
local HybridScrollFrame_GetOffset = HybridScrollFrame_GetOffset
local HybridScrollFrame_CreateButtons = HybridScrollFrame_CreateButtons
--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
--- @class IconSelector
--- @field scrollFrame Frame
--- @field selectedIconButton Button
LibIconPicker_IconSelectorMixin = {}

--- @type IconSelector | Frame
local S = LibIconPicker_IconSelectorMixin
local p = ns:Log('IconSelector')

-- Settings
local ICON_SIZE = 32
local ICON_PAD = 6
local ICON_COLS = 10
local ROW_HEIGHT = ICON_SIZE + ICON_PAD
local ROW_WIDTH =
(ICON_COLS * ICON_SIZE) +
        ((ICON_COLS - 1) * ICON_PAD)

-- The button padding
local GRID_PADDING_LEFT = 0
local ROW_PADDING_LEFT = 5
local ROW_PADDING_TOP = 0

local MAX_BUTTONS = 200   -- cap regardless of scroll area height
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @type Button
local function selectedIconButton() return ns.O.IconSelector.SelectedIconButton end


--- @class _IconButton
--- @field icon Texture

--- Alias: IconButton
--- @alias IconButton _IconButton | Button

--[[-----------------------------------------------------------------------------
Handlers
-------------------------------------------------------------------------------]]
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
        if type(LIB_ICON_ID) == 'number' then
            selectedIconButton():SetNormalTexture(LIB_ICON_ID)
        end

        if col == 1 then
            b:SetPoint("LEFT", self, "LEFT", GRID_PADDING_LEFT, 0)
        else
            b:SetPoint("LEFT", self[col-1], "RIGHT", ICON_PAD, 0)
        end

        ---@param self IconButton
        b:SetScript("OnClick", function(self)
            --- @type number
            local tex = self.icon:GetTexture()
            selectedIconButton():SetNormalTexture(tex)
            LIB_ICON_ID = tex
            if S.callback then
                S.callback(self.icon)
            end
        end)

        self[col] = b
    end
end

-- -----------------------------------------------------
-- PUBLIC API
-- -----------------------------------------------------
function S:OnLoad()

    local firstRow = self.FirstRow
    self.selectedIconButton = firstRow.SelectedIconButton

    self.HeaderTitle:SetText("Icon Picker")

    --- @type ScrollFrame
    self.scrollFrame = self.ScrollBox
    --- @type Button
    self.SelectedIconButton = self.FirstRow.SelectedIconButton
    C_Timer.After(1, function()
        p('Selected:', self.SelectedIconButton)
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
end

function S:ShowDialog(callback)
    if InCombatLockdown() then return end

    self.callback = callback

    -- reload icons
    self.icons = ns.iconDataProvider:GetIcons()
    self.filtered = self.icons

    local showTextField = false
    if not showTextField then
        --self.FirstRow:ClearAllPoints()
        --self.FirstRow:SetHeight(40)
        --self.FirstRow.Label:Hide()
        --self.FirstRow.EditBox:Hide()
        --self.scrollFrame:ClearAllPoints()
    end

    self:InitGrid()
    self:Show()
end

function S:OnClickClose() self:Hide() end

function S:OnClickOkay()
    print(self:GetName() .. '::', 'OK clicked')
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
    local icons = self.filtered
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
                    b.icon:SetTexture(tex)
                    b:Show()
                else
                    b:Hide()
                end
            end
        end
    end

    local contentHeight = rows * ROW_HEIGHT
    self.scrollFrame.scrollChild:SetHeight(contentHeight)

    p('offset:', offset, 'visibleRows:', visibleRows, 'cHeight:', contentHeight, 'rows:', rows)

    HybridScrollFrame_Update(
            self.scrollFrame,
            contentHeight,
            self.scrollFrame:GetHeight()
    )
end


