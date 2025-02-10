local loc = localization.localize

return lp.defineSlot("lootplot.s0:null_slot", {
    triggers = {},
    image = "null_slot",
    name = loc("Null slot"),
    rarity = lp.rarities.COMMON,
    description = loc("Doesn't activate items!"),
    baseCanSlotPropagate = false,
})
