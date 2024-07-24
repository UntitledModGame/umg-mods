---@class lootplot.targets.Shape: objects.Class
local Shape = objects.Class("lootplot.targets:Shape")

---@param name string?
function Shape:init(name)
    self.name = name or ""
end

---@param ppos lootplot.PPos
---@return objects.Array
function Shape:getTargets(ppos)
    return objects.Array()
end

function Shape:getName()
    return self.name
end

---@param name string
function Shape:setName(name)
    self.name = name or ""
end

---@param ppos lootplot.PPos
---@param dx integer
---@param dy integer
---@param dest objects.Array
---@return boolean
function Shape.tryInsertPosition(ppos, dx, dy, dest)
    local newPPos = ppos:move(dx, dy)
    if newPPos then
        dest:add(newPPos)
    end

    return not not newPPos
end

return Shape
