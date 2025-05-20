
local loc = localization.localize


return lp.defineSlot("lootplot.s0:emerald_slot", {
    image = "emerald_slot",
    name = loc("Emerald Slot"),

    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}Pulse{/lootplot:TRIGGER_COLOR} on item"),
    baseMaxActivations = 100,
    triggers = {"REROLL"},

    rarity = lp.rarities.UNCOMMON,

    onActivate = function(slotEnt)
        local item = lp.slotToItem(slotEnt)
        if item then
            lp.tryTriggerEntity("PULSE", item)
        end
    end
})


