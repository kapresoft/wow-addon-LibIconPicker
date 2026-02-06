--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker;
if not ns then return end

--- @class _LibIconPicker_IconButtonMixin
--- @field icon Texture
LibIconPicker_IconButtonMixin = {}

local S = LibIconPicker_IconButtonMixin
local p = ns:Log('IconButton')

--- @class _LibIconPicker_IconButton : _LibIconPicker_IconButtonMixin

--- Alias: IconButton
--- @alias LibIconPicker_IconButton _LibIconPicker_IconButton | Button
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

--- hold down ALT key
--- @param self LibIconPicker_IconButton
local function OnEnter(self)
  if not IsAltKeyDown() then return end
  p('Icon:', self:GetIcon())
end

--- @type _LibIconPicker_IconButton | LibIconPicker_IconButton
local o = S
--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

function o:OnLoad()
  self:HideNormalTexture()
  
  if not ns:IsDev() then return end
  self:SetScript('OnEnter', OnEnter)
end

-- p("SetIcon call stack:", debugstack(1, 5, 5))
--- @param tex IconIDOrPath
function o:SetIcon(tex)
  local type = type(tex)
  local icon = 134400 -- question mark
  if type == 'string' or type == 'number' then icon = tex end
  self.icon:SetTexture(icon)
end

function o:GetIcon() return self.icon:GetTexture() end

function o:HideNormalTexture()
  local normalTex = self:GetNormalTexture()
  return normalTex and normalTex:Hide()
end
