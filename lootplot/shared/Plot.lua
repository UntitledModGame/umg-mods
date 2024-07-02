
--[[

A grid object that contains entities
    (specifically, slot-entities)

Must have an owner entity;
the owner entity MUST reference plot by `ent.plot = Plot(...)`


]]

local Pipeline = require("shared.Pipeline")

---@class lootplot.Plot: objects.Class
local Plot = objects.Class("lootplot:Plot")

local ptrack = require("shared.internal.positionTracking")




local plotTc = typecheck.assert("entity", "number", "number")
---@param ownerEnt Entity
---@param width integer
---@param height integer
function Plot:init(ownerEnt, width, height)
    plotTc(ownerEnt, width, height)

    ownerEnt.plot = self

    self.pipeline = Pipeline()

    self.ownerEnt = ownerEnt

    self.grid = objects.Grid(width,height) -- dummy grid; contains nothing.

    self.layers = {
        --[[
            todo: Do we want custom Layer objects here,
            instead of Grid objects?
        ]]
        ["slot"] = objects.Grid(width,height),
        ["item"] = objects.Grid(width,height),
        -- ... can define custom ones too!
    }

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



--[[

TODO: 
Use these methods instead

]]
local INDEX = "number"
local ENT = "entity"
local LAYER = "string"

umg.definePacket("lootplot:setPlotEntry", {typelist = {ENT, INDEX, ENT}})
umg.definePacket("lootplot:clearPlotEntry", {typelist = {ENT, INDEX, LAYER}})

---@param index integer
---@param ent lootplot.LayerEntity needs ent.layer comp
function Plot:set(index, ent)
    --[[
        ent needs ent.layer comp
    ]]
    assert(ent:isSharedComponent("layer"))
    --[[
        TODO: Should we guard against multiple attachment???
        hmmm... 
        Future mods may need this bahaviour
    ]]
    assert(not ptrack.get(ent), "attached somewhere else")

    local x,y = self.grid:indexToCoords(index)
    local grid = self.layers[ent.layer]
    grid:set(x,y, ent)
    ptrack.set(ent, lp.PPos({
        slot=index,
        plot=self
    }))
    if server then
        local plotEnt = self.ownerEnt
        server.broadcast("lootplot:setPlotEntry", plotEnt, index, ent)
    end
end


local clearTc = typecheck.assert('number', 'string')
---@param index integer
---@param layer string layer name
function Plot:clear(index, layer)
    clearTc(index, layer)
    local x,y = self.grid:indexToCoords(index)
    local grid = self.layers[layer]
    grid:set(x,y, nil)
    if server then
        local plotEnt = self.ownerEnt
        assert(self.layers[layer], "invalid layer")
        server.broadcast("lootplot:clearPlotEntry", plotEnt, index, layer)
    end
end


if client then
    client.on("lootplot:setPlotEntry", function(plotEnt, index, ent)
        plotEnt.plot:set(index, ent)
    end)
    client.on("lootplot:clearPlotEntry", function(plotEnt, index, layer)
        plotEnt.plot:clear(index, layer)
    end)
end






---@param index integer
---@return lootplot.SlotEntity?
function Plot:getSlot(index)
    local x,y = self.grid:indexToCoords(index)
    local e = self.layers.slot:get(x,y)
    if umg.exists(e) then
        return e
    end
end

---@param index integer
---@return lootplot.ItemEntity?
function Plot:getItem(index)
    local x,y = self.grid:indexToCoords(index)
    -- This is a bit hacky accessing the item layer directly
    local e = self.layers.item:get(x,y)
    if umg.exists(e) then
        return e
    end
end

---@param x1 integer
---@param x2 integer
---@param y1 integer
---@param y2 integer
---@param func fun(ppos:lootplot.PPos)
function Plot:foreachInArea(x1, y1, x2, y2, func)
    local grid = self.grid
    return grid:foreachInArea(x1, y1, x2, y2, function(_val,x,y)
        local i = grid:coordsToIndex(x,y)
        local ppos = lp.PPos({slot=i, plot=self})
        func(ppos)
    end)
end


---@param slotIndex integer
---@return integer,integer
function Plot:indexToCoords(slotIndex)
    return self.grid:indexToCoords(slotIndex)
end

---@param x integer
---@param y integer
---@return integer
function Plot:coordsToIndex(x,y)
    return self.grid:coordsToIndex(x,y)
end


---runs a function within a plot, buffered.
---@param fn fun(...:any)
---@param ... any
function Plot:queue(fn, ...)
    self.pipeline:push(fn, ...)
end

---@param time number
function Plot:wait(time)
    local mult = umg.ask("lootplot:getPipelineDelayMultiplier", self) or 1
    self.pipeline:wait(time * mult)
end



function Plot:tick()
    self.pipeline:tick()
end

---loops over all of the plot, including empty slots
---@param func fun(ppos:lootplot.PPos)
function Plot:foreach(func)
    self.grid:foreach(function(_val, x, y)
        local slotI = self.grid:coordsToIndex(x,y)
        local ppos = lp.PPos({
            plot = self,
            slot = slotI
        })
        func(ppos)
    end)
end

---loops over all slot-entities in plot
---@param func fun(ent:lootplot.SlotEntity,ppos:lootplot.PPos)
function Plot:foreachSlot(func)
    self:foreach(function(ppos)
        local slotEnt = lp.posToSlot(ppos)
        if slotEnt then
            func(slotEnt, ppos)
        end
    end)
end

---loops over all item-entities in plot
---@param func fun(ent:lootplot.ItemEntity,ppos:lootplot.PPos)
function Plot:foreachItem(func)
    self:foreach(function(ppos)
        local itemEnt = lp.posToItem(ppos)
        if itemEnt then
            func(itemEnt, ppos)
        end
    end)
end

---returns plot-position as a dimensionVector
---@param ppos lootplot.PPos
---@return spatial.DimensionVector
function Plot:pposToWorldCoords(ppos)
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


---gets the closest ppos to a (x,y) coord pair.
---
---**NOTE:**
---If the (x,y) coords is out of bounds, 
---it will STILL return the closest match!
---@param x number
---@param y number
---@return lootplot.PPos
function Plot:getClosestPPos(x,y)
    local plotEnt = self.ownerEnt
    local slotDist = lp.constants.WORLD_SLOT_DISTANCE
    local ix = math.round((x/slotDist) - plotEnt.x)
    local iy = math.round((y/slotDist) - plotEnt.y)

    local grid = self.grid
    ix = math.clamp(ix, 0, grid.width-1)
    iy = math.clamp(iy, 0, grid.height-1)

    local i = grid:coordsToIndex(ix,iy)
    return lp.PPos({
        slot = i,
        plot = self
    })
end

---@param triggerName string
function Plot:trigger(triggerName)
    self:foreach(function(ppos)
        local slotEnt = lp.posToSlot(ppos)

        if slotEnt then
            lp.triggerEntity(triggerName, slotEnt)
        end
    end)
end

function Plot:reset()
    return self:trigger("RESET")
end

---@cast Plot +fun(ownerEnt:Entity,width:integer,height:integer):lootplot.Plot
return Plot

