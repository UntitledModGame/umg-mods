local loc = localization.localize

lp.defineSlot("lootplot.s0.content:slot", {
    image = "slot",
    name = loc("Basic Slot"),
    triggers = {"PULSE"},
})


return lp.defineSlot("lootplot.s0.content:sticky_slot", {
    image = "slot",
    name = loc("Sticky Slot"),
    stickySlot = true,
    triggers = {"PULSE"},
})

