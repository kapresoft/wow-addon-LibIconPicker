--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end
local O = ns.O
local IconHistory = O.IconHistory

local strlenutf8 = strlenutf8
local tMergeWithDefaults = O.Util.Table_MergeWithDefaults

--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- @class LibIconPicker_FirstRow
--- @field IconTypeDropdown DropdownButton
--- @field Label FontString
--- @field EditBox LibIconPicker_EditBox
--- @field HistoryButton DropdownButton

--- @class LibIconPicker_SelectedIconButton : LibIconPicker_IconButton
--- @field Checked Texture

--- @class LibIconPicker_IconScrollFrame : ScrollFrame
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
local L = ns:GetLocale()

local FIRST_ROW_HEIGHT = 80
local FIRST_ROW_HEIGHT_NO_TEXT_FIELD = 65

--- @type table<number, number>
local icons

--- @type LibIconPicker_FirstRow
local firstRow
--- @type LibIconPicker_IconTypeFilter
local selectedIconType

--- @type LibIconPicker_IconScrollFrame
local scrollFrame

--- @type LibIconPicker_SelectedIconButton
local selectedIconBtn

--- @type LibIconPicker_HelpTip
local dragTip
--- @type LibIconPicker_HelpTip
local historyTip

local maxText = ns.sformat('%s %s %s', L['Max'], 16, L['Characters'])
local labelText = ns.sformat('%s (%s):', L['Name'], maxText)

-- For LibIconPicker_Options textInput.max
local NAME_FIELD_MAX_LIMIT = 100

--- Default Options
--- @type LibIconPicker_Options
local DEFAULT_ICON_PICKER_OPTIONS = {
  showTextInput = false,
  textInput = { value = '', label = labelText, min = 1 },
  anchor = {
    point = 'CENTER',
    relativeTo = UIParent,
    relativePoint = 'CENTER',
    x = 0,
    y = 0,
  },
}

--- @type LibIconPicker_CallbackInfo
local callbackInfo

-- Settings
local ICON_SIZE = 32
local ICON_PAD = 6
local ICON_COLS = 10
local ROW_HEIGHT = ICON_SIZE + ICON_PAD

local HISTORY_GRID_COLUMNS = 5
-- Blizzard's minimum menu cell width; smaller ones stretch
local HISTORY_ICON_SIZE = 50
-- Columns via Blizzard's grid padding; rows via AddRowGap
local HISTORY_GRID_GAP = 4
-- Whole menu, not cells, so Blizzard's insets stay even
local HISTORY_MENU_SCALE = 0.8

-- Warm tint marks OK as the main action
local OKAY_TINT = CreateColor(1, 0.8, 0.5)
-- UIMenuButtonStretchTemplate's nine background slices
local STRETCH_SLICES = {
  'TopLeft',
  'TopMiddle',
  'TopRight',
  'MiddleLeft',
  'MiddleMiddle',
  'MiddleRight',
  'BottomLeft',
  'BottomMiddle',
  'BottomRight',
}

-- The button padding
local GRID_PADDING_LEFT = 0
local ROW_PADDING_LEFT = 5
local ROW_PADDING_TOP = 0

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
--- @class LibIconPicker_IconSelectorMixin : Frame
--- @field private _lastOffset number
--- @field icons table<number, number>
--- @field ScrollFrame LibIconPicker_IconScrollFrame
--- @field FirstRow LibIconPicker_FirstRow
--- @field HeaderTitle FontString
--- @field DragTip LibIconPicker_HelpTip
--- @field HistoryTip LibIconPicker_HelpTip
--- @field OkayButton Button
LibIconPicker_IconSelectorMixin = {}; local o = LibIconPicker_IconSelectorMixin
local p = ns.log('IconSelector')

--
--- @class LibIconPicker_IconSelector : LibIconPicker_IconSelectorMixin
--

--[[-----------------------------------------------------------------------------
Local Functions and Handlers
-------------------------------------------------------------------------------]]
--- @param self LibIconPicker_IconButton
local function OnClickIconItem(self) selectedIconBtn:SetIcon(self:GetIcon()) end

--- @param setName string
--- @return IconIDOrPath|nil
local function GetEquipmentSetIcon(setName)
  local setID = C_EquipmentSet.GetEquipmentSetID(setName)
  return setID and select(2, C_EquipmentSet.GetEquipmentSetInfo(setID))
end

--- Keyed by GetCursorInfo() type; args are its other returns
--- @type table<string, fun(id: number|string, arg2: any, arg3: any): IconIDOrPath|nil>
local cursorIconResolvers = {
  item = function(itemID) return C_Item.GetItemIconByID(itemID) end,
  spell = function(_, _, spellID) return (C_Spell.GetSpellTexture(spellID)) end,
  macro = function(index) return (select(2, GetMacroInfo(index))) end,
  mount = function(mountID) return (select(3, C_MountJournal.GetMountInfoByID(mountID))) end,
  battlepet = function(petID) return (select(9, C_PetJournal.GetPetInfoByPetID(petID))) end,
  equipmentset = GetEquipmentSetIcon,
}

--- @return IconIDOrPath|nil
local function GetCursorIcon()
  local cursorType, id, arg2, arg3 = GetCursorInfo()
  local resolve = cursorType and cursorIconResolvers[cursorType]
  return resolve and resolve(id, arg2, arg3)
end

--- @param self LibIconPicker_SelectedIconButton
local function OnDropCursorIcon(self)
  local icon = GetCursorIcon()
  if not icon then return end
  self:SetIcon(icon)
  ClearCursor()
  dragTip:Dismiss()
end

--- @param self LibIconPicker_SelectedIconButton
local function UpdateCheckedState(self) self.Checked:SetShown(GetCursorIcon() ~= nil) end

--- @param self LibIconPicker_SelectedIconButton
local function OnShowSelectedIcon(self)
  self:RegisterEvent('CURSOR_CHANGED')
  UpdateCheckedState(self)
end

--- @param self LibIconPicker_SelectedIconButton
local function OnHideSelectedIcon(self) self:UnregisterEvent('CURSOR_CHANGED') end

--- Grid has no row gap; an unclickable strip is one.
--- @param button LibIconPicker_IconButton
--- @param gap number @0 on the last row, so the menu ends at the icons
local function AddRowGap(button, gap)
  button:SetHeight(HISTORY_ICON_SIZE + gap)
  button:SetHitRectInsets(0, 0, 0, gap)
  for _, region in ipairs({ button.icon, button:GetHighlightTexture() }) do
    region:ClearAllPoints()
    region:SetPoint('TOPLEFT')
    region:SetPoint('TOPRIGHT')
    region:SetHeight(HISTORY_ICON_SIZE)
  end
end

--- Multiplies the silver art, so it can tint but not lighten.
--- @param button Button @UIMenuButtonStretchTemplate
--- @param color ColorMixin
local function TintStretchButton(button, color)
  for _, key in ipairs(STRETCH_SLICES) do
    button[key]:SetVertexColor(color:GetRGB())
  end
end

--- Template pins Text to the top; center it at any height.
--- @param button DropdownButton
local function CenterText(button)
  button.Text:ClearAllPoints()
  button.Text:SetPoint('CENTER')
end

--- Widest label's width, so a pick never shifts the row.
--- @param dropdown DropdownButton @Filter template, resizeToText off
--- @param labels table<string, string>
local function FitWidestLabel(dropdown, labels)
  local widest = 0
  for _, label in pairs(labels) do
    dropdown.Text:SetText(label)
    widest = math.max(widest, dropdown.Text:GetUnboundedStringWidth())
  end
  dropdown:SetWidth(widest + dropdown.resizeToTextPadding)
end

--- @param opt LibIconPicker_Options|nil
local function CreateOptions(opt) return tMergeWithDefaults(DEFAULT_ICON_PICKER_OPTIONS, opt) end

local function NormalizeTextInput(textInput)
  if type(textInput) ~= 'table' then return end

  local min, max = tonumber(textInput.min), tonumber(textInput.max)

  -- normalize max
  if not max or max < 1 then
    max = NAME_FIELD_MAX_LIMIT
  elseif max > NAME_FIELD_MAX_LIMIT then
    max = NAME_FIELD_MAX_LIMIT
  end
  -- normalize min
  if not min or min < 1 then
    min = 1
  elseif min > max then
    min = max
  end

  textInput.min = min
  textInput.max = max
end

-- -----------------------------------------------------
-- Row Template Population (called by CreateButtons)
-- -----------------------------------------------------
--- @param self Frame The frame of the row
function o.OnLoadRow(self)
  self:SetHeight(ROW_HEIGHT)

  --- @type Template
  local template = 'LibIconPicker_IconButtonTemplate'
  -- Each row gets 12 icon buttons
  for col = 1, ICON_COLS do
    --- @type LibIconPicker_IconButton
    local b = CreateFrame('Button', nil, self, template)
    b:SetSize(ICON_SIZE, ICON_SIZE)

    if col == 1 then
      b:SetPoint('LEFT', self, 'LEFT', GRID_PADDING_LEFT, 0)
    else
      b:SetPoint('LEFT', self[col - 1], 'RIGHT', ICON_PAD, 0)
    end
    b:SetScript('OnClick', OnClickIconItem)
    self[col] = b
  end
end

-- -----------------------------------------------------
-- Methods
-- -----------------------------------------------------
function o:OnLoad()
  firstRow = self.FirstRow
  selectedIconBtn = firstRow.SelectedIconButton
  dragTip = self.DragTip
  historyTip = self.HistoryTip
  TintStretchButton(self.OkayButton, OKAY_TINT)

  self.HeaderTitle:SetText(L['Icon Picker'])
  firstRow.Label:SetText(DEFAULT_ICON_PICKER_OPTIONS.textInput.label)

  scrollFrame = self.ScrollFrame

  self:SetBackdrop(ns.backdrops.modernDark)

  local scrollBar = scrollFrame.scrollBar
  scrollBar:HookScript('OnValueChanged', function()
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    -- Prevent redraw at the top or end of scroll: offset didn't change
    if offset == self._lastOffset then return end
    self._lastOffset = offset
    self:RedrawDelayed()
  end)

  scrollFrame:SetScript(
    'OnMouseWheel',
    function(sf, delta) HybridScrollFrame_OnMouseWheel(sf, delta) end
  )
  O.IconSelector = self

  self:OnInit()
end

--- @private
function o:OnInit()
  tinsert(UISpecialFrames, self:GetName())
  self:InitTooltips()
  self:InitDragAndDrop()
  self:InitIconTypeDropdown()
  self:InitHistoryButton()
end

--- @return table<number, number>
function o:GetIcons() return ns.iconDataProvider:GetIcons(selectedIconType) end

--- @param callback LibIconPicker_CallbackFn
--- @param _opt LibIconPicker_Options|nil
function o:ShowDialog(callback, _opt)
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

  if type(callback) == 'function' then callbackInfo = { callback = callback, opt = opt } end
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
  self:ShowHelpTip()
  self:Show()
end

--- One tip at a time; history waits until it has picks.
--- @private
function o:ShowHelpTip()
  if dragTip:ShowOnce() then return end
  if #IconHistory:GetIcons() > 0 then historyTip:ShowOnce() end
end

--- @private
--- @param opt LibIconPicker_Options
function o:OnToggleFirstRow(opt)
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
function o:OnClickClose() self:Hide() end

--- @private
function o:OnClickOkay()
  if callbackInfo then
    local fn = callbackInfo.callback
    local icon = selectedIconBtn:GetIcon()
    --- @type LibIconPicker_Selection
    local sel = { icon = icon }
    if firstRow.EditBox:IsShown() then sel.textInputValue = firstRow.EditBox:GetText() end
    IconHistory:Add(icon)
    fn(sel)
    return self:Hide()
  end
  self:Hide()
end

--- @private
function o:OnClickCancel()
  self:Hide()
end

-- -----------------------------------------------------
-- Initialization
-- -----------------------------------------------------
--- @private
function o:InitGrid()
  if not scrollFrame.buttons then
    HybridScrollFrame_CreateButtons(scrollFrame, 'LibIconPicker_IconRowTemplate', ROW_HEIGHT, 0)
  end
  self:RedrawDelayed()
end

--- @private
function o:InitTooltips()
  selectedIconBtn:SetScript('OnEnter', function(self)
    if GetCursorIcon() then return end
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip:SetText(L['Selected Icon'])
    GameTooltip:AddLine(L['Selected Icon::Desc'], 0.8, 0.8, 0.8, true)
    GameTooltip:AddLine(' ')
    local r, g, b = GREEN_FONT_COLOR:GetRGB()
    GameTooltip:AddLine(L['Selected Icon::DragHint'], r, g, b, true)
    GameTooltip:Show()
  end)
  selectedIconBtn:SetScript('OnLeave', function() GameTooltip:Hide() end)
end

--- @private
function o:InitDragAndDrop()
  selectedIconBtn:SetScript('OnReceiveDrag', OnDropCursorIcon)
  selectedIconBtn:SetScript('OnClick', OnDropCursorIcon)
  selectedIconBtn:SetScript('OnEvent', UpdateCheckedState)
  selectedIconBtn:HookScript('OnShow', OnShowSelectedIcon)
  selectedIconBtn:HookScript('OnHide', OnHideSelectedIcon)
end

--- @private
function o:InitIconTypeDropdown()
  local prov = ns.iconDataProvider
  local dropdown = firstRow.IconTypeDropdown
  local order = { prov.BOTH, prov.ITEMS, prov.SPELLS }
  local labels =
    { [prov.BOTH] = L['All Icons'], [prov.ITEMS] = L['Items'], [prov.SPELLS] = L['Spells'] }
  selectedIconType = prov.BOTH
  CenterText(dropdown)
  FitWidestLabel(dropdown, labels)
  -- Filter template shows fixed text; keep it on the pick
  dropdown:SetText(labels[selectedIconType])
  local function IsSelected(iconType) return iconType == selectedIconType end
  -- Radios keep the menu open; a filter pick closes it
  local function SetSelected(iconType)
    dropdown:SetText(labels[iconType])
    self:OnIconTypeChanged(iconType)
    return MenuResponse.Close
  end
  dropdown:SetupMenu(function(_, root)
    for _, iconType in ipairs(order) do
      root:CreateRadio(labels[iconType], IsSelected, SetSelected, iconType)
    end
  end)
end

--- @private
function o:InitHistoryButton()
  local button = firstRow.HistoryButton
  CenterText(button)
  button:SetupMenu(function(_, root) self:BuildHistoryMenu(root) end)
  button:SetText(L['Recent Icons'])
  button:RegisterCallback(DropdownButtonMixin.Event.OnMenuOpen, function() historyTip:Dismiss() end)
end

--- Newest first; picking one only sets the selected icon.
--- @private
--- @param root RootMenuDescriptionProxy
function o:BuildHistoryMenu(root)
  local history = IconHistory:GetIcons()
  if #history == 0 then
    root:CreateTitle(L['No Recent Icons'])
    return
  end
  -- Non-zero, or the dropdown's width stretches 1 to 2 cells
  root:SetMinimumWidth(1)
  -- Blizzard resets the scale on every open
  root:AddMenuAcquiredCallback(
    function(menu) menu:SetScale(menu:GetScale() * HISTORY_MENU_SCALE) end
  )
  root:SetGridMode(MenuConstants.HorizontalGridDirection, HISTORY_GRID_COLUMNS, HISTORY_GRID_GAP)
  local lastRowStart = #history - (#history - 1) % HISTORY_GRID_COLUMNS
  for i, icon in ipairs(history) do
    self:AddHistoryCell(root, icon, i >= lastRowStart)
  end
end

--- Icon-only cell; a custom template must Pick() itself.
--- @private
--- @param root RootMenuDescriptionProxy
--- @param icon IconIDOrPath
--- @param isLastRow boolean
function o:AddHistoryCell(root, icon, isLastRow)
  local cell = root:CreateTemplate('LibIconPicker_IconButtonTemplate')
  cell:AddInitializer(function(button, description)
    button:SetWidth(HISTORY_ICON_SIZE)
    AddRowGap(button, isLastRow and 0 or HISTORY_GRID_GAP)
    button:SetIcon(icon)
    button:SetScript(
      'OnClick',
      function(_, buttonName) description:Pick(MenuInputContext.MouseButton, buttonName) end
    )
  end)
  cell:SetResponder(function()
    selectedIconBtn:SetIcon(icon)
    return MenuResponse.CloseAll
  end)
  cell:SetTooltip(function(tooltip) tooltip:SetText(tostring(icon)) end)
end

--- @private
--- @param iconType "'spells'" | "'items'" | "'both'"
--- @see LibIconPicker_IconDataProvider#{SPELLS, ITEMS, BOTH}
function o:OnIconTypeChanged(iconType)
  selectedIconType = iconType
  -- 1) Fetch new icons
  icons = self:GetIcons()

  -- 2) Reset scroll position (critical)
  scrollFrame:SetVerticalScroll(0)
  HybridScrollFrame_SetOffset(scrollFrame, 0)
  scrollFrame.scrollBar:SetValue(0)

  self:RedrawDelayed()
end

--- @private
function o:ResetRowPoints(row, rowIndex)
  row:ClearAllPoints()
  if rowIndex == 1 then
    row:SetPoint('TOPLEFT', scrollFrame.scrollChild, 'TOPLEFT', ROW_PADDING_LEFT, ROW_PADDING_TOP)
  else
    row:SetPoint('TOPLEFT', scrollFrame.buttons[rowIndex - 1], 'BOTTOMLEFT', 0, 0)
  end
end

function o:RedrawDelayed()
  C_Timer.After(0.01, function() self:Redraw() end)
end

-- -----------------------------------------------------
-- Virtual Scroll Update
-- -----------------------------------------------------
--- @private
function o:Redraw()
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
  if IsAltKeyDown() then
    p(ns.sformat('Redraw:: total=%s, type=%s, offset=%s', total, selectedIconType, offset))
  end

  HybridScrollFrame_Update(scrollFrame, contentHeight, scrollFrame:GetHeight())
end

--[[-------------------------------------------------------------------
LibIconPicker_IconSelector_EditBoxMixin
@see IconSelector.xml
---------------------------------------------------------------------]]

--- @class LibIconPicker_IconSelector_EditBoxMixin : EditBox
--- @field opt LibIconPicker_TextInputOptions
--- @field OkayButton ButtonObj
LibIconPicker_IconSelector_EditBoxMixin = {}
local ebm = LibIconPicker_IconSelector_EditBoxMixin

--
--- @class LibIconPicker_EditBox : LibIconPicker_IconSelector_EditBoxMixin
--

function ebm:OnLoad() self.OkayButton = self:GetParent():GetParent().OkayButton end

-- Delay focus to avoid keybind input bleeding into EditBox
function ebm:SetFocusDelayed()
  C_Timer.After(0.01, function() self:SetFocus() end)
end

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
  if self.OkayButton and self.OkayButton:IsEnabled() then self.OkayButton:Click() end
end

function ebm:OnEscapePressed() self:GetParent():GetParent():OnClickClose() end

--- @return boolean True if min utf8 char length is satisfied
function ebm:IsMinCharsValid() return strlenutf8(self:GetText() or '') >= self.opt.min end
function ebm:UpdateOkayButtonState() self.OkayButton:SetEnabled(self:IsMinCharsValid()) end
