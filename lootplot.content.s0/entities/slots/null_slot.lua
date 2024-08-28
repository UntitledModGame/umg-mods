local loc = localization.newLocalizer()

return lp.defineSlot("lootplot.content.s0:null_slot", {
    image = "null_slot",
    name = loc("Null slot"),
    description = loc("Doesn't activate items!"),
    baseCanSlotPropagate = false,
})
