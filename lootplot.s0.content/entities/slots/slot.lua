local loc = localization.localize

return lp.defineSlot("lootplot.s0.content:slot", {
    image = "slot",
    name = loc("Basic Slot"),
    stickySlot = true,
    triggers = {"PULSE"},
})

