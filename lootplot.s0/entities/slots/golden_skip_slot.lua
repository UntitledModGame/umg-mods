

local loc = localization.localize


return lp.defineSlot("lootplot.s0:golden_skip_slot", {
    image = "golden_skip_slot",
    name = loc("Golden Skip Slot"),

    triggers = {"LEVEL_UP"},

    rarity = lp.rarities.EPIC,

    canAddItemToSlot = function()
        return false -- cant hold items!!!
    end,

    baseMaxActivations = 2,
    baseMoneyGenerated = 10
})


