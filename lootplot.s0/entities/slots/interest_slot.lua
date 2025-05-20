
local loc = localization.localize


local function earnMoneyFancy(ent, moneyEarned)
    local ppos = assert(lp.getPos(ent))
    for _=1, moneyEarned do
        lp.wait(ppos, 0.1)
        lp.queueWithEntity(ent, function(selfEnt)
            lp.addMoney(selfEnt, 1)
        end)
        lp.wait(ppos, 0.1)
    end
end


local MAX_INTEREST = 3
local INTEREST_REQUIREMENT = 10 -- $1 per $10

return lp.defineSlot("lootplot.s0:interest_slot", {
    image = "interest_slot",
    name = loc("Interest Slot"),
    activateDescription = loc(
    "Earns {lootplot:MONEY_COLOR}$1{/lootplot:MONEY_COLOR} for every {lootplot:MONEY_COLOR}$%{requirement}{/lootplot:MONEY_COLOR} you have.\n(Max: {lootplot:MONEY_COLOR}$%{max}{/lootplot:MONEY_COLOR})", {
        max = MAX_INTEREST,
        requirement = INTEREST_REQUIREMENT
    }),

    rarity = lp.rarities.EPIC,

    canAddItemToSlot = function()
        return false -- cant hold items!!!
    end,
    baseMaxActivations = 2,

    triggers = {"PULSE"},
    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if not ppos then return end -- okay???

        local money = lp.getMoney(ent)
        local moneyEarned = math.min(5, math.floor(money / 10))
        earnMoneyFancy(ent, moneyEarned)
    end
})

