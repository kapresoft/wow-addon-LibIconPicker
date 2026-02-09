--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end
local O = ns.O

local strlenutf8 = strlenutf8
local tMergeWithDefaults = ns.O.Util.Table_MergeWithDefaults

--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- @alias LibIconPicker_IconSelector LibIconPicker_IconSelectorMixin | Frame
--- @alias LibIconPicker_IconScrollFrame _LibIconPicker_IconScrollFrame | ScrollFrame

--- @class LibIconPicker_FirstRow
--- @field IconTypeDropdown Frame
--- @field Label FontString
--- @field EditBox LibIconPicker_EditBox

--- @class _LibIconPicker_IconScrollFrame
--- @field scrollChild SimpleFrame
--- @field scrollBar Slider
--- @field buttons table<number, LibIconPicker_IconButton>

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
local L = O.AceLocale:GetLocale(ns.name)

local FIRST_ROW_HEIGHT = 80
local FIRST_ROW_HEIGHT_NO_TEXT_FIELD = 65

--- @type table<number, number>
local icons

--- @type LibIconPicker_FirstRow
local firstRow
--- @type Frame
local dropdown

--- @type LibIconPicker_IconScrollFrame
local scrollFrame
--- @type LibIconPicker_IconButton
local selectedIconBtn

local maxText = ns.sformat('%s %s %s', L['Max'], 16, L['Characters'])
local labelText = ns.sformat('%s (%s):', L['Name'], maxText)

-- For LibIconPicker_Options textInput.max
local NAME_FIELD_MAX_LIMIT = 100

--- Default Options
--- @type LibIconPicker_Options
local DEFAULT_ICON_PICKER_OPTIONS = {
    showTextInput = false,
    textInput = { value = '', label = labelText, min=1 },
    anchor = { point = 'CENTER', relativeTo = UIParent,
               relativePoint = 'CENTER', x = 0, y = 0 }
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
--- @class LibIconPicker_IconSelectorMixin
--- @field private _lastOffset number
--- @field icons table<number, number>
--- @field ScrollFrame Frame
--- @field FirstRow LibIconPicker_FirstRow
--- @field HeaderTitle FontString
LibIconPicker_IconSelectorMixin = {}

--- @type LibIconPicker_IconSelectorMixin | Frame
local S = LibIconPicker_IconSelectorMixin
local p = ns:Log('IconSelector')

--[[-----------------------------------------------------------------------------
Local Functions and Handlers
-------------------------------------------------------------------------------]]
--- @param self LibIconPicker_IconButton
local function OnClickIconItem(self)
    selectedIconBtn:SetIcon(self:GetIcon())
end
--- @param opt LibIconPicker_Options|nil
local function CreateOptions(opt) return tMergeWithDefaults(DEFAULT_ICON_PICKER_OPTIONS, opt) end

local function NormalizeTextInput(textInput)
  if type(textInput) ~= 'table' then return end
  
  local min, max = tonumber(textInput.min), tonumber(textInput.max)
  
  -- normalize max
  if not max or max < 1 then max = NAME_FIELD_MAX_LIMIT
  elseif max > NAME_FIELD_MAX_LIMIT then max = NAME_FIELD_MAX_LIMIT end
  -- normalize min
  if not min or min < 1 then min = 1
  elseif min > max then min = max end
  
  textInput.min = min
  textInput.max = max
end
-- -----------------------------------------------------
-- Row Template Population (called by CreateButtons)
-- -----------------------------------------------------
--- @param self Frame The frame of the row
function S.OnLoadRow(self)
    self:SetHeight(ROW_HEIGHT)

    -- Each row gets 12 icon buttons
    for col = 1, ICON_COLS do
        --- @type LibIconPicker_IconButton
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
    firstRow.Label:SetText(DEFAULT_ICON_PICKER_OPTIONS.textInput.label)

    --- @type _LibIconPicker_IconScrollFrame
    scrollFrame = self.ScrollFrame

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
--- @param _opt LibIconPicker_Options|nil
function S:ShowDialog(callback, _opt)
  if InCombatLockdown() then return end
  
  --- @type LibIconPicker_Options
  local opt = CreateOptions(_opt)
  opt.showTextInput = opt.showTextInput == true
  
  if not opt.textInput.label then
    opt.textInput.label = DEFAULT_ICON_PICKER_OPTIONS.textInput.label
  end
  
  local icon = 134400
  if type(opt.icon) == 'number' then icon = opt.icon end
  selectedIconBtn:SetIcon(opt.icon)
  
  if type(callback) == 'function' then
    callbackInfo = { callback = callback, opt = opt }
  end
  self:OnToggleFirstRow(opt)
  
  icons = self:GetIcons()
  self:InitGrid()
  
  firstRow.EditBox.opt = opt.textInput
  if opt.showTextInput == true then
    firstRow.EditBox:SetText(opt.textInput.value or '')
    firstRow.Label:SetText(opt.textInput.label)
    NormalizeTextInput(opt.textInput)
    firstRow.EditBox:SetMaxLetters(opt.textInput.max)
  end
  
  local anchor = opt.anchor
  if anchor then
    anchor.x = type(anchor.x) == 'number' and anchor.x or 0
    anchor.y = type(anchor.y) == 'number' and anchor.y or 0
    self:ClearAllPoints()
    self:SetPoint(anchor.point, anchor.relativeTo, anchor.relativePoint, anchor.x, anchor.y)
  end
  self:Show()
end

--- @private
--- @param opt LibIconPicker_Options
function S:OnToggleFirstRow(opt)
    local showTextInput = opt.showTextInput
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
    if callbackInfo then
        local fn = callbackInfo.callback
        local icon = selectedIconBtn:GetIcon()
        --- @type LibIconPicker_Selection
        local sel  = { icon = icon }
        if firstRow.EditBox:IsShown() then
            sel.textInputValue = firstRow.EditBox:GetText()
        end
        fn(sel)
        return self:Hide()
    end
    self:Hide()
end

--- @private
function S:OnClickCancel()
    p(self:GetName() .. '::', 'Cancel clicked')
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
--- @see LibIconPicker_IconDataProvider#{SPELLS, ITEMS, BOTH}
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
                --- @type LibIconPicker_IconButton
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
    if IsAltKeyDown() then
        p(ns.sformat("Redraw:: total=%s, type=%s, offset=%s", total, selectedType, offset))
    end

    HybridScrollFrame_Update(
            scrollFrame,
            contentHeight,
            scrollFrame:GetHeight()
    )
end

--[[-------------------------------------------------------------------
LibIconPicker_IconSelector_EditBoxMixin
@see IconSelector.xml
---------------------------------------------------------------------]]
--- @alias LibIconPicker_EditBox LibIconPicker_IconSelector_EditBoxMixin|EditBoxObj

--- @class LibIconPicker_IconSelector_EditBoxMixin : EditBox
--- @field opt LibIconPicker_TextInputOptions
--- @field OkayButton ButtonObj
LibIconPicker_IconSelector_EditBoxMixin = {}

--- @type LibIconPicker_IconSelector_EditBoxMixin|LibIconPicker_EditBox
local ebm = LibIconPicker_IconSelector_EditBoxMixin

function ebm:OnLoad()
  self.OkayButton = self:GetParent():GetParent().OkayButton
end

-- Delay focus to avoid keybind input bleeding into EditBox
function ebm:SetFocusDelayed() C_Timer.After(0.01, function() self:SetFocus() end) end

--- To be safe, set focus here only after showing the EditBox
function ebm:OnShow()
  self:SetFocusDelayed()
  self:UpdateOkayButtonState()
end

--- @param userInput boolean
function ebm:OnTextChanged(userInput)
  if not userInput then return end
  self:UpdateOkayButtonState()
end

function ebm:OnEnterPressed()
  if self.OkayButton and self.OkayButton:IsEnabled() then
    self.OkayButton:Click()
  end
end

function ebm:OnEscapePressed() self:GetParent():GetParent():OnClickClose() end

--- @return boolean True if min utf8 char length is satisfied
function ebm:IsMinCharsValid() return strlenutf8(self:GetText() or "") >= self.opt.min end
function ebm:UpdateOkayButtonState() self.OkayButton:SetEnabled(self:IsMinCharsValid()) end
