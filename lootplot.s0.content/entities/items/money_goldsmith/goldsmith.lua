
local loc = localization.localize
local interp = localization.newInterpolator
local helper = require("shared.helper")

local MONEY_REQUIREMENT = 30


local function defItem(id, etype)
    etype.image = etype.image or id
    return lp.defineItem("lootplot.s0.content:"..id, etype)
end




local function percentageOfBalanceGetter(percentage)
    return function(ent)
        local tier = lp.tiers.getTier(ent)
        local money = lp.getMoney(ent)
        if money then
            return money * percentage * tier
        end
        return 0
    end
end


local POINT_PERCENT = 100
local SILV_RING_DESC = interp("Earn points equal to %{val}% of current balance.\n{lootplot:MONEY_COLOR}(Balance: $%{balance})")

local function defSilvRing(id,name,trigger)
    defItem(id, {
        name = loc(name),
        triggers={trigger},

        activateDescription = function(ent)
            return SILV_RING_DESC({
                val = ent.tier * POINT_PERCENT,
                balance = lp.getMoney(ent) or 0
            })
        end,

        tierUpgrade = {
            description = loc("Increases percentage!")
        },

        basePrice = 6,
        basePointsGenerated = 0,

        lootplotProperties = {
            modifiers = {
                pointsGenerated = percentageOfBalanceGetter(POINT_PERCENT / 100.0)
            }
        },

        rarity = lp.rarities.RARE,
    })
end


defSilvRing("silver_pulse_ring", "Silver Pulse Ring", "PULSE")
defSilvRing("silver_reroll_ring", "Silver Reroll Ring", "REROLL")




local GOLD_RING_DESC = interp("Earn money equal to %{val}% of current balance {lootplot:MONEY_COLOR}($%{balance}){/lootplot:MONEY_COLOR}.\n(Max of $20)")
local MONEY_PERCENT = 10

local function defGoldRing(id, name, trigger)
    defItem(id, {
        name = loc(name),
        triggers = {trigger},

        activateDescription = function(ent)
            return GOLD_RING_DESC({
                val = ent.tier * MONEY_PERCENT,
                balance = lp.getMoney(ent) or 0
            })
        end,

        tierUpgrade = {
            description = loc("Increases percentage!")
        },

        basePrice = 8,
        baseMoneyGenerated = 0,

        lootplotProperties = {
            maximums = {
                moneyGenerated = 20
            },
            modifiers = {
                moneyGenerated = percentageOfBalanceGetter(MONEY_PERCENT/100.0)
            }
        },

        rarity = lp.rarities.EPIC,
    })
end

defGoldRing("gold_pulse_ring", "Gold Pulse Ring", "PULSE")
defGoldRing("gold_reroll_ring", "Gold Reroll Ring", "REROLL")


local TOPAZ_BUFF = 3
local TOPAZ_DESC = interp("If {lootplot:MONEY_COLOR}money > $%{moneyReq}{/lootplot:MONEY_COLOR}, permanently gain %{pointBuff} points.\n"){
    pointBuff = 3,
    moneyReq = MONEY_REQUIREMENT
}

defItem("belt_topaz", {
    name = loc("Topaz Belt"),
    activateDescription = TOPAZ_DESC,

    basePointsGenerated = 20,
    baseMaxActivations = 2,
    tierUpgrade = helper.propertyUpgrade("maxActivations", 2, 3),

    onActivate = function(ent)
        if (lp.getMoney(ent) or 0) > MONEY_REQUIREMENT then
            lp.modifierBuff(ent, "pointsGenerated", TOPAZ_BUFF, ent)
        end
    end,

    rarity = lp.rarities.RARE
})



do
local RUBY_DESC = interp("Only works if {lootplot:MONEY_COLOR}money > $%{moneyReq}!"){
    moneyReq = MONEY_REQUIREMENT
}
defItem("belt_ruby", {
    name = loc("Ruby Belt"),
    activateDescription = RUBY_DESC,

    baseMaxActivations = 4,
    basePointsGenerated = 50,
    tierUpgrade = helper.propertyUpgrade("maxActivations", 4, 3),

    canActivate = function(ent)
        if (lp.getMoney(ent) or 0) > MONEY_REQUIREMENT then
            return true
        end
    end,

    rarity = lp.rarities.UNCOMMON
})
end






defItem("gold_coin", {
    name = loc("Gold Coin"),
    activateDescription = interp("Only activates if {lootplot:MONEY_COLOR}money > $%{moneyReq}{/lootplot:MONEY_COLOR}"){
        moneyReq = MONEY_REQUIREMENT
    },

    baseMoneyGenerated = 1,
    baseMaxActivations = 1,
    basePrice = 12,
    basePointsGenerated = 200,
    tierUpgrade = helper.propertyUpgrade("maxActivations", 1, 3),

    canActivate = function(ent)
        return (lp.getMoney(ent) or 0) > MONEY_REQUIREMENT
    end,

    rarity = lp.rarities.RARE
})



defItem("robbers_bag", {
    name = loc("Robbers Bag"),
    activateDescription = loc("Multiplies money by -1.5"),

    basePrice = 10,

    rarity = lp.rarities.EPIC,
    doomCount = 3,

    onActivate = function(ent)
        local money = lp.getMoney(ent) or 0
        lp.setMoney(ent, money * -1.5)
    end
})



local function exponential(ent)
    return 2^(ent.totalActivationCount or 0)
end

defItem("golden_spoon", {
    name = loc("Golden Spoon"),
    activateDescription = loc("Cost and points are doubled each activation."),

    basePrice = 20,

    rarity = lp.rarities.EPIC,

    lootplotProperties = {
        multipliers = {
            moneyGenerated = exponential,
            pointsGenerated = exponential
        }
    },

    baseMoneyGenerated = -1,
    basePointsGenerated = 100,
})




