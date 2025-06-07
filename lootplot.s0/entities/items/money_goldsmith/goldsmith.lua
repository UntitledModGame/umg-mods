
local loc = localization.localize
local interp = localization.newInterpolator

local consts = require("shared.constants")
local helper = require("shared.helper")

local MONEY_REQUIREMENT = assert(consts.GOLDSMITH_MONEY_REQUIREMENT)


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    return lp.defineItem("lootplot.s0:"..id, etype)
end




local function percentageOfBalanceGetter(percentage)
    return function(ent)
        local money = lp.getMoney(ent)
        if money then
            return money * percentage
        end
        return 0
    end
end



local MULT_RING_DESC = interp("Adds {lootplot:POINTS_MULT_COLOR}mult{/lootplot:POINTS_MULT_COLOR} equal to 4% of the balance {lootplot:MONEY_COLOR}($%{balance})")

local function defMultRing(id,name, triggers, extraComps)
    extraComps = extraComps or {}
    local etype = {
        triggers=assert(triggers),

        description = function(ent)
            return MULT_RING_DESC({
                balance = math.floor(lp.getMoney(ent) or 0)
            })
        end,

        basePrice = 12,
        baseMultGenerated = 0,
        baseMaxActivations = 6,

        lootplotProperties = {
            modifiers = {
                multGenerated = function(ent)
                    local money = lp.getMoney(ent) or 0
                    local interest = money * (4/100)
                    return interest
                end
            }
        },

        rarity = lp.rarities.RARE,
    }
    for k,v in pairs(extraComps) do
        etype[k] = v
    end
    defItem(id, name, etype)
end


defMultRing("red_multiplier_ring", "Red Multiplier Ring", {"PULSE"})
defMultRing("green_multiplier_ring", "Green Multiplier Ring", {"REROLL"})
defMultRing("orange_multiplier_ring", "Orange Multiplier Ring", {"ROTATE", "LEVEL_UP"}, {
    unlockAfterWins = consts.UNLOCK_AFTER_WINS.ROTATEY,
    baseMoneyGenerated = 2
})




local SILV_RING_DESC = interp("Earns points equal to the current balance {lootplot:MONEY_COLOR}($%{balance})")

local function defSilvRing(id,name,trigger)
    defItem(id, name, {
        triggers={trigger},

        description = function(ent)
            return SILV_RING_DESC({
                balance = math.floor(lp.getMoney(ent) or 0)
            })
        end,

        basePrice = 6,
        basePointsGenerated = 0,
        baseMaxActivations = 6,

        lootplotProperties = {
            modifiers = {
                pointsGenerated = percentageOfBalanceGetter(1)
            }
        },

        rarity = lp.rarities.RARE,
    })
end


defSilvRing("silver_pulse_ring", "Silver Pulse Ring", "PULSE")
defSilvRing("silver_reroll_ring", "Silver Reroll Ring", "REROLL")




local GOLD_RING_DESC = loc("Earn {lootplot:MONEY_COLOR}$1{/lootplot:MONEY_COLOR} of interest for every {lootplot:MONEY_COLOR}$20{/lootplot:MONEY_COLOR} you have. (Max of {lootplot:MONEY_COLOR}$4{/lootplot:MONEY_COLOR})")

local function defGoldenRing(id, name, trigger)
    defItem(id, name, {
        triggers = {trigger},

        description = GOLD_RING_DESC,

        basePrice = 8,
        baseMoneyGenerated = 0,
        baseMaxActivations = 2,

        sticky = true,

        lootplotProperties = {
            maximums = {
                moneyGenerated = 4
            },
            modifiers = {
                moneyGenerated = function(ent)
                    local money = lp.getMoney(ent) or 0
                    local interest = math.floor(money / 20)
                    return interest
                end
            }
        },

        rarity = lp.rarities.EPIC,
    })
end

defGoldenRing("golden_pulse_ring", "Golden Pulse Ring", "PULSE")
defGoldenRing("golden_reroll_ring", "Golden Reroll Ring", "REROLL")



--[[

===========
items that only work when money > REQUIREMENT
===========
]]

local DEFAULT_ACTIVATE_DESC = loc("(Only works if {lootplot:MONEY_COLOR}money{/lootplot:MONEY_COLOR} exceeds {lootplot:MONEY_COLOR}$%{amount}{/lootplot:MONEY_COLOR})", {
    amount = MONEY_REQUIREMENT
})

local DEFAULT_CAN_ACTIVATE = function(ent)
    return (lp.getMoney(ent) or 0) > MONEY_REQUIREMENT
end


do
local BUFF = 3
local DESC = interp("If {lootplot:MONEY_COLOR}money more than $%{moneyReq}{/lootplot:MONEY_COLOR}, permanently gain %{pointBuff} points.\n"){
    pointBuff = BUFF,
    moneyReq = MONEY_REQUIREMENT
}

defItem("iron_ornament", "Iron Ornament", {
    activateDescription = DESC,

    basePointsGenerated = 10,
    baseMaxActivations = 4,

    onActivate = function(ent)
        if (lp.getMoney(ent) or 0) > MONEY_REQUIREMENT then
            lp.modifierBuff(ent, "pointsGenerated", BUFF, ent)
        end
    end,

    rarity = lp.rarities.UNCOMMON,
    triggers = {"PULSE"},
})
end



do
local BUFF = 0.1
local DESC = interp("If {lootplot:MONEY_COLOR}money more than $%{moneyReq}{/lootplot:MONEY_COLOR}, permanently gain {lootplot:POINTS_MULT_COLOR}+%{buff} multiplier."){
    buff = BUFF,
    moneyReq = MONEY_REQUIREMENT
}

defItem("ruby_ornament", "Ruby Ornament", {
    activateDescription = DESC,

    baseMultGenerated = -0.5,
    baseMaxActivations = 4,

    onActivate = function(ent)
        if (lp.getMoney(ent) or 0) > MONEY_REQUIREMENT then
            lp.modifierBuff(ent, "multGenerated", BUFF, ent)
        end
    end,

    rarity = lp.rarities.UNCOMMON,
    triggers = {"PULSE"},
})
end



defItem("golden_ornament", "Golden Ornament", {
    --[[
    Used as a way to "pivot into" goldsmith builds
    ]]
    triggers = {"PULSE"},

    activateDescription = DEFAULT_ACTIVATE_DESC,
    canActivate = DEFAULT_CAN_ACTIVATE,

    basePrice = 8,
    baseMaxActivations = 1,
    baseMoneyGenerated = 1,
    baseBonusGenerated = 4,

    rarity = lp.rarities.RARE,
})





do
local ROBBER_PRICE_DECREASE = 4

defItem("robbers_sack", "Robbers Sack", {
    activateDescription = loc("Makes money negative.\nReduces price of items by ${decrease}.", {
        decrease = ROBBER_PRICE_DECREASE
    }),

    basePrice = 10,

    unlockAfterWins = 4,

    canItemFloat = true,

    rarity = lp.rarities.EPIC,
    triggers = {"PULSE"},

    shape = lp.targets.RookShape(7),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targEnt)
            lp.modifierBuff(targEnt, "price", -ROBBER_PRICE_DECREASE)
        end
    },

    onActivate = function(ent)
        local positiveMoney = math.abs(lp.getMoney(ent) or 0)
        lp.setMoney(ent, -positiveMoney)
    end
})

end




--[[


TODO: Implement `reroll_award` item.
TODO
TODO
TODO
TODO
TODO

It should be related to rerolling, and goldsmith-
work fine with money

]]


