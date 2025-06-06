local shapeRenamer = {}
local shapes = require("shared.shapes")
local util = require("shared.util")


---@type table<string, string>
local test = {}

---@param shape lootplot.targets.ShapeData
local function makeTest(shape)
    test[util.hashCoords(shape.relativeCoords)] = shape.name
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

    makeTest(shapes.VerticalShape(i))
    makeTest(shapes.HorizontalShape(i))

    makeTest(shapes.UpShape(i))
    makeTest(shapes.DownShape(i))
    makeTest(shapes.LeftShape(i))
    makeTest(shapes.RightShape(i))

    makeTest(shapes.NorthEastShape(i))
    makeTest(shapes.NorthWestShape(i))
    makeTest(shapes.SouthEastShape(i))
    makeTest(shapes.SouthWestShape(i))
end


makeTest(shapes.ROOK_SHAPE)
makeTest(shapes.BISHOP_SHAPE)
makeTest(shapes.QUEEN_SHAPE)
makeTest(shapes.KNIGHT_SHAPE)
makeTest(shapes.ON_SHAPE)



---@param coords {[1]:integer,[2]:integer}[]
---@return string?
function shapeRenamer.tryFindName(coords)
    local coordString = util.hashCoords(coords)
    return test[coordString]
end

return shapeRenamer
