--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

--- @class Util
local o = {}; ns.O.Util = o

--- @param tbl table
--- @param shallow boolean
--- @return table The copied table
function o.Table_Copy(tbl, shallow)
  if tbl == nil then return nil end
  local copy = {};
  for k, v in pairs(tbl) do
    if type(v) == "table" and not shallow then
      copy[k] = o.Table_Copy(v, shallow);
    else
      copy[k] = v;
    end
  end
  return copy;
end

--- Applies non-nil values from {right} over {left}.
--- {left} values act as defaults.
--- Returns a new table; inputs are not modified.
--- @param left table|nil
--- @param right table
--- @return table
function o.Table_MergeWithDefaults(left, right)
  assert(type(right) == 'table', "The param [right] must be a table.")
  if left == nil then return o.Table_Copy(right, false) end
  local result = o.Table_Copy(left, false)
  
  -- apply override values over defaults
  for k, v in pairs(right) do
    if type(v) == "table" then
      local destSub = type(result[k]) == "table" and result[k] or nil
      result[k] = o.Table_MergeWithDefaults(destSub, v)
    else
      if v ~= nil then result[k] = v end
    end
  end
  return result
end
