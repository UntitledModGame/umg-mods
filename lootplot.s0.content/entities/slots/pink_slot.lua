local loc = localization.localize

return lp.defineSlot("lootplot.s0:pink_slot", {
    image = "pink_slot",
    name = loc("Pink Slot"),
    activateDescription = loc("Gives an extra life to item."),
    triggers = {"PULSE"},

    onActivate = function(slotEnt)
        local itemEnt = lp.slotToItem(slotEnt)
        if itemEnt then
            itemEnt.lives = (itemEnt.lives or 0) + 1
        end
    end
})

