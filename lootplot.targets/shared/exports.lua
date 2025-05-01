---@class lootplot.targets
local targets = {}

local util = require("shared.util")
local shapes = require("shared.shapes")

-- Shape exports
targets.KingShape = shapes.KingShape
targets.UnionShape = shapes.UnionShape
targets.OffsetShape = shapes.OffsetShape
targets.RotationShape = shapes.RotationShape
targets.UniDirectionalShape = shapes.UniDirectionalShape
targets.CircleShape = shapes.CircleShape
targets.RookShape = shapes.RookShape
targets.BishopShape = shapes.BishopShape
targets.QueenShape = shapes.QueenShape

targets.VerticalShape = shapes.VerticalShape
targets.HorizontalShape = shapes.HorizontalShape

targets.UpShape = shapes.UpShape
targets.DownShape = shapes.DownShape
targets.LeftShape = shapes.LeftShape
targets.RightShape = shapes.RightShape

targets.NorthEastShape = shapes.NorthEastShape
targets.NorthWestShape = shapes.NorthWestShape
targets.SouthEastShape = shapes.SouthEastShape
targets.SouthWestShape = shapes.SouthWestShape


-- Pre-defined shape instance
targets.KING_SHAPE = shapes.KING_SHAPE
targets.LARGE_KING_SHAPE = shapes.LARGE_KING_SHAPE
targets.ROOK_SHAPE = shapes.ROOK_SHAPE
targets.BISHOP_SHAPE = shapes.BISHOP_SHAPE
targets.QUEEN_SHAPE = shapes.QUEEN_SHAPE
targets.KNIGHT_SHAPE = shapes.KNIGHT_SHAPE

targets.ON_SHAPE = shapes.ON_SHAPE

targets.UP_SHAPE = shapes.UP_SHAPE
targets.DOWN_SHAPE = shapes.DOWN_SHAPE


---@param basePPos lootplot.PPos
local function sortPPos(basePPos)
    ---@param a lootplot.PPos
    ---@param b lootplot.PPos
    return function(a, b)
        return util.chebyshevDistance(a:getDifference(basePPos)) < util.chebyshevDistance(b:getDifference(basePPos))
    end
end

---@param itemEnt lootplot.ItemEntity
---@return lootplot.PPos[]?
function targets.getTargets(itemEnt)
    local pos = lp.getPos(itemEnt)
    local targetList = nil

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
---@return Entity[]
function targets.getConvertedTargets(itemEnt)
    local targetList = targets.getTargets(itemEnt)
    if not targetList then
        return objects.Array()
    end
    targetList = objects.Array(targetList)

    local target = itemEnt.target
    local convertType = target and target.type
    if convertType then
        local ret = targetList:map(function(ppos)
            local ok, ent = lp.tryConvert(ppos, convertType)
            if target then
                ok = ok and util.canTarget(itemEnt, ppos)
            end
            if ok then
                if not umg.exists(ent) then
                    -- convertType must convert ppos -> ent, or else this function's "promise" is violated
                    umg.melt("invalid target-type for entity: " .. tostring(itemEnt))
                end
                return ent
            end
        end)
        return ret
    else
        -- no convertType..? I guess we just return empty.
        return {}
    end
end




---@param itemEnt lootplot.ItemEntity
---@return lootplot.PPos[]
function targets.getValidTargets(itemEnt)
    local targetList = targets.getTargets(itemEnt)
    if not targetList then
        return objects.Array()
    end
    targetList = objects.Array(targetList)

    local target = itemEnt.target
    if target then
        local convertType = target.type
        local ret = targetList:map(function(ppos)
            local ok = true
            if convertType then
                ok, _ = lp.tryConvert(ppos, convertType)
            end
            ok = ok and util.canTarget(itemEnt, ppos)
            if ok then
                return ppos
            end
        end)
        return ret
    else
        -- no convertType..? I guess we just return empty.
        return {}
    end
end






---@param itemEnt lootplot.ItemEntity
---@param shape lootplot.targets.ShapeData
function targets.setShape(itemEnt, shape)
    itemEnt.shape = shape
    sync.syncComponent(itemEnt, "shape")
end


targets.TARGET_COLOR = {1, 0.6, 0.3}


-- How dare you overwriting lp.targets before us!
assert(not lp.targets, "\27]8;;https://youtu.be/dQw4w9WgXcQ\27\\Unexpected error! open the link for more information.\27]8;;\27\\")
---Availability: Client and Server
lp.targets = targets
