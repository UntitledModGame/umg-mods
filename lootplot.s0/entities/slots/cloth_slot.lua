

local loc = localization.localize


lp.defineSlot("lootplot.s0:cloth_slot", {
    name = loc("Cloth Slot"),
    image = "level_cloth_slot",

    triggers = {"PULSE"},
    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}Level-Up{/lootplot:TRIGGER_COLOR} on item"),

    unlockAfterWins = 3,

    onActivate = function(ent)
        local itemEnt = lp.slotToItem(ent)
        if itemEnt then
            lp.tryTriggerEntity("LEVEL_UP", itemEnt)
        end
    end,

    rarity = lp.rarities.RARE
})


