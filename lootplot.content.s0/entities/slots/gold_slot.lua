local loc = localization.newLocalizer()

--[[

not yet implemented!!!

]]
return lp.defineSlot("lootplot.content.s0:golden_slot", {
    image = "golden_slot",
    name = loc("Golden slot"),
    description = loc("Can hold %{rarity} items!", {
        rarity = lp.rarities.LEGENDARY.displayString
    }),
})

