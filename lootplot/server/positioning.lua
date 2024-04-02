

--[[

Positioning code.

Automatically sets positions of entities according to their ppos.


]]


local worldPlotEnts = umg.group("plot", "worldPlot")




local function updateWorldPosition(plotEnt, slotEnt, ppos)
    local wp = plotEnt.worldPlot

    local slotDist = wp.slotDistance or constants.WORLD_SLOT_DISTANCE
    local ix, iy = ppos:getXY()
    
    --[[
        TODO: In future:::
        We shouldn't set `x,y` values here;
        we should set `targetX,targetY`, and then the entity should lerp
        towards those values automatically via some other system:
        umg.group("targetX", "targetY")
    ]]
    slotEnt.x = wp.x + ix*slotDist
    slotEnt.y = wp.y + iy*slotDist
end



umg.on("@tick", function(dt)
    for _, plotEnt in ipairs(worldPlotEnts) do
        local plot = plotEnt.plot
        plot:foreachSlot(function(slotEnt, ppos)
            updateWorldPosition(plotEnt, slotEnt, ppos)
        end)
    end
end)


