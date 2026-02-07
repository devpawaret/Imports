local Tables = {}

function Tables.Dump(tbl, level)
    level = level or 0

    if type(tbl) ~= "table" then
        if type(tbl) == "string" then
            return string.format("%q", tbl)
        end
        return tostring(tbl)
    end

    local indent = string.rep("    ", level)
    local nextIndent = string.rep("    ", level + 1)

    local s = "{\n"
    for k, v in pairs(tbl) do
        local key = type(k) == "number" and "["..k.."]" or '["'..tostring(k)..'"]'

        s = s .. nextIndent .. key .. " = " .. Tables.Dump(v, level + 1) .. ",\n"
    end

    return s .. indent .. "}"
end

function Tables.DeepMerge(target, source)
    for k, v in pairs(source) do
        if type(v) == "table" and type(target[k]) == "table" then
            Tables.DeepMerge(target[k], v)
        else
            target[k] = v
        end
    end

    return target
end

function Tables.Clone(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end

    local meta = getmetatable(tbl)
    local target = {}

    for k, v in pairs(tbl) do
        if type(v) == "table" then
            target[k] = Tables.Clone(v) 
        else
            target[k] = v
        end
    end

    setmetatable(target, meta)

    return target
end

return Tables
