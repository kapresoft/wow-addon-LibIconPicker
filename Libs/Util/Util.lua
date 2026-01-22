--- @type LibIconPickerNamespace
local ns = select(2, ...)

--- @class Util
local S  = {}; ns.O.Util = S

--- @return table|nil Returns a shallow copy of `t`; returns nil if `t` is nil
function S.Table_ShallowCopy(t)
    if t == nil then return nil end
    local t2 = {}
    for k,v in pairs(t) do t2[k] = v end
    return t2
end
