
--[[

not yet implemented!!!

]]
return lp.defineSlot("lootplot.content.s0:golden_slot", {
    image = "golden_slot",
    name = localization.localize("Golden slot"),
    description = localization.localize("Can hold %{rarity} items!", {
        rarity = lp.rarities.LEGENDARY.displayString
    }),
})

