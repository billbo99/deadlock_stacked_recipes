local Func = {}

function Func.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Func.deepcopy(orig_key)] = Func.deepcopy(orig_value)
        end
        setmetatable(copy, Func.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function Func.has_key(table, element)
    for key, _ in pairs(table) do
        if key == element then
            return true
        end
    end
    return false
end

function Func.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function Func.ends_with(str, ending)
    return ending == "" or str:sub( -(#ending)) == ending
end

function Func.starts_with(str, start)
    return str:sub(1, #start) == start
end

function Func.splitString(s, regex)
    local chunks = {}
    local count = 0
    if regex == nil then
        regex = "%S+"
    end

    for substring in s:gmatch(regex) do
        count = count + 1
        chunks[count] = substring
    end
    return chunks
end

function Func.getPlayerByName(playerName)
    for _, player in pairs(game.players) do
        if (player.name == playerName) then
            return player
        end
    end
end

function Func.isAdmin(player)
    if (player.admin) then
        return true
    else
        return false
    end
end

function Func.is_empty(t)
    for _, _ in pairs(t) do
        return false
    end
    return true
end

-- multiply a number with a unit (kJ, kW etc) at the end
---@param property string
---@param mult number
---@return string|number
function Func.multiply_number_unit(property, mult)
    local value, unit
    value = string.match(property, "%d+")
    if string.match(property, "%d+%.%d+") then -- catch floats
        value = string.match(property, "%d+%.%d+")
    end
    unit = string.match(property, "%a+")
    if unit == nil then
        return value * mult
    else
        return ((value * mult) .. unit)
    end
end

return Func
