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
        local r = math.random()
        if r < 0.25 then
            ent.image = "dirt_slot1"
        elseif r < 0.5 then
            ent.image = "dirt_slot2"
        elseif r < 0.75 then
            ent.image = "dirt_slot3"
        else
            ent.image = "dirt_slot4"
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


