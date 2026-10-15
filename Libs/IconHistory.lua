--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local MAX_ICON_HISTORY = 15

--[[-----------------------------------------------------------------------------
LibIconPicker_IconHistory: confirmed picks, newest first
-------------------------------------------------------------------------------]]
--- @class LibIconPicker_IconHistory
local o = {}; ns.O.IconHistory = o

--- @param icons IconIDOrPath[]
--- @param icon IconIDOrPath
local function Remove(icons, icon)
  for i = #icons, 1, -1 do
    if icons[i] == icon then tremove(icons, i) end
  end
end

--- @return IconIDOrPath[]
function o:GetIcons() return ns:GetIconHistory() end

--- A repeat pick moves to the top; the oldest drops past the cap.
--- @param icon IconIDOrPath?
function o:Add(icon)
  if not icon or icon == ns.QUESTION_MARK_ICON_ID then return end
  local icons = ns:GetIconHistory()
  Remove(icons, icon)
  tinsert(icons, 1, icon)
  for i = #icons, MAX_ICON_HISTORY + 1, -1 do
    icons[i] = nil
  end
end
