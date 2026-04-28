--- @type LibIconPicker_Namespace
local ns = select(2, ...).LibIconPicker; if not ns then return end

--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- @alias LibIconPicker_LogFn fun(...: any) : void @A log function that accepts any values and outputs formatted text; behaves like print

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat, date = string.format, date

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local prefixC = CreateColorFromHexString("ff32CF21")
local nameC = CreateColorFromHexString("ffFDFF05") -- yellow
local logName = prefixC:WrapTextInColorCode('LIP') -- LibIconPicker
local keyColor   = CreateColorFromHexString("ffB8BA05") -- yellow
local valueColor = CreateColorFromHexString("ffFFFFFF") -- white

local function tpack(...)
    return { n = select("#", ...), ... }
end

local function valToStr(tbl)
    if tbl == nil then return "nil" end
    if type(tbl) ~= "table" then return tostring(tbl) end

    local out = {}
    for k, v in pairs(tbl) do
        local key   = keyColor:WrapTextInColorCode(tostring(k))
        local value = valueColor:WrapTextInColorCode(tostring(v))
        out[#out + 1] = key .. "=" .. value
    end

    return "{ " .. table.concat(out, ", ") .. " }"
end

--- @param name Name The log name
--- @return LibIconPicker_LogFn
function ns.log(name)
    assert(type(name) == "string", "ns.log(name): {name} should be a string")

    local prefix = sformat("{{%s::%s}}:", logName, nameC:WrapTextInColorCode(name))

    return function(...)
        local args = tpack(...)
        for i = 1, args.n do
            if type(args[i]) == "table" then
                args[i] = valToStr(args[i])
            end
        end
        print("[" .. date("%H:%M:%S") .. "]", prefix, unpack(args, 1, args.n))
    end
end

--[[-----------------------------------------------------------------------------
Trace Function: Override from Namespace
-------------------------------------------------------------------------------]]
--- @param prefix Name
--- @param ... any
function ns.tr(prefix, ...)
  local _ns = ns
  local c = CreateColorFromHexString('466EFFff')
  local identifier = c:WrapTextInColorCode(strupper(_ns.name)) .. '::'
  if not EventTrace then return end; EventTrace:LogEvent(identifier .. prefix, ...)
end
