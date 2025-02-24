local loc = localization.localize


local SPECIAL_RARITIES = {
    [lp.rarities.CURSE_1] = true,
    [lp.rarities.CURSE_2] = true,
    [lp.rarities.CURSE_3] = true,

    [lp.rarities.UNIQUE] = true
}



return lp.defineSlot("lootplot.s0:dirt_slot", {
    image = "dirt_slot1",
    name = loc("Dirt slot"),
    description = loc("Cannot hold %{displayString} items.\n(Or anything higher.)", lp.rarities.RARE),
    triggers = {"PULSE"},

    rarity = lp.rarities.COMMON,

    init = function(ent)
        -- randomly flip the image to make it look cool.
        if math.random() < 0.5 then
            ent.scaleX = -1
        end
        if math.random() < 0.5 then
            ent.scaleY = -1
        end
    end,

    canAddItemToSlot = function(slotEnt, itemEnt)
        if itemEnt.rarity then
            if SPECIAL_RARITIES[itemEnt.rarity] then
                return true -- OK to hold these rarities.
            end

            local rareWeight = lp.rarities.getWeight(lp.rarities.RARE)
            local itemWeight = lp.rarities.getWeight(itemEnt.rarity)
            return itemWeight > rareWeight
        end
        return true -- no rarity.. i guess its fine? 
    end
})


