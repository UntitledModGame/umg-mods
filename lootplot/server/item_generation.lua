


-- Item spawner generator
umg.on("lootplot:entityActivated", function(ent)
    if lp.isSlotEntity(ent) and ent.itemSpawner then
        local ppos = lp.getPos(ent)
        if ppos then
            local entName = ent:itemSpawner() or lp.FALLBACK_NULL_ITEM
            lp.trySpawnItem(ppos, server.entities[entName], ent.lootplotTeam)
        end
    end
end)

-- Item reroller generator
umg.on("lootplot:entityActivated", function(ent)
    if lp.isSlotEntity(ent) and ent.itemReroller then
        local itemEnt = lp.slotToItem(ent)
        local ppos = lp.getPos(ent)

        if itemEnt and ppos then
            local entName = ent:itemReroller() or lp.FALLBACK_NULL_ITEM
            lp.forceSpawnItem(ppos, server.entities[entName], ent.lootplotTeam)
        end
    end
end)
