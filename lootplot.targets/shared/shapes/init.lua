local shapes = {}


---@class lootplot.targets.ShapeData
---@field name string
---@field relativeCoords {[1]:integer,[2]:integer}[]

-- Shape exports
local KingShape = require("shared.shapes.King")
local UnionShape = require("shared.shapes.Union")
local OffsetShape = require("shared.shapes.Offset")
local RotationShape = require("shared.shapes.Rotation")
local UniDirectionalShape = require("shared.shapes.UniDirectional")
local CircleShape = require("shared.shapes.Circle")


local MAX_DISTANCE = 40


shapes.KingShape = KingShape
shapes.UnionShape = UnionShape
shapes.OffsetShape = OffsetShape
shapes.RotationShape = RotationShape
shapes.UniDirectionalShape = UniDirectionalShape
shapes.CircleShape = CircleShape


---@alias lootplot.targets.ShapeFactory fun(size, name): lootplot.targets.ShapeData



---@param size integer?
---@param name string?
---@return lootplot.targets.ShapeData
function shapes.RookShape(size, name)
    return UnionShape(
        UniDirectionalShape(1, 0, size),
        UniDirectionalShape(0, 1, size),
        UniDirectionalShape(-1, 0, size),
        UniDirectionalShape(0, -1, size),
        name or ("ROOK-" .. tostring(size))
    )
end

---@param size integer?
---@param name string?
---@return lootplot.targets.ShapeData
function shapes.BishopShape(size, name)
    return UnionShape(
        UniDirectionalShape(1, 1, size),
        UniDirectionalShape(-1, 1, size),
        UniDirectionalShape(-1, -1, size),
        UniDirectionalShape(1, -1, size),
        name or ("BISHOP-" .. tostring(size))
    )
end

---@param size integer?
---@return lootplot.targets.ShapeData
function shapes.QueenShape(size, name)
    return UnionShape(
        shapes.RookShape(size),
        shapes.BishopShape(size),
        name or ("QUEEN-" .. tostring(size))
    )
end


-- Pre-defined shape instance
shapes.KING_SHAPE = KingShape(1)
shapes.LARGE_KING_SHAPE = KingShape(2)
shapes.ROOK_SHAPE = shapes.RookShape(MAX_DISTANCE, "ROOK-BIG")
shapes.BISHOP_SHAPE = shapes.BishopShape(MAX_DISTANCE, "BISHOP-BIG")
shapes.QUEEN_SHAPE = UnionShape(shapes.ROOK_SHAPE, shapes.BISHOP_SHAPE, "QUEEN-BIG")
---@type lootplot.targets.ShapeData
shapes.KNIGHT_SHAPE = {
    name = "KNIGHT",
    relativeCoords = {
        {-2, -1},
        {-1, -2},
        {-2, 1},
        {-1, 2},
        {2, -1},
        {1, -2},
        {2, 1},
        {1, 2},
    }
}

shapes.ON_SHAPE = {
    name = "ON",
    relativeCoords = {
        {0,0}
    }
}

shapes.ABOVE_SHAPE = UniDirectionalShape(0, -1, 1, "ABOVE")
shapes.BELOW_SHAPE = UniDirectionalShape(0, 1, 1, "BELOW")

shapes.ABOVE_BELOW_SHAPE = UnionShape(shapes.ABOVE_SHAPE, shapes.BELOW_SHAPE, "ABOVE-BELOW")

return shapes
