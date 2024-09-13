
---@param name string the existing name of the shape
---@param rot number
local function getName(name, rot)
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



local function rotateCoord(coord, rot)
    for i=1,rot do
        local x, y = coord[1], coord[2]
        coord = {y, -x}
    end
    return coord
end


---@param shape lootplot.targets.ShapeData
---@param dy number
---@return lootplot.targets.ShapeData
return function(shape, rot, name)
    rot = rot % 4 -- 1 = 90 degrees of rotation
    if rot == 0 then
        return shape
    end

    name = name or getName(shape.name, rot)
    local coords = {}

    for _, coord in ipairs(shape.relativeCoords) do
        coords[#coords+1] = rotateCoord(coord, rot)
    end

    return {
        name = name,
        relativeCoords = coords
    }
end

