

local loc = localization.localize

local MONEY_LIMIT_TEXT = localization.newInterpolator("Limits money to %{limit}")

-- Adjust this when balancing. Maybe 100 is better?
local MONEY_LIMIT = 100

return lp.defineSlot("lootplot.s0.content:money_limit_slot", {
    image = "money_limit_slot",
    name = loc("Money-limit slot"),
    description = MONEY_LIMIT_TEXT({limit = MONEY_LIMIT}),

    baseCanSlotPropagate = false,
    canAddItemToSlot = function()
        return false -- cant hold items!!!
    end,

    triggers = {"PULSE", "RESET"},
    onActivate = function(ent)
        local money = lp.getMoney(ent)
        if money > MONEY_LIMIT then
            lp.setMoney(ent, MONEY_LIMIT)
        end
    end
})
