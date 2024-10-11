


local function definePerk(id, etype)
    etype.image = etype.image or id
    etype.canItemFloat = true -- perk always float

    lp.worldgen.STARTING_ITEMS:add(etype, 1)
    lp.defineItem("lootplot.s0.starting_items:" .. id, etype)
end



definePerk("one_ball", {
    onActivateOnce = function(ent)
        -- generate world!
        local ppos = assert(lp.getPos(ent))
        local team = assert(ent.lootplotTeam, "?")

        local wg = lp.worldgen
        wg.spawnSlots(assert(ppos:move(-4,1)), server.entities.shop_slot, 3,2, team)
        wg.spawnSlots(ppos, server.entities.slot, 3,3, team)
        wg.spawnSlots(assert(ppos:move(0, 3)), server.entities.sell_slot, 3,1, team)
        wg.spawnSlots(assert(ppos:move(-4, -2)), server.entities.reroll_button_slot, 1,1, team)
    end
})

