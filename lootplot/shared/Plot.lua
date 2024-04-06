
--[[

A grid object that contains entities
    (specifically, slot-entities)

Must have an owner entity;
the owner entity MUST reference plot by `ent.plot = Plot(...)`


]]

local Plot = objects.Class("lootplot:Plot")




local plotTc = typecheck.assert("entity", "number", "number")
function Plot:init(ownerEnt, width, height)
    plotTc(ownerEnt, width, height)

    ownerEnt.plot = self

    self.pipeline = lp.Pipeline()

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



function Plot:run(fn, ...)
    local delay = umg.ask("lootplot:getPipelineDelay", self) or 0
    delay = delay + lp.options.PIPELINE_DELAY
    local mult = umg.ask("lootplot:getPipelineDelayMultiplier", self)
    self.pipeline:push(fn, delay*mult, ...)
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



return Plot

