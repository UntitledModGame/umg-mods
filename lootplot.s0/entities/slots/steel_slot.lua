
local loc = localization.localize

return lp.defineSlot("lootplot.s0:steel_slot", {
    image = "steel_slot",
    name = loc("Steel slot"),

    rarity = lp.rarities.UNCOMMON,

    description = loc("Item gets a {lootplot:POINTS_MULT_COLOR}2 x POINTS-MULTIPLIER{/lootplot:POINTS_MULT_COLOR}."),
    triggers = {"PULSE"},
    baseMaxActivations = 100,
    slotItemProperties = {
        multipliers = {
            pointsGenerated = 2
        }
    },
})


