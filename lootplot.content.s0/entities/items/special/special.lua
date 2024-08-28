
local loc = localization.newLocalizer()


lp.defineItem("lootplot.content.s0:manure", {
    image = "manure",
    name = loc("Manure"),
    rarity = lp.rarities.UNIQUE,
    description = loc("Something has gone terribly wrong..."),
})




lp.defineItem("lootplot.content.s0:FALLBACK_NULL_SLOT", {
    image = "fallback_slot",
    name = loc("NULL SLOT"),
    rarity = lp.rarities.UNIQUE,
    description = loc("Something has gone terribly wrong..."),
})


lp.FALLBACK_NULL_SLOT = "lootplot.content.s0:FALLBACK_NULL_SLOT"

lp.FALLBACK_NULL_ITEM = "lootplot.content.s0:manure"
