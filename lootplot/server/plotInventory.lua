





local function tryGetSlot(invEnt, slot)
    if invEnt.plot then
        local slotEnt = invEnt.plot:getSlot(slot)
        return slotEnt
    end
end


umg.answer("items:isItemRemovalBlocked", function(invEnt, itemEnt, slot)
    local slotEnt = tryGetSlot(slot)
    --[[
        TODO:
        emit a question here, or somehting.

        (Buyable slots should tag onto this)
    ]]
end)

umg.answer("items:isItemAdditionBlocked", function(invEnt, itemEnt, slot)
    local slotEnt = tryGetSlot(slot)
    if not slotEnt then
        return true -- block; because there's no slot to put item in.
    end
end)


umg.on("items:itemAdded", function(invEnt, itemEnt, slot)
    local slotEnt = tryGetSlot(slot)
    if slotEnt then
        attachItem(itemEnt, slotEnt)
    end
end)

umg.on("items:itemRemoved", function(invEnt, itemEnt, slot)
    local slotEnt = tryGetSlot(slot)
    if slotEnt then
    detachItem(itemEnt)
    end
end)










local function forceUpdateInventory(ent)
    -- If plot is different than inventory; update the plot.
    -- (Plot takes precedence over inventory)
    local inventory = ent.inventory
    local plot = ent.plot
    plot:foreach(function(ppos)
        local i = ppos.slot
        local slotEnt = plot:getSlot(i)
        if slotEnt ~= inventory:get(i) then
            inventory:rawset(i, slotEnt)
        end
    end)
end


local plotInventoryGroup = umg.group("inventory", "plot")

umg.on("@tick", function()
    for _, ent in ipairs(plotInventoryGroup) do
        forceUpdateInventory(ent)
    end
end)



