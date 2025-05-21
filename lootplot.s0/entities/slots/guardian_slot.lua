
local loc = localization.localize


local MIN = 1

return lp.defineSlot("lootplot.s0:guardian_slot", {
    image = "guardian_slot",
    name = loc("Guardian slot"),

    description = loc("While on this slot, item's points, bonus, and multiplier properties cannot be less than %{MIN}.", {
        MIN = 1
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

