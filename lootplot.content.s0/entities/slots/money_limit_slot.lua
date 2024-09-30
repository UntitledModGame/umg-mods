

local loc = localization.localize

-- Adjust this when balancing. Maybe 100 is better?
local MONEY_LIMIT = 50

return lp.defineSlot("lootplot.content.s0:money_limit_slot", {
    image = "money_limit_slot",
    name = loc("Money-limit slot"),
    description = loc("Limits money to %{limit}", {limit = MONEY_LIMIT}),

    baseCanSlotPropagate = false,
    canAddItemToSlot = function()
        return false -- cant hold items!!!
    end,

    triggers = {"PULSE"},
    onActivate = function(ent)
        local money = lp.getMoney(ent)
        if money > MONEY_LIMIT then
            lp.setMoney(ent, MONEY_LIMIT)
        end
    end
})
