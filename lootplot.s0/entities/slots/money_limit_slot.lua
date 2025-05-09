

local loc = localization.localize

local MONEY_LIMIT_TEXT = localization.newInterpolator("Limits money when activated!")


local MONEY_LIMIT = 100


return lp.defineSlot("lootplot.s0:money_limit_slot", {
    image = "money_limit_slot",
    name = loc("Money-limit slot"),
    activateDescription = MONEY_LIMIT_TEXT({limit = MONEY_LIMIT}),

    canAddItemToSlot = function()
        return false -- cant hold items!!!
    end,
    rarity = lp.rarities.UNIQUE,

    -- feel free to override this!
    grubMoneyCap = 100,

    triggers = {"PULSE", "REROLL"},
})

