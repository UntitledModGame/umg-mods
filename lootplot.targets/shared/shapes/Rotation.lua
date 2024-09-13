
---@param name string the existing name of the shape
---@param rot number
local function getName(name, rot)
    rot = rot % 4
    if rot == 0 then
        return name
    end

    local PATTERN = " ROT%-%d"
    local FMT_PATTERN = " ROT-%d"
    local found = name:match(PATTERN)
    if found then
        -- Increment existing rot count
        rot = (rot + tonumber(found:match("%d"))) % 4
        local rotString = FMT_PATTERN:format(rot)
        if rot == 0 then
            rotString = "" -- 0 = no rotation!
        end
        name = name:gsub(PATTERN, rotString)
    else
        -- just append string
        name = name .. FMT_PATTERN:format(rot)
    end

    return name
end



---@param shape lootplot.targets.ShapeData
---@param dx number
---@param dy number
---@return lootplot.targets.ShapeData
return function(shape, dx, dy)
    local name = getName(shape.name, dx, dy)
    local coords = {}

    for _, coord in ipairs(shape.relativeCoords) do
        local x, y = coord[1], coord[2]
        coords[#coords+1] = {x + dx, y + dy}
    end

    return {
        name = name,
        relativeCoords = coords
    }
end

