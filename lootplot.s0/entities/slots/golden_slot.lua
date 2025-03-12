local loc = localization.localize


local PTS_MULT = 6

return lp.defineSlot("lootplot.s0:golden_slot", {
    --[[
    This slot is (kinda) an anti-activator item.
    IE it anti-synergizes with Ruby.
    ]]
    image = "golden_slot",
    name = loc("Golden slot"),
    rarity = lp.rarities.RARE,

    description = loc("While on this slot,\nItems earn {lootplot:POINTS_MULT_COLOR}%{mult} x points{/lootplot:POINTS_MULT_COLOR}, and cost {lootplot:MONEY_COLOR}$1 extra{/lootplot:MONEY_COLOR} to activate.", {
        mult = PTS_MULT,
    }),

    slotItemProperties = {
        multipliers = {
            pointsGenerated = PTS_MULT
        },
        modifiers = {
            moneyGenerated = -1
        }
    },

    triggers = {"PULSE"},
})

