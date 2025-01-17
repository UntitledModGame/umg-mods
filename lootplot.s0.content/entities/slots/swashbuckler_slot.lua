

local loc = localization.localize

lp.defineSlot("lootplot.s0.content:swashbuckler_slot", {
    image = "swashbuckler_slot",
    name = loc("Swashbuckler Slot"),

    triggers = {"PULSE"},
    activateDescription = loc("Items placed on this slot don't cost any money to activate.\n(And cannot earn money!)"),

    slotItemProperties = {
        multipliers = {
            moneyGenerated = 0
        }
    },
})


