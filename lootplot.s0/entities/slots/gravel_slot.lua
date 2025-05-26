
local helper = require("shared.helper")


local loc = localization.localize


local SPECIAL_RARITIES = {
    [lp.rarities.UNIQUE] = true
}



return lp.defineSlot("lootplot.s0:gravel_slot", {
    image = "gravel_slot1",
    name = loc("Gravel slot"),
    description = loc("Cannot hold %{displayString} items.\n(Or anything higher.)", lp.rarities.EPIC),

    triggers = {"PULSE"},

    unlockAfterWins = 2,

    rarity = lp.rarities.UNCOMMON,

    init = function(ent)
        -- randomly flip the image to make it look cool.
        local r = math.random()
        if r < 0.5 then
            ent.image = "gravel_slot1"
        else
            ent.image = "gravel_slot2"
        end
    end,

    canAddItemToSlot = function(slotEnt, itemEnt)
        if lp.canItemFloat(itemEnt) then
            return true -- its OK to add.
        end
        if itemEnt.rarity then
            if SPECIAL_RARITIES[itemEnt.rarity] then
                return true -- OK to hold these rarities.
            end

            local epicWeight = lp.rarities.getWeight(lp.rarities.EPIC)
            local itemWeight = lp.rarities.getWeight(itemEnt.rarity)
            return itemWeight > epicWeight
        end
        return true -- no rarity.. i guess its fine? 
    end
})



