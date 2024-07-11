umg.answer("lootplot:hasPlayerAccess", function(ent)
    local ppos = lp.getPos(ent)
    if ppos then
        return not ppos.plot:isPipelineRunning()
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
    return not not slotEnt:hasComponent("shopLock")
end)
