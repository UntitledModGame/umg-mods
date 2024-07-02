-- Item spawner generator
umg.on("lootplot:entityActivated", function(ent)
    if lp.isSlotEntity(ent) and ent.itemSpawner then
        local ppos = lp.getPos(ent)
        if ppos then
            local itemSpawner = ent.itemSpawner ---@type generation.Query
            local entName = itemSpawner()
            lp.trySpawnItem(ppos, server.entities[entName])
        end
    end
end)

-- Item reroller generator
umg.on("lootplot:entityActivated", function(ent)
    if lp.isSlotEntity(ent) and ent.itemReroller then
        local itemEnt = lp.slotToItem(ent)
        local ppos = lp.getPos(ent)

        if itemEnt and ppos then
            local itemReroller = ent.itemReroller ---@type generation.Query
            local entName = itemReroller()
            lp.forceSpawnItem(ppos, server.entities[entName])
        end
    end
end)
