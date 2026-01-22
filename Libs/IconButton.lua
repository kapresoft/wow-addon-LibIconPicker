--- @type LibIconPickerNamespace
local ns = select(2, ...)

--- @class _IconButtonMixin
--- @field icon Texture
LibIconPicker_IconButtonMixin = {}

local S = LibIconPicker_IconButtonMixin
local p = ns:Log('IconButton')

--- @class _IconButton : _IconButtonMixin

--- Alias: IconButton
--- @alias IconButton _IconButton | Button
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]

--- hold down ALT key
--- @param self IconButton
local function OnEnter(self)
    if not IsAltKeyDown() then return end
    p('Icon:', self:GetIcon())
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o _IconButton | IconButton
local function Methods(o)

    function o:OnLoad()
        self:HideNormalTexture()

        if not ns:IsDev() then return end
        self:SetScript('OnEnter', OnEnter)
    end

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

end; Methods(S)
