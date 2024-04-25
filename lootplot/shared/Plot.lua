
--[[

A grid object that contains entities
    (specifically, slot-entities)

Must have an owner entity;
the owner entity MUST reference plot by `ent.plot = Plot(...)`


]]

local Pipeline = require("shared.Pipeline")

local Plot = objects.Class("lootplot:Plot")

local ptrack = require("shared.internal.positionTracking")




local plotTc = typecheck.assert("entity", "number", "number")
function Plot:init(ownerEnt, width, height)
    plotTc(ownerEnt, width, height)

    ownerEnt.plot = self

    self.pipeline = Pipeline()

    self.ownerEnt = ownerEnt

    self.grid = objects.Grid(width,height) -- dummy grid; contains nothing

    self.slotGrid = objects.Grid(width,height) -- contains slots
    self.itemGrid = objects.Grid(width,height) -- contains items

    -- entities that we have already seen.
    --[[
        NOTE:
        `seenEntities` doesnt do anything rn,
        but if we want our code to be a bit more defensive in the future,
        we can use this to check for duplicates.

        (Can be used for asserting that the same entity doesnt exist in
            multiple slots)
    ]]
    self.seenEntities = {--[[
        [ent] = boolean
    ]]}
end





local INDEX = "number"
local ENT = "entity"

umg.definePacket("lootplot:setPlotSlot", {typelist = {ENT, INDEX, ENT}})
umg.definePacket("lootplot:clearPlotSlot", {typelist = {ENT, INDEX}})

function Plot:setSlot(index, slotEnt)
    local x,y = self.grid:indexToCoords(index)
    self.slotGrid:set(x,y, slotEnt)
    ptrack.set(slotEnt, lp.PPos({
        slot=index,
        plot=self
    }))
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





umg.definePacket("lootplot:setPlotItem", {typelist = {ENT, INDEX, ENT}})
umg.definePacket("lootplot:clearPlotItem", {typelist = {ENT, INDEX}})

function Plot:setItem(index, itemEnt)
    local x,y = self.grid:indexToCoords(index)
    self.itemGrid:set(x,y, itemEnt)
    ptrack.set(itemEnt, lp.PPos({
        slot=index,
        plot=self
    }))
    if server then
        local plotEnt = self.ownerEnt
        if itemEnt then
            server.broadcast("lootplot:setPlotItem", plotEnt, index, itemEnt)
        else
            server.broadcast("lootplot:clearPlotItem", plotEnt, index)
        end
    end
end

if client then
    client.on("lootplot:setPlotItem", function(plotEnt, index, itemEnt)
        plotEnt.plot:setItem(index, itemEnt)
    end)
    client.on("lootplot:clearPlotItem", function(plotEnt, index)
        plotEnt.plot:setItem(index, nil)
    end)
end





function Plot:getSlot(index)
    local x,y = self.grid:indexToCoords(index)
    local e = self.slotGrid:get(x,y)
    if umg.exists(e) then
        return e
    end
end

function Plot:getItem(index)
    local x,y = self.grid:indexToCoords(index)
    local e = self.itemGrid:get(x,y)
    if umg.exists(e) then
        return e
    end
end


function Plot:foreachInArea(x1,x2, y1,y2, func)
    local grid = self.grid
    return grid:foreachInArea(x1,x2,y1,y2, function(_val,x,y)
        local i = grid:coordsToIndex(x,y)
        local ppos = lp.PPos({slot=i, plot=self})
        func(ppos)
    end)
end



function Plot:indexToCoords(slotIndex)
    return self.grid:indexToCoords(slotIndex)
end

function Plot:coordsToIndex(x,y)
    return self.grid:coordsToIndex(x,y)
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
    self.grid:foreach(function(_val, x, y)
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

