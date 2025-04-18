
local loc = localization.localize

local PTS_MULT = 3
local ACTIVATIONS_CAP = 2


return lp.defineSlot("lootplot.s0:steel_slot", {
    image = "steel_slot",
    name = loc("Steel slot"),

    rarity = lp.rarities.UNCOMMON,

    description = loc("While on this slot,\nItems earn {lootplot:POINTS_MULT_COLOR}%{mult} x points{/lootplot:POINTS_MULT_COLOR}, and activations are limited to %{activations}.", {
        mult = PTS_MULT,
        activations = ACTIVATIONS_CAP
    }),
    triggers = {"PULSE"},
    baseMaxActivations = 100,
    slotItemProperties = {
        multipliers = {
            pointsGenerated = PTS_MULT
        },
        maximums = {
            maxActivations = ACTIVATIONS_CAP
        }
    },
})


