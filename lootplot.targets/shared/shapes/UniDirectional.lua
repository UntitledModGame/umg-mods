local Shape = require("shared.Shape")

---@class lootplot.targets.UniDirectionalShape: lootplot.targets.Shape
local UniDirectionalShape = objects.Class("lootplot.targets:UniDirectionalShape"):implement(Shape)

---@param dx integer
---@param dy integer
---@param length integer?
---@param name string?
function UniDirectionalShape:init(dx, dy, length, name)
    Shape.init(self, name or "Uni-directional Shape")
    self.length = length or 1
    self.dx = dx
    self.dy = dy
end

---@param ppos lootplot.PPos
---@return objects.Array
function UniDirectionalShape:getTargets(ppos)
    local result = objects.Array()

    for i = 1, self.length do
        if not Shape.tryInsertPosition(ppos, self.dx * i, self.dy * i, result) then
            break
        end
    end

    return result
end

---@alias lootplot.UniDirectionalShape_M lootplot.targets.UniDirectionalShape|fun(dx:integer,dy:integer,length:integer?,name:string?):lootplot.targets.UniDirectionalShape
---@cast UniDirectionalShape +lootplot.UniDirectionalShape_M
return UniDirectionalShape
