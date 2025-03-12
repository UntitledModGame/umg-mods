

local loc = localization.localize

local MULT = 6

return lp.defineSlot("lootplot.s0:sapphire_slot", {
    image = "sapphire_slot",
    name = loc("Sapphire slot"),

    rarity = lp.rarities.RARE,

    description = loc("While on this slot,\nItems earn {lootplot:POINTS_MULT_COLOR}%{mult} x points{/lootplot:POINTS_MULT_COLOR}.\n(Only works when {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} is negative!)", {
        mult = MULT,
    }),

    triggers = {"PULSE"},
    baseMaxActivations = 100,
    slotItemProperties = {
        multipliers = {
            pointsGenerated = function(ent)
                local isBonusNegative = (lp.getPointsBonus(ent) or 0) < 0
                if isBonusNegative then
                    return MULT
                else
                    return 1
                end
            end
        }
    },
})


