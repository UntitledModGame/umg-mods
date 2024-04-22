
--[[

A grid object that contains entities
    (specifically, slot-entities)

Must have an owner entity;
the owner entity MUST reference plot by `ent.plot = Plot(...)`


]]

local Pipeline = require("shared.Pipeline")

local Plot = objects.Class("lootplot:Plot")




local plotTc = typecheck.assert("entity", "number", "number")
function Plot:init(ownerEnt, width, height)
    plotTc(ownerEnt, width, height)

    ownerEnt.plot = self

    self.pipeline = Pipeline()

    self.ownerEnt = ownerEnt
    self.grid = objects.Grid(width,height)
end





local INDEX = "number"
local ENT = "entity"

umg.definePacket("lootplot:setPlotSlot", {
    typelist = {ENT, INDEX, ENT}
})

umg.definePacket("lootplot:clearPlotSlot", {
    typelist = {ENT, INDEX}
})

function Plot:setSlot(index, slotEnt)
    local x,y = self.grid:indexToCoords(index)
    self.grid:set(x,y, slotEnt)
    if server then
        local plotEnt = self.ownerEnt
        if slotEnt then
            server.broadcast("lootplot:setPlotSlot", plotEnt, index, slotEnt)
        else
            server.broadcast("lootplot:clearPlotSlot", plotEnt, index)
        end
    end
end


if client then
    client.on("lootplot:setPlotSlot", function(plotEnt, index, slotEnt)
        plotEnt.plot:setSlot(index, slotEnt)
    end)
    client.on("lootplot:clearPlotSlot", function(plotEnt, index)
        plotEnt.plot:setSlot(index, nil)
    end)
end



function Plot:getSlot(index)
    local x,y = self.grid:indexToCoords(index)
    local e = self.grid:get(x,y)
    if umg.exists(e) then
        return e
    end
end



function Plot:queue(fn, ...)
    --[[
        runs a function within a plot, buffered.
    ]]
    self.pipeline:push(fn, ...)
end


function Plot:wait(time)
    local mult = umg.ask("lootplot:getPipelineDelayMultiplier", self) or 1
    self.pipeline:wait(time * mult)
end



function Plot:tick()
    self.pipeline:tick()
end


function Plot:foreach(func)
    --[[
        loops over all of the plot, including empty slots
    ]]
    self.grid:foreach(function(_ent, x, y)
        local slotI = self.grid:coordsToIndex(x,y)
        local ppos = lp.PPos({
            plot = self,
            slot = slotI
        })
        func(ppos)
    end)
end


function Plot:foreachSlot(func)
    -- loops over all slot-entities in plot
    self:foreach(function(ppos)
        local slotEnt = lp.posToSlot(ppos)
        if slotEnt then
            func(slotEnt, ppos)
        end
    end)
end

function Plot:foreachItem(func)
    -- loops over all item-entities in plot
    self:foreach(function(ppos)
        local itemEnt = lp.posToItem(ppos)
        if itemEnt then
            func(itemEnt, ppos)
        end
    end)
end


function Plot:pposToWorldCoords(ppos)
    --[[
        returns plot-position as a dimensionVector
    ]]
    local plotEnt = self.ownerEnt
    assert(plotEnt.x and plotEnt.y, "Cannot get world position of a Plot when owner ent doesn't have x,y components")
    local ix,iy = ppos:getCoords()
    local slotDist = lp.constants.WORLD_SLOT_DISTANCE
    local x = plotEnt.x + ix*slotDist
    local y = plotEnt.y + iy*slotDist
    return {
        x = x, y = y,
        dimension = plotEnt.dimension
    }
end



local function round(x)
    return math.floor(x+0.5)
end

function Plot:getClosestPPos(x,y)
    --[[
        gets the closest ppos to a (x,y) coord pair.
        NOTE:
        If the (x,y) coords is out of bounds, 
        it will STILL return the closest match!
    ]]
    local plotEnt = self.ownerEnt
    local slotDist = lp.constants.WORLD_SLOT_DISTANCE
    local ix = round((x/slotDist) - plotEnt.x)
    local iy = round((y/slotDist) - plotEnt.y)

    local grid = self.grid
    ix = math.clamp(ix, 0, grid.width-1)
    iy = math.clamp(iy, 0, grid.height-1)

    local i = grid:coordsToIndex(ix,iy)
    return lp.PPos({
        slot = i,
        plot = self
    })
end



return Plot

