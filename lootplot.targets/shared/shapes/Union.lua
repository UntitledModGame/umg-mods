local util = require("shared.util")


local MAX_NAME_SIZE = 24

local function makeConcatName(shapes)
    -- try generate name from concatenating shapes
    -- (If its too long, we fall back)
    local concatName = shapes[1].name
    for i=2, #shapes do
        local shape = shapes[i]
        local newName = concatName .. "-" .. shape.name
        if #newName > MAX_NAME_SIZE then
            return concatName
        end
        concatName = newName
    end
    return concatName
end


---@param shape1 lootplot.targets.ShapeData
---@param shape2 lootplot.targets.ShapeData
---@param ... lootplot.targets.ShapeData|string
---@return lootplot.targets.ShapeData
return function(shape1, shape2, ...)
    local shapes = {shape1, shape2, ...}

    local name
    if type(shapes[#shapes]) == "string" then
        -- This is the name
        name = table.remove(shapes)
    end

    local coords = {}
    local coordsSet = objects.Set()

    for _, shape in ipairs(shapes) do
        for _, coord in ipairs(shape.relativeCoords) do
            local key = util.coordsToString(coord[1], coord[2])
            if not coordsSet:has(key) then
                coords[#coords+1] = coord
                coordsSet:add(key)
            end
        end
    end

    if not name then
        local shapeRenamer = require("shared.shape_renamer")
        name = shapeRenamer.get(coords) or makeConcatName(shapes)
    end

    return {
        name = name,
        relativeCoords = coords
    }
end
