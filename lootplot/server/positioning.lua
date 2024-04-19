

--[[

Positioning code.

Automatically sets positions of entities according to their ppos.


]]


local worldPlotEnts = umg.group("plot", "x", "y")


local function updateItem(itemEnt, slotEnt)
    assert(slotEnt.x and slotEnt.y, "???")
    itemEnt.targetX = slotEnt.x
    itemEnt.targetY = slotEnt.y
end


local function updateSlot(slotEnt, ppos)
    --[[
        TODO: In future:::
        We shouldn't set `x,y` values here;
        we should set `targetX,targetY`, and then the entity should lerp
        towards those values automatically via some other system:
        umg.group("targetX", "targetY")
    ]]
    local dvec = ppos:getWorldPos()
    slotEnt.x, slotEnt.y = dvec.x, dvec.y

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







local targetEnts = umg.group("targetX", "targetY")

umg.on("@tick", function(dt)
    for _, ent in ipairs(targetEnts) do
        -- TODO: 
        -- Do lerping/spring behaviour in future.
        ent.x = ent.targetX
        ent.y = ent.targetY
    end
end)

