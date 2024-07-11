
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
_G.PPos = PPos

---@param args {slot:integer,plot:lootplot.Plot?,plotEntity:Entity?,rotation?:number}
function PPos:init(args)
    lp.posTc(args)
    self.slot = args.slot
    if args.plotEntity then
        self.plotEntity =  args.plotEntity
    elseif args.plot then
        self.plotEntity = args.plot:getOwnerEntity()
    end
    self.rotation = args.rotation or 0
end


---@return lootplot.Plot
function PPos:getPlot()
    return self.plotEntity.plot
end


local ROTATIONS = {
    -- ac +ve
    [0] = function(x,y) return x,y end,
    [1] = function(x,y) return -y,x end,
    [2] = function(x,y) return -x,-y end,
    [3] = function(x,y) return y,-x end
}

---@cast PPos +fun(args:{slot:integer,plot:lootplot.Plot,rotation?:number}):lootplot.PPos
local number2Tc = typecheck.assert("number", "number")
---@param dx integer
---@param dy integer
---@return lootplot.PPos?
function PPos:move(dx, dy)
    number2Tc(dx, dy)
    local plot = self.plot
    local x,y = plot:indexToCoords(self.slot)
    x = x + dx
    y = y + dy

    if self.plot.grid:contains(x, y) then
        local newSlot = plot:coordsToIndex(x,y)
        return PPos({
            plot = plot,
            slot = newSlot,
            rotation = self.rotation
        })
    end

    return nil
end


---It's quite "bad" to create a bunch of garbage like this....
---But I dont forsee this game becoming heavy performance-wise.
---So its gonna slide for now.
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
    return self.plot:indexToCoords(self.slot)
end

---@return integer
function PPos:getSlotIndex()
    return self.slot
end

---@return spatial.DimensionVector
function PPos:getWorldPos()
    return self.plot:pposToWorldCoords(self)
end



---@param ent lootplot.LayerEntity
function PPos:set(ent)
    return self.plot:set(self.slot, ent)
end

---@param ent lootplot.LayerEntity
function PPos:clear(ent)
    return self.plot:clear(self.slot, ent.layer)
end

---This gets the delta positions of `other` - `self`.
---@param other lootplot.PPos
function PPos:getDifference(other)
    if self.plot ~= other.plot then
        return math.huge, math.huge
    end

    local x1, y1 = self.plot:indexToCoords(self.slot)
    local x2, y2 = self.plot:indexToCoords(other.slot)
    return x2 - x1, y2 - y1
end

return PPos
