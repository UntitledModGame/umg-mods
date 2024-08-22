
return lp.defineSlot("lootplot.content.s0:reroll_slot", {
    image = "reroll_slot",
    name = localization.localize("Reroll slot"),
    triggers = {"REROLL", "PULSE"},
    itemReroller = {},
    baseCanSlotPropagate = false,
    baseMaxActivations = 500,
})

