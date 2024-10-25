
local loc = localization.localize
local helper = require("shared.helper")


lp.defineItem("lootplot.s0.content:gold_sword", {
    image = "gold_sword",
    name = loc("Golden Sword"),
    rarity = lp.rarities.RARE,
    baseMoneyGenerated = 1,
    tierUpgrade = helper.propertyUpgrade("moneyGenerated", 1, 3)
})


lp.defineItem("lootplot.s0.content:gold_axe", {
    image = "gold_axe",
    name = loc("Golden Axe"),

    rarity = lp.rarities.RARE,

    shape = lp.targets.ABOVE_BELOW_SHAPE,

    baseMoneyGenerated = 1,
    tierUpgrade = helper.propertyUpgrade("moneyGenerated", 1, 2),

    target = {
        description = loc("Earn money."),
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            local pGen = targetEnt.pointsGenerated or 0
            if pGen and pGen > 0 then
                return true
            end
            return false
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.addMoney(selfEnt, selfEnt.moneyGenerated or 0)
        end
    }
})


local goldBarDesc = localization.newInterpolator("After %{count} activations, give $10")
local GOLD_BAR_ACTS = 10

lp.defineItem("lootplot.s0.content:gold_bar", {
    image = "gold_bar",
    name = loc("Gold Bar"),
    description = function(ent)
        return goldBarDesc({
            count = GOLD_BAR_ACTS - (ent.totalActivationCount or 0)
        })
    end,

    basePointsGenerated = 3,

    rarity = lp.rarities.COMMON,

    onActivate = function(selfEnt)
        if selfEnt.totalActivationCount >= GOLD_BAR_ACTS then
            lp.addMoney(selfEnt, 10)
            lp.destroy(selfEnt)
        end
    end
})




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


lp.defineItem("lootplot.s0.content:bishop_ring", {
    image = "bishop_ring",
    name = loc("Bishop Ring"),

    description = helper.tierLocalize({
        "Earn money equal to 20% of current balance.\n(Max of $20)",
        "Earn money equal to 40% of current balance.\n(Max of $20)",
        "Earn money equal to 60% of current balance.\n(Max of $20)",
    }),

    basePointsGenerated = 0,

    lootplotProperties = {
        modifiers = {
            pointsGenerated = percentageOfBalanceGetter(0.20)
        }
    },

    rarity = lp.rarities.RARE,
})


lp.defineItem("lootplot.s0.content:king_ring", {
    image = "king_ring",
    name = loc("King Ring"),

    description = helper.tierLocalize({
        "Earn money equal to 5% of current balance.\n(Max of $20)",
        "Earn money equal to 10% of current balance.\n(Max of $20)",
        "Earn money equal to 15% of current balance.\n(Max of $20)",
    }),

    baseMoneyGenerated = 0,

    lootplotProperties = {
        maximums = {
            moneyGenerated = 20
        },
        modifiers = {
            moneyGenerated = percentageOfBalanceGetter(0.05)
        }
    },

    rarity = lp.rarities.RARE,
})




lp.defineItem("lootplot.s0.content:lucky_horseshoe", {
    image = "lucky_horseshoe",
    name = loc("Lucky Horseshoe"),

    rarity = lp.rarities.RARE,

    shape = lp.targets.ON_SHAPE,

    target = {
        type = "SLOT",
        description = loc("50% chance to destroy slot.\n40% Chance to earn $5.\n10% Chance to spawn a KEY."),
        activate = function(selfEnt, ppos, targetEnt)
            if lp.SEED:randomMisc() <= 0.5 then
                lp.destroy(targetEnt)
            else
                -- YEAH, maths! (0.1 / (0.4+0.1) = 0.2)
                if lp.SEED:randomMisc() < 0.2 then
                    lp.destroy(selfEnt)
                    lp.forceSpawnItem(ppos, server.entities.key, selfEnt.lootplotTeam)
                else
                    lp.addMoney(selfEnt, 5)
                end
            end
        end
    }
})



lp.defineItem("lootplot.s0.content:money_bag", {
    image = "money_bag",
    name = loc("Money Bag"),
    description = loc("Price increases by 5% each activation.\nCapped at $200."),

    rarity = lp.rarities.EPIC,

    basePrice = 5,
    tierUpgrade = helper.propertyUpgrade("price", 5, 5),

    lootplotProperties = {
        maximums = {
            price = 200
        }
    },

    onActivate = function(ent)
        local x = ent.price * 0.05
        lp.modifierBuff(ent, "price", x, ent)
    end
})

lp.defineItem("lootplot.s0.content:robbers_bag", {
    image = "robbers_bag",
    name = loc("Robbers Bag"),
    description = loc("Steals money, and increases its price by the amount stolen!"),

    baseMoneyGenerated = -3,
    tierUpgrade = helper.propertyUpgrade("moneyGenerated", -3, 3),

    rarity = lp.rarities.EPIC,

    onActivate = function(ent)
        local moneyGen = ent.moneyGenerated
        lp.modifierBuff(ent, "price", -moneyGen, ent)
    end
})



lp.defineItem("lootplot.s0.content:contract", {
    image = "contract",
    name = loc("Contract"),

    rarity = lp.rarities.UNCOMMON,

    basePrice = 5,
    tierUpgrade = helper.propertyUpgrade("price", 5, 5),

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "ITEM",
        description = loc("Generate points equal to the price of item."),
        filter = function(selfEnt, ppos, targetEnt)
            return targetEnt.price
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.addPoints(selfEnt, targetEnt.price)
        end
    }
})




lp.defineItem("lootplot.s0.content:gold_knuckles", {
    image = "gold_knuckles",
    name = loc("Gold Knuckles"),

    rarity = lp.rarities.RARE,

    triggers = {},

    basePrice = 5,
    baseMoneyGenerated = 3,
    tierUpgrade = helper.propertyUpgrade("moneyGenerated", 2, 2),

    shape = lp.targets.KING_SHAPE,

    listen = {
        trigger = "DESTROY",
        filter = function(ent)
            return (not ent.lives) or (ent.lives == 0)
        end,
        description = "If target has no extra-lives, earn money",
    }
})






lp.defineItem("lootplot.s0.content:robber", {
    image = "robber",
    name = loc("Robber"),

    rarity = lp.rarities.EPIC,

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "ITEM",
        description = loc("If item price is less than $20,\nSet price to 0"),
        activate = function(selfEnt, ppos, targetEnt)
            if targetEnt.price and targetEnt.price < 20 then
                lp.multiplierBuff(targetEnt, "price", 0, selfEnt)
            end
        end
    }
})


