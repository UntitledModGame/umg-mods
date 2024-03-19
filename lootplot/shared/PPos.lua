
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
    posTc(ppos)
    self.slot = ppos.slot
    self.plot = ppos.plot
end


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
        slot = newSlot
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



function PPos:isInside()
    local grid = self.plot.grid
    local x,y = grid:indexToCoords(self.slot)
    return grid:contains(x,y)
end


