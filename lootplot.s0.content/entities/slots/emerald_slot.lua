
local loc = localization.localize


return lp.defineSlot("lootplot.s0.content:emerald_slot", {
    image = "emerald_slot",
    name = loc("Emerald Slot"),

    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}PULSE{/lootplot:TRIGGER_COLOR} and {lootplot:TRIGGER_COLOR}REROLL{/lootplot:TRIGGER_COLOR} for item!\n{lootplot:BAD_COLOR}Does not trigger items otherwise."),
    baseMaxActivations = 100,
    triggers = {"REROLL"},
    baseCanSlotPropagate = false,

    onActivate = function(slotEnt)
        local item = lp.slotToItem(slotEnt)
        if item then
            lp.tryActivateEntity(item)
        end
    end
})


