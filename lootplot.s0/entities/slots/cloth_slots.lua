

local loc = localization.localize


lp.defineSlot("lootplot.s0:key_cloth_slot", {
    name = loc("Key Cloth Slot"),
    image = "key_cloth_slot",

    triggers = {"PULSE"},
    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}Unlock{/lootplot:TRIGGER_COLOR} on item"),

    baseMaxActivations = 3,

    unlockAfterWins = 3,

    onActivate = function(ent)
        local itemEnt = lp.slotToItem(ent)
        if itemEnt then
            lp.tryTriggerEntity("UNLOCK", itemEnt)
        end
    end,

    rarity = lp.rarities.EPIC
})



lp.defineSlot("lootplot.s0:level_cloth_slot", {
    name = loc("Level Cloth Slot"),
    image = "level_cloth_slot",

    triggers = {"PULSE"},
    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}Level-Up{/lootplot:TRIGGER_COLOR} on item"),

    baseMaxActivations = 3,

    unlockAfterWins = 3,

    onActivate = function(ent)
        local itemEnt = lp.slotToItem(ent)
        if itemEnt then
            lp.tryTriggerEntity("LEVEL_UP", itemEnt)
        end
    end,

    rarity = lp.rarities.RARE
})


