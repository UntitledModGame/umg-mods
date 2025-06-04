
local loc = localization.localize


lp.defineItem("lootplot.s0:FALLBACK_ITEM", {
    image = "fallback_item",
    name = loc("FALLBACK ITEM"),
    rarity = lp.rarities.UNIQUE,
    triggers = {"PULSE"},
    basePointsGenerated = -1,
    description = loc("Something has gone wrong..."),
})





lp.defineSlot("lootplot.s0:FALLBACK_SLOT", {
    image = "fallback_slot",
    name = loc("FALLBACK SLOT"),
    rarity = lp.rarities.UNIQUE,
    description = loc("Something has gone wrong..."),
    triggers = {},
})


lp.FALLBACK_NULL_SLOT = "lootplot.s0:FALLBACK_SLOT"

lp.FALLBACK_NULL_ITEM = "lootplot.s0:FALLBACK_ITEM"


---------------------------------------------------------------------


