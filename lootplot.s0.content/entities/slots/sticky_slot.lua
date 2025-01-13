
local loc = localization.localize

lp.defineSlot("lootplot.s0.content:sticky_slot", {
    image = "slot",
    name = loc("Sticky Slot"),
    stickySlot = true,
    triggers = {"PULSE"},
})

