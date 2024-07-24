local Shape = require("shared.Shape")

---@class lootplot.targets.UnionShape: lootplot.targets.Shape
local UnionShape = objects.Class("lootplot.targets:UnionShape"):implement(Shape)

---@param shape1 lootplot.targets.Shape
---@param shape2 lootplot.targets.Shape
---@param ... lootplot.targets.Shape|string
function UnionShape:init(shape1, shape2, ...)
    self.shapes = {shape1, shape2, ...}

    local last = self.shapes[#self.shapes]
    local name = "Union Shape"
    if type(last) == "string" then
        -- This is the name
        table.remove(self.shapes)
        name = last
    end

    Shape.init(self, name)
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

---@alias lootplot.UnionShape_M lootplot.targets.UnionShape|fun(shape1:lootplot.targets.Shape,shape2:lootplot.targets.Shape,...:lootplot.targets.Shape|string):lootplot.targets.UnionShape
---@cast UnionShape +lootplot.UnionShape_M
return UnionShape
