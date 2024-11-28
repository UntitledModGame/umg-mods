local shapeRenamer = {}
local shapes = require("shared.shapes")
local util = require("shared.util")

---@param coords {[1]:integer,[2]:integer}[]
local function computeCoordListString(coords)
    local result = {}
    local sortedCoords = table.deepCopy(coords)
    table.sort(sortedCoords, function(a, b)
        if a[1] == b[1] then
            return a[2] < b[2]
        else
            return a[1] < b[1]
        end
    end)

    for _, v in ipairs(sortedCoords) do
        result[#result+1] = util.coordsToString(v[1], v[2])
    end

    return table.concat(result)
end

---@type table<string, string>
local test = {}

---@param shape lootplot.targets.ShapeData
local function makeTest(shape)
    test[computeCoordListString(shape.relativeCoords)] = shape.name
end

makeTest(shapes.KING_SHAPE)
makeTest(shapes.LARGE_KING_SHAPE)

for i = 1, 5 do
    makeTest(shapes.RookShape(i))
    makeTest(shapes.BishopShape(i))
    if i > 3 then
        makeTest(shapes.CircleShape(i))
    end

    if i > 1 then
        makeTest(shapes.QueenShape(i))
    end
end

makeTest(shapes.ROOK_SHAPE)
makeTest(shapes.BISHOP_SHAPE)
makeTest(shapes.QUEEN_SHAPE)
makeTest(shapes.KNIGHT_SHAPE)
makeTest(shapes.ON_SHAPE)
makeTest(shapes.ABOVE_SHAPE)
makeTest(shapes.BELOW_SHAPE)
makeTest(shapes.ABOVE_BELOW_SHAPE)


---@param coords {[1]:integer,[2]:integer}[]
---@return string?
function shapeRenamer.get(coords)
    local coordString = computeCoordListString(coords)
    return test[coordString]
end

return shapeRenamer
