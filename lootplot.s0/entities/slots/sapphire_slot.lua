

local loc = localization.localize

local WEAK_MULT = 2
local STRONG_MULT = 5

return lp.defineSlot("lootplot.s0:sapphire_slot", {
    image = "sapphire_slot",
    name = loc("Sapphire slot"),

    rarity = lp.rarities.RARE,

    description = loc("While on this slot,\nItems earn {lootplot:POINTS_MULT_COLOR}%{weakMult} x points{/lootplot:POINTS_MULT_COLOR}.\n(If {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} is negative, becomes {lootplot:POINTS_MULT_COLOR}%{strongMult} x{/lootplot:POINTS_MULT_COLOR})", {
        weakMult = WEAK_MULT,
        strongMult = STRONG_MULT,
    }),

    triggers = {"PULSE"},
    baseMaxActivations = 100,
    slotItemProperties = {
        multipliers = {
            pointsGenerated = function(ent)
                local isBonusNegative = (lp.getPointsBonus(ent) or 0) < 0
                if isBonusNegative then
                    return STRONG_MULT
                else
                    return WEAK_MULT
                end
            end
        }
    },
})


