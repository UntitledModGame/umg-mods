
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


local PPos = objects.Class("lootplot:PPos")
_G.PPos = PPos


function PPos:init(ppos)
    lp.posTc(ppos)
    self.slot = ppos.slot
    self.plot = ppos.plot
    self.rotation = ppos.rotation or 0
end


local ROTATIONS = {
    -- ac +ve
    [0] = function(x,y) return x,y end,
    [1] = function(x,y) return -y,x end,
    [2] = function(x,y) return -x,-y end,
    [3] = function(x,y) return y,-x end
}


local number2Tc = typecheck.assert("number", "number")
function PPos:move(dx, dy)
    number2Tc(dx, dy)
    local plot = self.plot
    local x,y = plot.grid:indexToCoords(self.slot)
    x = x + dx
    y = y + dy
    local newSlot = plot.grid:coordsToIndex(x,y)
    return PPos({
        plot = plot,
        slot = newSlot,
        rotation = self.rotation
    })
end


--[[
    It's quite "bad" to create a bunch of garbage like this....
    But I dont forsee this game becoming heavy performance-wise.
    So its gonna slide for now.
]]
function PPos:up(n)
    n = n or 1
    return self:move(0,-n)
end
function PPos:left(n)
    n = n or 1
    return self:move(-n,0)
end
function PPos:right(n)
    n = n or 1
    return self:move(n,0)
end
function PPos:down(n)
    n = n or 1
    return self:move(0,n)
end



function PPos:getCoords()
    -- gets XY coords of PPos
    return self.plot.grid:indexToCoords(self.slot)
end


function PPos:getWorldPos()
    --[[
        returns plot-position as a dimensionVector
        TODO:
        This code feels kinda dirty.. idk why
    ]]
    local plotEnt = self.plot.ownerEnt
    assert(plotEnt.x and plotEnt.y, "Cannot get world position of a Plot when owner ent doesn't have x,y components")
    local ix,iy = self:getCoords()
    local slotDist = constants.WORLD_SLOT_DISTANCE
    local x = plotEnt.x + ix*slotDist
    local y = plotEnt.y + iy*slotDist
    return {
        x = x, y = y,
        dimension = plotEnt.dimension
    }
end



function PPos:isInPlot()
    local grid = self.plot.grid
    local x,y = grid:indexToCoords(self.slot)
    return grid:contains(x,y)
end




return PPos
