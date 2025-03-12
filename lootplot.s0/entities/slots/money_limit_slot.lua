

local loc = localization.localize

local MONEY_LIMIT_TEXT = localization.newInterpolator("Limits money to {lootplot:MONEY_COLOR}$%{limit}{/lootplot:MONEY_COLOR}")

-- Adjust this when balancing. Maybe 100 is better?
local MONEY_LIMIT = 100

return lp.defineSlot("lootplot.s0:money_limit_slot", {
    image = "money_limit_slot",
    name = loc("Money-limit slot"),
    activateDescription = MONEY_LIMIT_TEXT({limit = MONEY_LIMIT}),

    canAddItemToSlot = function()
        return false -- cant hold items!!!
    end,
    rarity = lp.rarities.UNIQUE,

    triggers = {"PULSE", "REROLL"},
    onActivate = function(ent)
        local money = lp.getMoney(ent)
        if money > MONEY_LIMIT then
            lp.setMoney(ent, MONEY_LIMIT)
        end
    end
})
