
local loc = localization.localize


local MIN = 1

return lp.defineSlot("lootplot.s0:guardian_slot", {
    image = "guardian_slot",
    name = loc("Guardian slot"),

    description = loc("While on this slot, item's {lootplot:POINTS_COLOR}points{/lootplot:POINTS_COLOR}, {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR}, and {lootplot:POINTS_MULT_COLOR}multiplier{/lootplot:POINTS_MULT_COLOR} cannot be less than %{MIN}.", {
        MIN = MIN
    }),

    baseMaxActivations = 1,
    triggers = {"PULSE"},

    rarity = lp.rarities.EPIC,

    slotItemProperties = {
        minimums = {
            pointsGenerated = MIN,
            bonusGenerated = MIN,
            multGenerated = MIN,
        }
    },
})

