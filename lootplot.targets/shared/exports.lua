local targets = {}

local util = require("shared.util")

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


targets.KingShape = KingShape
targets.UnionShape = UnionShape
targets.OffsetShape = OffsetShape
targets.RotationShape = RotationShape
targets.UniDirectionalShape = UniDirectionalShape
targets.CircleShape = CircleShape


---@alias lootplot.targets.ShapeFactory fun(size, name): lootplot.targets.ShapeData



---@param size integer?
---@param name string?
---@return lootplot.targets.ShapeData
function targets.RookShape(size, name)
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
function targets.BishopShape(size, name)
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
function targets.QueenShape(size, name)
    return UnionShape(
        targets.RookShape(size),
        targets.BishopShape(size),
        name or ("QUEEN-" .. tostring(size))
    )
end


-- Pre-defined shape instance
targets.KING_SHAPE = KingShape(1)
targets.LARGE_KING_SHAPE = KingShape(2)
targets.ROOK_SHAPE = targets.RookShape(MAX_DISTANCE, "ROOK-BIG")
targets.BISHOP_SHAPE = targets.BishopShape(MAX_DISTANCE, "BISHOP-BIG")
targets.QUEEN_SHAPE = UnionShape(targets.ROOK_SHAPE, targets.BISHOP_SHAPE, "QUEEN-BIG")
---@type lootplot.targets.ShapeData
targets.KNIGHT_SHAPE = {
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

targets.ON_SHAPE = {
    name = "ON",
    relativeCoords = {
        {0,0}
    }
}

targets.ABOVE_SHAPE = UniDirectionalShape(0, -1, 1, "ABOVE")
targets.BELOW_SHAPE = UniDirectionalShape(0, 1, 1, "BELOW")

targets.ABOVE_BELOW_SHAPE = UnionShape(targets.ABOVE_SHAPE, targets.BELOW_SHAPE, "ABOVE-BELOW")


---@param basePPos lootplot.PPos
local function sortPPos(basePPos)
    ---@param a lootplot.PPos
    ---@param b lootplot.PPos
    return function(a, b)
        return util.chebyshevDistance(a:getDifference(basePPos)) < util.chebyshevDistance(b:getDifference(basePPos))
    end
end

---@param itemEnt lootplot.ItemEntity
---@return objects.Array?
function targets.getShapePositions(itemEnt)
    local pos = lp.getPos(itemEnt)
    local targetList

    if itemEnt.shape and pos then
        targetList = objects.Array()

        for _, coords in ipairs(itemEnt.shape.relativeCoords) do
            local newPpos = pos:move(coords[1], coords[2])

            if newPpos then
                targetList:add(newPpos)
            end
        end

        if targetList then
            targetList:sortInPlace(sortPPos(pos))
        end
    end

    return targetList
end

---@param itemEnt lootplot.ItemEntity
---@param shape lootplot.targets.ShapeData
function targets.setShape(itemEnt, shape)
    itemEnt.shape = shape
    sync.syncComponent(itemEnt, "shape")
end


targets.TARGET_COLOR = {1, 0.65, 0.35}
targets.LISTEN_COLOR = {0.35, 0.65, 1}


-- How dare you overwriting lp.targets before us!
assert(not lp.targets, "\27]8;;https://youtu.be/dQw4w9WgXcQ\27\\Unexpected error! open the link for more information.\27]8;;\27\\")
---Availability: Client and Server
lp.targets = targets
