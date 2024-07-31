---@class lootplot.targets.CoordinateSet: objects.Class
local CoordinateSet = objects.Class("lootplot.targets:CoordinateSet")

---@param x integer
---@param y integer
local function coordsToString(x, y)
    x = x % 4294967296
    y = y % 4294967296
    return string.char(
        x % 256,
        (x / 256) % 256,
        (x / 65536) % 256,
        (x / 16777216) % 256,
        y % 256,
        (y / 256) % 256,
        (y / 65536) % 256,
        (y / 16777216) % 256
    )
end

---@param shape1 lootplot.targets.ShapeData
---@param shape2 lootplot.targets.ShapeData
---@param ... lootplot.targets.ShapeData|string
---@return lootplot.targets.ShapeData
return function(shape1, shape2, ...)
    local shapes = {shape1, shape2, ...}

    local name = "Union Shape"
    if type(shapes[#shapes]) == "string" then
        -- This is the name
        name = table.remove(shapes)
    end

    local coords = {}
    local coordsSet = objects.Set()

    for _, shape in ipairs(shapes) do
        for _, coord in ipairs(shape.relativeCoords) do
            local key = coordsToString(coord[1], coord[2])
            if not coordsSet:has(key) then
                coords[#coords+1] = coord
            end
        end
    end

    return {
        name = name,
        relativeCoords = coords
    }
end
