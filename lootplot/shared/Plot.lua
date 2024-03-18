
--[[

A grid object that contains entities
    (specifically, slot-entities)

Must have an owner entity;
the owner entity MUST reference plot by `ent.plot = Plot(...)`


]]

local Plot = objects.Class("lootplot:Plot")



local gridTc = typecheck.assert("entity", "number", "number")
function Plot:init(ownerEnt, width, height)
    gridTc(width, height)

    ownerEnt.plot = self

    self.owner = ownerEnt
    self.grid = objects.Grid(width,height)
end



function Plot:setSlot(index, slotEnt)
    local x,y = self.grid:indexToCoords(index)
    self.grid:set(x,y, slotEnt)
    if server then
        if slotEnt then
            server.broadcast("lootplot:setPlotSlot", index, slotEnt)
        else
            server.broadcast("lootplot:clearPlotSlot", index)
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



function Plot:foreach(func)
    self.grid:foreach(function(val, x, y)
        local slotI = self.grid:coordsToIndex(x,y)
        func(val, slotI)
    end)
end



return Plot

