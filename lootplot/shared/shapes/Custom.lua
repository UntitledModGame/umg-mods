local Shape = require("shared.Shape")

local DIRECTION = {-1, 1}

---@class lootplot.CustomShape: lootplot.Shape
local CustomShape = objects.Class("lootplot:CustomShape"):implement(Shape)

---@param func fun(ppos:lootplot.PPos):objects.Array
function CustomShape:init(func)
    self.func = func
end

---@param ppos lootplot.PPos
---@return objects.Array
function CustomShape:getTargets(ppos)
    return func(ppos)
end

---@cast CustomShape +fun(func:fun(ppos:lootplot.PPos):objects.Array):lootplot.CustomShape
return CustomShape
