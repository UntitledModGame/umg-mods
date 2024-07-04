local Shape = require("shared.Shape")

---@class lootplot.KingShape: lootplot.Shape
local KingShape = objects.Class("lootplot:KingShape"):implement(Shape)


---@param size integer?
function KingShape:init(size)
    self.size = size or 1
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

---@alias lootplot.KingShape_M lootplot.KingShape|fun(size:integer?):lootplot.KingShape
---@cast KingShape +lootplot.KingShape_M
return KingShape
