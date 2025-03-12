local loc = localization.localize


return lp.defineSlot("lootplot.s0:golden_slot", {
    image = "golden_slot",
    name = loc("Golden slot"),
    rarity = lp.rarities.RARE,
    baseMoneyGenerated = 1,
    triggers = {"PULSE"},
})

