---@param dx integer
---@param dy integer
---@param length integer?
---@param name string?
---@return lootplot.targets.ShapeData
return function(dx, dy, length, name)
    local coords = {}
    for i = 1, length do
        coords[#coords+1] = {dx * i, dy * i}
    end

    return {
        name = name or "Uni-directional Shape",
        relativeCoords = coords
    }
end
