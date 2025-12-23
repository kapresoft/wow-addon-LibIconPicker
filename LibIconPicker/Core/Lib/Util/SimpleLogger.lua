--- @type LibIconPickerNamespace
local ns = select(2, ...)

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
function ns:Log(name)
    assert(type(name) == "string", "name must be a string")

    if not ns:IsDev() then return function() end end

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

