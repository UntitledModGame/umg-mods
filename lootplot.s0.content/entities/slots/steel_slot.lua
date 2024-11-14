
local loc = localization.localize

return lp.defineSlot("lootplot.s0.content:steel_slot", {
    image = "steel_slot",
    name = loc("Steel slot"),
    description = loc("Item gets a {lootplot:POINTS_MULT_COLOR}2 x POINTS-MULTIPLIER{/lootplot:POINTS_MULT_COLOR}."),
    baseMaxActivations = 100,
    slotItemProperties = {
        multipliers = {
            pointsGenerated = 2
        }
    },
})


