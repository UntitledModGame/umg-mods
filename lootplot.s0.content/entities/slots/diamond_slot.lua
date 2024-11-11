local loc = localization.localize

return lp.defineSlot("lootplot.s0.content:diamond_slot", {
    image = "diamond_slot",
    name = loc("Diamond slot"),
    description = loc("Gives a 5x points-multiplier to item"),
    baseMaxActivations = 3,
    slotItemProperties = {
        multipliers = {
            pointsGenerated = 5
        }
    },
})

