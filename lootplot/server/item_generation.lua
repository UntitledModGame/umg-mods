-- Item spawner generator
umg.on("lootplot:entityActivated", function(ent)
    if lp.isSlotEntity(ent) and ent.itemSpawner then
        local ppos = lp.getPos(ent)
        if ppos then
            local itemSpawner = lp.getItemGenerator()
            local entName = itemSpawner:query(function (entityType)
                return lp.getDynamicSpawnChance(entityType, ent)
            end)
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
            local itemReroller = lp.getItemGenerator()
            local entName = itemReroller:query(function (entityType)
                return lp.getDynamicSpawnChance(entityType, ent)
            end)
            lp.forceSpawnItem(ppos, server.entities[entName], ent.lootplotTeam)
        end
    end
end)
