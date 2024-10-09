local loc = localization.localize

return lp.defineSlot("lootplot.s0.content:null_slot", {
    image = "null_slot",
    name = loc("Null slot"),
    description = loc("Doesn't activate items!"),
    baseCanSlotPropagate = false,
})
