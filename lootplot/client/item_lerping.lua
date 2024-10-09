

--[[

Positioning code.

Automatically sets positions of entities according to their ppos.

]]

local worldPlotEnts = umg.group("plot", "x", "y")




local function updateItem(itemEnt, ppos)
    local dvec = ppos:getWorldPos()
    local x, y = dvec.x, dvec.y
    assert(dvec, "?")
    
    -- the target position the item should lerp to.
    local targetX, targetY = umg.ask("lootplot:getItemTargetPosition", itemEnt)
    if targetX then
        itemEnt.targetX = targetX
        itemEnt.targetY = targetY
    else
        itemEnt.targetX = x
        itemEnt.targetY = y
    end

    if not (itemEnt.x and itemEnt.y) then
        itemEnt.x = x
        itemEnt.y = y
    end
end


local function updateSlot(slotEnt, ppos)
    local dvec = ppos:getWorldPos()
    slotEnt.x, slotEnt.y = dvec.x, dvec.y
end


local updateFuncs = {
    item = updateItem,
    slot = updateSlot,
}


umg.on("@tick", function(dt)
    for _, plotEnt in ipairs(worldPlotEnts) do
        local plot = plotEnt.plot
        plot:foreachLayerEntry(function(slotEnt, ppos, layer)
            local f = updateFuncs[layer]
            if f then
                f(slotEnt, ppos)
            end
        end)
    end
end)



local targetEnts = umg.group("targetX", "targetY", "x", "y")

local SPEED = 8

umg.on("@update", function(dt)
    for _, ent in ipairs(targetEnts) do
        local dx,dy = ent.targetX-ent.x, ent.targetY-ent.y
        ent.x = ent.x + dt*dx*SPEED
        ent.y = ent.y + dt*dy*SPEED
    end
end)

