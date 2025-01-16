


--[[
The reason we spawn the item before, 
is so onActivate can alter the item that was spawned.

eg: shop slots- 
- Give all spawned items STICKY
- Make all spawned items cost $4 more
- Have a 10% chance for the spawned item to cost mana
]]
local BEFORE_ORDER = -10


-- Item spawner generator
umg.on("lootplot:entityActivated", BEFORE_ORDER, function(ent)
    if ent.itemSpawner and lp.isSlotEntity(ent) then
        local ppos = lp.getPos(ent)
        if ppos then
            local entName = ent:itemSpawner() or lp.FALLBACK_NULL_ITEM
            lp.trySpawnItem(ppos, server.entities[entName], ent.lootplotTeam)
        end
    end
end)

-- Item reroller generator
umg.on("lootplot:entityActivated", BEFORE_ORDER, function(ent)
    if ent.itemReroller and lp.isSlotEntity(ent) then
        local itemEnt = lp.slotToItem(ent)
        local ppos = lp.getPos(ent)

        if itemEnt and ppos then
            local entName = ent:itemReroller() or lp.FALLBACK_NULL_ITEM
            lp.forceSpawnItem(ppos, server.entities[entName], ent.lootplotTeam)
        end
    end
end)
