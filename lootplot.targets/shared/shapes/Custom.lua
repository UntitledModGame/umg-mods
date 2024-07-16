local Shape = require("shared.Shape")


---@class lootplot.targets.CustomShape: lootplot.targets.Shape
local CustomShape = objects.Class("lootplot.targets:CustomShape"):implement(Shape)

---@param func fun(ppos:lootplot.PPos):objects.Array
function CustomShape:init(func)
    self.func = func
end

---@param ppos lootplot.PPos
---@return objects.Array
function CustomShape:getTargets(ppos)
    return self.func(ppos)
end

---@cast CustomShape +fun(func:fun(ppos:lootplot.PPos):objects.Array):lootplot.targets.CustomShape
return CustomShape
