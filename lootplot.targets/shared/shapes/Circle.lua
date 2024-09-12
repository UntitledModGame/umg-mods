---@param size integer?
---@param name string?
---@return lootplot.targets.ShapeData
return function(size, name)
    size = size or 1
    local coords = {}

    for dx = -size, size do
        for dy = -size, size do
            if not (dx == 0 and dy == 0) and math.distance(dx, dy) <= size then
                coords[#coords+1] = {dx, dy}
            end
        end
    end

    return {
        name = name or ("CIRCLE-"..size),
        relativeCoords = coords
    }
end

