local Shape = require("shared.Shape")

---@class lootplot.UniDirectionalShape: lootplot.Shape
local UniDirectionalShape = objects.Class("lootplot:UniDirectionalShape"):implement(Shape)

---@param dx integer
---@param dy integer
---@param length integer?
function UniDirectionalShape:init(dx, dy, length)
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

---@alias lootplot.UniDirectionalShape_M lootplot.UniDirectionalShape|fun(dx:integer,dy:integer,length:integer?):lootplot.UniDirectionalShape
---@cast UniDirectionalShape +lootplot.UniDirectionalShape_M
return UniDirectionalShape
