if client then
    umg.on("lootplot:populateDescription", function(ent, dest)
        if ent.description then
            dest:add(ent.description)
        end
    end)
end

umg.answer("lootplot:hasPlayerAccess", function(ent)
    local ppos = lp.getPos(ent)
    if ppos then
        return not ppos:getPlot():isPipelineRunning()
    end
    return true
end)

umg.answer("lootplot:hasPlayerAccess", function(ent, clientId)
    return ent.ownerPlayer == clientId
end)

umg.answer("lootplot:hasPlayerAccess", function(ent)
    local slotEnt = lp.isItemEntity(ent) and lp.itemToSlot(ent)

    if slotEnt then
        return not slotEnt.shopLock
    end

    return true
end)

umg.answer("lootplot:isItemAdditionBlocked", function(slotEnt)
    -- shop slots cant hold items!
    return not not slotEnt:hasComponent("shopLock")
end)

umg.answer("lootplot:isItemAdditionBlocked", function(slotEnt)
    -- button slots cant hold items!
    return not not slotEnt:hasComponent("buttonSlot")
end)


