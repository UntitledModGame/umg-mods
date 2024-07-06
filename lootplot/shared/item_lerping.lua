

--[[

Positioning code.

Automatically sets positions of entities according to their ppos.


================================
================================
TODO::
We need to someone make this code less assumption-ful,
to allow future mods to override lerping behaviour!
====
================================


]]


if server then

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

end



sync.autoSyncComponent("targetX", {type="number", lerp=false})
sync.autoSyncComponent("targetY", {type="number", lerp=false})



if client then

local targetEnts = umg.group("targetX", "targetY")

local SPEED = 8

umg.on("@update", function(dt)
    for _, ent in ipairs(targetEnts) do
        ent.x = ent.x or 0
        ent.y = ent.y or 0

        local dx,dy = ent.targetX-ent.x, ent.targetY-ent.y
        ent.x = ent.x + dt*dx*SPEED
        ent.y = ent.y + dt*dy*SPEED
    end
end)

end
