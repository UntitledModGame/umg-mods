
local loc = localization.localize



return lp.defineSlot("lootplot.s0.content:interest_slot", {
    image = "interest_slot",
    name = loc("Interest Slot"),
    activateDescription = loc(
        "Earns {lootplot:MONEY_COLOR}$1{/lootplot:MONEY_COLOR} for every {lootplot:MONEY_COLOR}$10{/lootplot:MONEY_COLOR} you have.\n(Max: {lootplot:MONEY_COLOR}$5{/lootplot:MONEY_COLOR})"
    ),

    baseCanSlotPropagate = false,
    canAddItemToSlot = function()
        return false -- cant hold items!!!
    end,
    baseMaxActivations = 2,

    triggers = {"PULSE"},
    onActivate = function(ent)
        local money = lp.getMoney(ent)
        local interest = math.min(5, math.floor(money / 10))
        lp.addMoney(ent, interest)
    end
})

