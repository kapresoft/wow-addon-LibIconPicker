--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker;
if not ns then return end

--- @class LibIconPicker_IconButtonMixin
--- @field icon Texture
LibIconPicker_IconButtonMixin = {}

local o = LibIconPicker_IconButtonMixin
local p = ns.log('IconButton')

--- @class LibIconPicker_IconButton : LibIconPicker_IconButtonMixin

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

--- hold down ALT key
--- @param self LibIconPicker_IconButton
local function OnEnter(self)
  if not IsAltKeyDown() then return end
  p('Icon:', self:GetIcon())
end

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
