--[[-----------------------------------------------------------------------------
TourList: every help tour, in priority order.

Tours without `since` are always eligible (the welcome tour). Feature tours
set `since` one past the highest in use, so only users who installed before
it see them. Step keys must be unique across all tours.
@see HelpTour.lua
-------------------------------------------------------------------------------]]
--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

--- @type LibIconPicker_HelpTourDef[]
ns.O.TourList = {
  {
    id = 'welcome',
    steps = {
      {
        key = 'DragTip',
        textKey = 'Selected Icon::DragHint',
        --- @param d LibIconPicker_IconSelector
        anchor = function(d) return d.FirstRow.SelectedIconButton end,
      },
      {
        key = 'HistoryTip',
        textKey = 'Recent Icons::Tip',
        --- @param d LibIconPicker_IconSelector
        anchor = function(d) return d.FirstRow.HistoryButton end,
      },
    },
  },
}
