
local loc = localization.localize
local interp = localization.newInterpolator
local helper = require("shared.helper")


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
local BISHOP_RING_DESC = interp("Earn points equal to %{val}% of current balance.")

local function defSilvRing(id,name,trigger)
    defItem(id, {
        name = loc(name),
        triggers={trigger},

        activateDescription = function(ent)
            return BISHOP_RING_DESC({
                val = ent.tier * POINT_PERCENT
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




local SILVER_RING_DESC = interp("Earn money equal to %{val}% of current balance.\n(Max of $20)")
local MONEY_PERCENT = 10

local function defGoldRing(id, name, trigger)
    defItem(id, {
        name = loc(name),
        triggers = {trigger},

        activateDescription = function(ent)
            return SILVER_RING_DESC({
                val = ent.tier * MONEY_PERCENT
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




