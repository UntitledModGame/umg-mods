local Shape = require("shared.Shape")

---@class lootplot.KingShape: lootplot.Shape
local KingShape = objects.Class("lootplot:KingShape"):implement(Shape)

local OFFSETS = {-1, 0, 1}
local LARGE_OFFSETS = {-2, -1, 0, 1, 2}

---@param size integer?
function KingShape:init(size)
    self.size = size or 1
end

---@param ppos lootplot.PPos
function KingShape:getTargets(ppos)
    local result = objects.Array()

    for dx = -self.size, self.size do
        for dy = -self.size, self.size do
            if dx ~= 0 and dy ~= 0 then
                Shape.tryInsertPosition(ppos, dx, dy, result)
            end
        end
    end

    return result
end

---@cast KingShape +fun(size:integer?):lootplot.KingShape
return KingShape
