
local loc = localization.localize


lp.defineItem("lootplot.s0.content:manure", {
    image = "manure",
    name = loc("Manure"),
    rarity = lp.rarities.UNIQUE,
    description = loc("Something has gone terribly wrong..."),
})




lp.defineItem("lootplot.s0.content:FALLBACK_NULL_SLOT", {
    image = "fallback_slot",
    name = loc("NULL SLOT"),
    rarity = lp.rarities.UNIQUE,
    description = loc("Something has gone terribly wrong..."),
})


lp.FALLBACK_NULL_SLOT = "lootplot.s0.content:FALLBACK_NULL_SLOT"

lp.FALLBACK_NULL_ITEM = "lootplot.s0.content:manure"
