local targets = {}

local util = require("shared.util")

-- Shape exports
local Shape = require("shared.Shape")
local CustomShape = require("shared.shapes.Custom")
local KingShape = require("shared.shapes.King")
local UnionShape = require("shared.shapes.Union")
local UniDirectionalShape = require("shared.shapes.UniDirectional")

local MAX_DISTANCE = 40

-- This is the class objects
targets.Shape = Shape
targets.KingShape = KingShape
targets.UnionShape = UnionShape
targets.UniDirectionalShape = UniDirectionalShape

-- Simple helper

---@param size integer?
function targets.PlusShape(size)
    return UnionShape(
        UniDirectionalShape(1, 0, size),
        UniDirectionalShape(0, 1, size),
        UniDirectionalShape(-1, 0, size),
        UniDirectionalShape(0, -1, size)
    )
end

---@param size integer?
function targets.CrossShape(size)
    return UnionShape(
        UniDirectionalShape(1, 1, size),
        UniDirectionalShape(-1, 1, size),
        UniDirectionalShape(-1, -1, size),
        UniDirectionalShape(1, -1, size)
    )
end

-- Pre-defined shape instance
targets.KING_SHAPE = KingShape(1)
targets.LARGE_KING_SHAPE = KingShape(2)
targets.ROOK_SHAPE = targets.PlusShape(MAX_DISTANCE)
targets.BISHOP_SHAPE = targets.CrossShape(MAX_DISTANCE)
targets.QUEEN_SHAPE = UnionShape(targets.ROOK_SHAPE, targets.BISHOP_SHAPE)
targets.KNIGHT_SHAPE = CustomShape(function(ppos)
    local result = objects.Array()

    for mx = -1, 1, 2 do
        for my = -1, 1, 2 do
            Shape.tryInsertPosition(ppos, 2 * mx, 1 * my, result)
            Shape.tryInsertPosition(ppos, 1 * mx, 2 * my, result)
        end
    end

    return result
end)
targets.ABOVE_SHAPE = UniDirectionalShape(0, -1, 1)

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
function targets.getTargets(itemEnt)
    local pos = lp.getPos(itemEnt)
    local tgt

    if itemEnt.shape and pos then
        tgt = itemEnt.shape:getTargets(pos)
        ---@cast tgt objects.Array

        if tgt then
            tgt:sortInPlace(sortPPos(pos))
        end
    end

    return tgt
end

-- How dare you overwriting lp.targets before us! You deserve getting rickrolled!
assert(not lp.targets, "Never gonna give you up, never gonna let you down!")
lp.targets = targets
