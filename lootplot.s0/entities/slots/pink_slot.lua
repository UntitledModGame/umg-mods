local loc = localization.localize

lp.defineSlot("lootplot.s0:pink_slot", {
    image = "pink_slot",
    name = loc("Pink Slot"),
    activateDescription = loc("Gives an extra {lootplot:LIFE_COLOR}life{/lootplot:LIFE_COLOR} to item.\n(Doesn't work on food-items!)"),
    triggers = {"PULSE"},
    rarity = lp.rarities.EPIC,

    onActivate = function(slotEnt)
        local itemEnt = lp.slotToItem(slotEnt)
        if itemEnt and (not itemEnt.foodItem) then
            itemEnt.lives = (itemEnt.lives or 0) + 1
        end
    end
})


lp.defineSlot("lootplot.s0:purple_slot", {
    image = "purple_slot",
    name = loc("Purple Slot"),
    activateDescription = loc("{lootplot:DOOMED_COLOR}DOOMED{/lootplot:DOOMED_COLOR} items are invincible on this slot!\n(But activations are capped at 1)"),

    unlockAfterWins = 3,

    triggers = {"PULSE"},
    rarity = lp.rarities.RARE,

    slotItemProperties = {
        maximums = {
            maxActivations = 2
        }
    },

    isItemInvincible = function(ent, itemEnt)
        return (not itemEnt.activateInstantly) and (itemEnt.doomCount)
    end
})



lp.defineSlot("lootplot.s0:invincibility_slot", {
    image = "invincibility_slot",
    name = loc("Invincibility Slot"),
    activateDescription = loc("items are invincible whilst on this slot!"),

    unlockAfterWins = 3,

    triggers = {"PULSE"},
    rarity = lp.rarities.LEGENDARY,

    isItemInvincible = function(ent, itemEnt)
        return (not itemEnt.activateInstantly)
    end,
})


