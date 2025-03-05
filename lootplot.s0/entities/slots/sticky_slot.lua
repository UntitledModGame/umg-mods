
local loc = localization.localize

lp.defineSlot("lootplot.s0:sticky_slot", {
    image = "slot",
    name = loc("Sticky Slot"),
    rarity = lp.rarities.UNIQUE,
    stickySlot = true,
    triggers = {"PULSE"},
})

