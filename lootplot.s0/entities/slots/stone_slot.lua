
local loc = localization.localize



lp.defineSlot("lootplot.s0:stone_slot", {
    --[[
    The idea is that systems/mods can give attributes to these slots,
    and players will attempt to destroy them.

    EG:
    Stone-slot:
    Generates +4 mult
    (3 lives)

    ]]
    name = loc("Stone slot"),
    image = "stone_slot",

    triggers = {"DESTROY"},

    canAddItemToSlot = function()
        return false -- cant hold items!!!
    end,
    baseMaxActivations = 6,

    rarity = lp.rarities.EPIC,
})


