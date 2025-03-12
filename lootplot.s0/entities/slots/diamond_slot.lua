local loc = localization.localize

local BONUS_MULT = 4

return lp.defineSlot("lootplot.s0:diamond_slot", {
    image = "diamond_slot",
    name = loc("Diamond slot"),

    description = loc("While on this slot,\nItems earn {lootplot:POINTS_MULT_COLOR}%{mult}x{/lootplot:POINTS_MULT_COLOR} as much {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR}", {
        mult = BONUS_MULT,
    }),

    baseMaxActivations = 100,
    triggers = {"PULSE"},

    rarity = lp.rarities.RARE,

    slotItemProperties = {
        multipliers = {
            bonusGenerated = BONUS_MULT
        }
    },
})

