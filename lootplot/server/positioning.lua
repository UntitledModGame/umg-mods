

--[[

Positioning code.

Automatically sets positions of entities according to their ppos.


]]


local worldPlotEnts = umg.group("plot", "x", "y")


local function updateItem(itemEnt, slotEnt)
    itemEnt.targetX, itemEnt.targetY = slotEnt.x, slotEnt.y
end


local function updateSlot(slotEnt, ppos)
    --[[
        TODO: In future:::
        We shouldn't set `x,y` values here;
        we should set `targetX,targetY`, and then the entity should lerp
        towards those values automatically via some other system:
        umg.group("targetX", "targetY")
    ]]
    local pos = ppos:getWorldPos()
    slotEnt.x, slotEnt.y = pos.x, pos.y

    local item = lp.posToItem(ppos)
    if item then
        updateItem(item, slotEnt)
    end
end



umg.on("@tick", function(dt)
    for _, plotEnt in ipairs(worldPlotEnts) do
        local plot = plotEnt.plot
        plot:foreachSlot(function(slotEnt, ppos)
            updateSlot(slotEnt, ppos)
        end)
    end
end)


