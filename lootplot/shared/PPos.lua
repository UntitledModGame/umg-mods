
--[[

PlotPosition class,
aka, PPos.


A plotPosition, or ppos, represents a position in a plot.
At it's core, a plotPosition is a struct:

{
    slot = 12,
    plot = Plot
}

]]

---@class lootplot.PPos: objects.Class
local PPos = objects.Class("lootplot:PPos")

---@param args {slot:integer,plot:lootplot.Plot?,plotEntity:Entity?}
function PPos:init(args)
    lp.posTc(args)
    ---@private
    self.slot = args.slot
    if args.plotEntity then
        assert(args.plotEntity.plot, "Invalid plot entity! (needs .plot comp)")
        ---@private
        self.plotEntity =  args.plotEntity
    elseif args.plot then
        ---@private
        self.plotEntity = args.plot:getOwnerEntity()
    end
end


---@return lootplot.Plot
function PPos:getPlot()
    return self.plotEntity.plot
end


---@cast PPos +fun(args:{slot:integer,plot:lootplot.Plot,rotation?:number}):lootplot.PPos
local number2Tc = typecheck.assert("number", "number")
---@param dx integer
---@param dy integer
---@return lootplot.PPos?
function PPos:move(dx, dy)
    number2Tc(dx, dy)
    if dx == 0 and dy == 0 then
        return self
    end

    local plot = self:getPlot()
    local x, y = plot:indexToCoords(self.slot)
    x = x + dx
    y = y + dy

    if plot.grid:contains(x, y) then
        return plot:getPPos(x, y)
    end

    return nil
end


---@param n integer
---@return lootplot.PPos?
function PPos:up(n)
    n = n or 1
    return self:move(0,-n)
end

---@param n integer
---@return lootplot.PPos?
function PPos:left(n)
    n = n or 1
    return self:move(-n,0)
end

---@param n integer
---@return lootplot.PPos?
function PPos:right(n)
    n = n or 1
    return self:move(n,0)
end

---@param n integer
---@return lootplot.PPos?
function PPos:down(n)
    n = n or 1
    return self:move(0,n)
end


---@return integer,integer
function PPos:getCoords()
    -- gets XY coords of PPos
    local plot = self:getPlot()
    return plot:indexToCoords(self.slot)
end

---@return integer
function PPos:getSlotIndex()
    return self.slot
end

---@return number x, number y, string? dimension, number? z
function PPos:getWorldPos()
    return self:getPlot():pposToWorldCoords(self)
end

function PPos:__tostring()
    local plot = self:getPlot()
    local x, y = plot:indexToCoords(self.slot)
    return string.format("(%d, %d; index=%d, plot=%p)", x, y, self.slot, plot)
end

---@param ent lootplot.LayerEntity
function PPos:set(ent)
    --[[
    WARNING: This is a very low-level function!!!
        dont call this unless ur a pro
    ]]
    local plot = self:getPlot()
    local x,y = plot:indexToCoords(self.slot)
    return plot:set(x,y, ent)
end

---@param layer string
function PPos:clear(layer)
    return self:getPlot():clear(self.slot, layer)
end

---This gets the delta positions of `other` - `self`.
---@param other lootplot.PPos
function PPos:getDifference(other)
    local plot = self:getPlot()
    if plot ~= other:getPlot() then
        return math.huge, math.huge
    end

    local x1, y1 = plot:indexToCoords(self.slot)
    local x2, y2 = plot:indexToCoords(other.slot)
    return x2 - x1, y2 - y1
end

return PPos
