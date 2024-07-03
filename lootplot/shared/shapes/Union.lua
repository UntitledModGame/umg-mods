local Shape = require("shared.Shape")

---@class lootplot.UnionShape: lootplot.Shape
local UnionShape = objects.Class("lootplot:UnionShape"):implement(Shape)

---@param shape1 lootplot.Shape
---@param shape2 lootplot.Shape
---@param ... lootplot.Shape
function UnionShape:init(shape1, shape2, ...)
    self.shapes = {shape1, shape2, ...}
end

---@param pposes objects.Array
---@param dest objects.Array
---@param set objects.Set
local function insertNonDuplicatePPos(pposes, dest, set)
    for _, t in ipairs(pposes) do
        ---@cast t lootplot.PPos
        if not set:contains(t:getSlotIndex()) then
            dest:add(t)
        end
    end
end

---@param ppos lootplot.PPos
---@return objects.Array
function UnionShape:getTargets(ppos)
    local usedIndex = objects.Set()
    local newTargets = objects.Array()

    for _, s in ipairs(self.shapes) do
        insertNonDuplicatePPos(s:getTargets(ppos), newTargets, usedIndex)
    end

    return newTargets
end

---@alias lootplot.UnionShape_M lootplot.UnionShape|fun(shape1:lootplot.Shape,shape2:lootplot.Shape,...:lootplot.Shape):lootplot.UnionShape
---@cast UnionShape +lootplot.UnionShape_M
return UnionShape
