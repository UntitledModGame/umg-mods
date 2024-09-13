

---@param name string the existing name of the shape
---@param dx number
---@param dy number
local function getName(name, dx, dy)
    local PATTERN = " OFF%-%d+%-%d+"
    local FMT_PATTERN = " OFF-%d-%d"
    local offString = FMT_PATTERN:format(dx,dy)
    if name:find(PATTERN) then
        -- replace existing
        name = name:gsub(PATTERN, offString)
    else
        -- else, append string
        name = name .. offString
    end
    print(name)
    return name
end


---@param shape lootplot.targets.ShapeData
---@param dx number
---@param dy number
---@return lootplot.targets.ShapeData
return function(shape, dx, dy, name)
    name = name or getName(shape.name, dx, dy)
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

