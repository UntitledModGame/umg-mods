
return lp.defineSlot("lootplot.content.s0:reroll_slot", {
    image = "reroll_slot",
    name = localization.localize("Reroll slot"),
    triggers = {"REROLL", "PULSE"},
    itemReroller = lp.ITEM_GENERATOR:createQuery():addAllEntries(),
    baseCanSlotPropagate = false,
    baseMaxActivations = 500,
})

