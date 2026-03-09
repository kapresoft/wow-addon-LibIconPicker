--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

--- @class Util
local o = {}; ns.O.Util = o

--- @param tbl table
--- @param shallow boolean
--- @param seen table|nil
--- @return table
function o.Table_Copy(tbl, shallow, seen)
  if tbl == nil then return nil end
  if type(tbl) ~= 'table' then return tbl end
  -- Do not copy WoW UI objects (Frame, Texture, FontString, etc.)
  -- NOTE:
  -- Some addons (notably "Spy") attach additional references to UI objects such
  -- as FontStrings and Frames. These can create cyclic graphs like:
  --   region -> parent -> regions -> region
  -- A naive deep copy would recurse indefinitely and cause a stack overflow.
  -- To prevent this we:
  --   1) Track visited tables via `seen`
  --   2) Avoid deep-copying WoW UI objects entirely.
  if tbl.GetObjectType then return tbl end
  
  seen = seen or {}
  if seen[tbl] then return seen[tbl] end
  
  local copy = {}
  seen[tbl] = copy
  
  for k, v in pairs(tbl) do
    if not shallow and type(v) == 'table' and not v.GetObjectType then
      copy[k] = o.Table_Copy(v, false, seen)
    else copy[k] = v end
  end
  
  return copy
end

--- Applies non-nil values from {right} over {left}.
--- {left} values act as defaults.
--- Returns a new table; inputs are not modified.
--- @param left table|nil
--- @param right table
--- @return table
function o.Table_MergeWithDefaults(left, right)
  assert(type(right) == 'table', 'Table_MergeWithDefaults(left, right):: The param [right] must be a table.')
  -- Do not merge UI objects
  -- NOTE:
  -- UI objects may contain cyclic references introduced by other addons
  -- (for example Spy). Recursively merging such objects could cause
  -- infinite recursion. We therefore treat WoW UI objects as opaque
  -- handles and copy the reference instead of merging their internals.
  if right.GetObjectType then return right end
  if left == nil then return o.Table_Copy(right, false) end
  
  local result = o.Table_Copy(left, false)
  -- apply override values over defaults
  for k, v in pairs(right) do
    if type(v) == 'table' and not v.GetObjectType then
      local destSub = type(result[k]) == 'table' and result[k] or nil
      result[k] = o.Table_MergeWithDefaults(destSub, v)
    else if v ~= nil then result[k] = v end end
  end
  
  return result
end
