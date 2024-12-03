
local loc = localization.localize

return lp.defineSlot("lootplot.s0.content:rotate_slot", {
    image = "rotate_slot",
    name = loc("Rotate Slot"),

    baseCanSlotPropagate = false,

    triggers = {"PULSE"},

    activateDescription = loc("Rotates item\n(Without activating it!)"),

    onActivate = function(slotEnt)
        local itemEnt = lp.slotToItem(slotEnt)
        if itemEnt then
            lp.rotateItem(itemEnt, 1)
        end
    end
})

