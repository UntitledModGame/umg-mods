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


function shapes.NorthEastShape(x)
    return UniDirectionalShape(1, -1, x, "NE-" .. tostring(x))
end
function shapes.NorthWestShape(x)
    return UniDirectionalShape(-1, -1, x, "NW-" .. tostring(x))
end
function shapes.SouthEastShape(x)
    return UniDirectionalShape(1, 1, x, "SE-" .. tostring(x))
end
function shapes.SouthWestShape(x)
    return UniDirectionalShape(-1, 1, x, "SW-" .. tostring(x))
end


function shapes.UpShape(x)
    return UniDirectionalShape(0, -1, x, "UP-" .. tostring(x))
end
function shapes.DownShape(x)
    return UniDirectionalShape(0, 1, x, "DOWN-" .. tostring(x))
end
function shapes.LeftShape(x)
    return UniDirectionalShape(-1, 0, x, "LEFT-" .. tostring(x))
end
function shapes.RightShape(x)
    return UniDirectionalShape(1, 0, x, "RIGHT-" .. tostring(x))
end

function shapes.HorizontalShape(x)
    return UnionShape(
        shapes.LeftShape(x),
        shapes.RightShape(x),
        "HORIZONTAL-" .. tostring(x)
    )
end

function shapes.VerticalShape(x)
    return UnionShape(
        shapes.UpShape(x),
        shapes.DownShape(x),
        "VERTICAL-" .. tostring(x)
    )
end



shapes.UP_SHAPE = shapes.UpShape(1)
shapes.DOWN_SHAPE = shapes.DownShape(1)
shapes.LEFT_SHAPE = shapes.LeftShape(1)
shapes.RIGHT_SHAPE = shapes.RightShape(1)

shapes.LEFT_RIGHT_SHAPE = UnionShape(shapes.LEFT, shapes.RIGHT, "LEFT-RIGHT")


return shapes
