local Shape = require("shared.Shape")

---@class lootplot.targets.KingShape: lootplot.targets.Shape
local KingShape = objects.Class("lootplot.targets:KingShape"):implement(Shape)


---@param size integer?
---@param name string?
function KingShape:init(size, name)
    self.size = size or 1
    Shape.init(self, name or ("KING-"..self.size))
end

---@param ppos lootplot.PPos
function KingShape:getTargets(ppos)
    local result = objects.Array()

    for dx = -self.size, self.size do
        for dy = -self.size, self.size do
            if not (dx == 0 and dy == 0) then
                Shape.tryInsertPosition(ppos, dx, dy, result)
            end
        end
    end

    return result
end

---@alias lootplot.KingShape_M lootplot.targets.KingShape|fun(size:integer?,name:string?):lootplot.targets.KingShape
---@cast KingShape +lootplot.KingShape_M
return KingShape
