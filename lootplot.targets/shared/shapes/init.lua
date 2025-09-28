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

local function l(txt)
    return localization.localize(txt)
end

local ROOK_STR = l("ROOK")
---@param size integer?
---@param name string?
---@return lootplot.targets.ShapeData
function shapes.RookShape(size, name)
    return UnionShape(
        UniDirectionalShape(1, 0, size),
        UniDirectionalShape(0, 1, size),
        UniDirectionalShape(-1, 0, size),
        UniDirectionalShape(0, -1, size),
        name or (ROOK_STR .. "-" .. tostring(size))
    )
end

--- BISHOP Shape
local BISHOP_STR = l("BISHOP")
---@param size integer?
---@param name string?
---@return lootplot.targets.ShapeData
function shapes.BishopShape(size, name)
    return UnionShape(
        UniDirectionalShape(1, 1, size),
        UniDirectionalShape(-1, 1, size),
        UniDirectionalShape(-1, -1, size),
        UniDirectionalShape(1, -1, size),
        name or (BISHOP_STR .. "-" .. tostring(size))
    )
end

local QUEEN_STR = l("QUEEN")
---@param size integer?
---@return lootplot.targets.ShapeData
function shapes.QueenShape(size, name)
    return UnionShape(
        shapes.RookShape(size),
        shapes.BishopShape(size),
        name or (QUEEN_STR .. "-" .. tostring(size))
    )
end


-- Pre-defined shape instance

local KING_STR = l("KING")
shapes.KING_SHAPE = KingShape(1, KING_STR .. "-1")
shapes.LARGE_KING_SHAPE = KingShape(2, KING_STR .. "-2")

local ROOK_BIG_STR = l("ROOK-BIG")
local BISHOP_BIG_STR = l("BISHOP-BIG")
local QUEEN_BIG_STR = l("QUEEN-BIG")
shapes.ROOK_SHAPE = shapes.RookShape(MAX_DISTANCE, ROOK_BIG_STR)
shapes.BISHOP_SHAPE = shapes.BishopShape(MAX_DISTANCE, BISHOP_BIG_STR)
shapes.QUEEN_SHAPE = UnionShape(shapes.ROOK_SHAPE, shapes.BISHOP_SHAPE, QUEEN_BIG_STR)

local KNIGHT_STR = l("KNIGHT")
---@type lootplot.targets.ShapeData
shapes.KNIGHT_SHAPE = {
    name = KNIGHT_STR,
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

local ON_STR = l("ON")
shapes.ON_SHAPE = {
    name = ON_STR,
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


local UP_STR = l("UP")
function shapes.UpShape(x)
    return UniDirectionalShape(0, -1, x, UP_STR .. "-" .. tostring(x))
end
local DOWN_STR = l("DOWN")
function shapes.DownShape(x)
    return UniDirectionalShape(0, 1, x, DOWN_STR .. "-" .. tostring(x))
end
local LEFT_STR = l("LEFT")
function shapes.LeftShape(x)
    return UniDirectionalShape(-1, 0, x, LEFT_STR .. "-" .. tostring(x))
end
local RIGHT_STR = l("RIGHT")
function shapes.RightShape(x)
    return UniDirectionalShape(1, 0, x, RIGHT_STR .. "-" .. tostring(x))
end

local HORIZONTAL_STR = l("HORIZONTAL")
function shapes.HorizontalShape(x)
    return UnionShape(
        shapes.LeftShape(x),
        shapes.RightShape(x),
        HORIZONTAL_STR .. "-" .. tostring(x)
    )
end

local VERTICAL_STR = l("VERTICAL")
function shapes.VerticalShape(x)
    return UnionShape(
        shapes.UpShape(x),
        shapes.DownShape(x),
        VERTICAL_STR .. "-" .. tostring(x)
    )
end


shapes.UP_SHAPE = shapes.UpShape(1)
shapes.DOWN_SHAPE = shapes.DownShape(1)
shapes.LEFT_SHAPE = shapes.LeftShape(1)
shapes.RIGHT_SHAPE = shapes.RightShape(1)

local LEFT_RIGHT_STR = l("LEFT-RIGHT")
shapes.LEFT_RIGHT_SHAPE = UnionShape(shapes.LEFT_SHAPE, shapes.RIGHT_SHAPE, LEFT_RIGHT_STR)


return shapes
