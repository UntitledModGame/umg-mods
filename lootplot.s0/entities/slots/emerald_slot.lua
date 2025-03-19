
local loc = localization.localize


return lp.defineSlot("lootplot.s0:emerald_slot", {
    image = "emerald_slot",
    name = loc("Emerald Slot"),

    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}PULSE{/lootplot:TRIGGER_COLOR} and {lootplot:TRIGGER_COLOR}REROLL{/lootplot:TRIGGER_COLOR} for item!\n{lootplot:BAD_COLOR}Does not trigger items otherwise."),
    baseMaxActivations = 100,
    triggers = {"REROLL"},
    dontPropagateTriggerToItem = true,

    rarity = lp.rarities.UNCOMMON,

    onActivate = function(slotEnt)
        local item = lp.slotToItem(slotEnt)
        if item then
            lp.tryTriggerEntity("REROLL", item)
            lp.tryTriggerEntity("PULSE", item)
        end
    end
})


