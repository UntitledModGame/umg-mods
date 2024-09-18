local loc = localization.localize

lp.defineItem("lootplot.content.s0:gold_sword", {
    image = "gold_sword",
    name = loc("Golden Sword"),
    description = loc("Earn 1 money."),
    rarity = lp.rarities.COMMON,
    baseMoneyGenerated = 1
})


lp.defineItem("lootplot.content.s0:gold_axe", {
    image = "gold_axe",
    name = loc("Golden Axe"),

    baseMoneyGenerated = 1,

    rarity = lp.rarities.RARE,

    shape = lp.targets.KNIGHT_SHAPE,

    target = {
        description = loc("{lootplot.targets:COLOR}Earn money if item generates points."),
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


lp.defineItem("lootplot.content.s0:golden_fruit", {
    image = "golden_fruit",
    name = loc("Golden Fruit"),
    description = loc("After 3 activations, give 10 money."),

    rarity = lp.rarities.UNCOMMON,

    doomCount = 3,
    onActivate = function(selfEnt)
        if selfEnt.totalActivationCount >= 3 then
            return lp.addMoney(selfEnt, 10)
        end
    end
})




local function percentageOfBalanceGetter(percentage)
    return function(ent)
        local money = lp.getMoney(ent)
        if money then
            return money * percentage
        end
        return 0
    end
end


lp.defineItem("lootplot.content.s0:bishop_ring", {
    image = "bishop_ring",
    name = loc("Bishop Ring"),
    description = loc("Generate points equal to 20% of the current balance."),

    basePointsGenerated = 0,

    lootplotProperties = {
        modifiers = {
            pointsGenerated = percentageOfBalanceGetter(0.20)
        }
    },

    rarity = lp.rarities.UNCOMMON,
})


lp.defineItem("lootplot.content.s0:king_ring", {
    image = "king_ring",
    name = loc("King Ring"),
    description = loc("Earn money equal to 5% of current balance.\n(Max of $20)"),

    baseMoneyGenerated = 0,

    lootplotProperties = {
        maximums = {
            moneyGenerated = 20
        },
        modifiers = {
            moneyGenerated = percentageOfBalanceGetter(0.05)
        }
    },

    rarity = lp.rarities.UNCOMMON,
})




lp.defineItem("lootplot.content.s0:lucky_horseshoe", {
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



lp.defineItem("lootplot.content.s0:money_bag", {
    image = "money_bag",
    name = loc("Money Bag"),
    description = loc("Price increases by 5% each activation.\nCapped at $200."),

    rarity = lp.rarities.EPIC,

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




lp.defineItem("lootplot.content.s0:robber", {
    image = "robber",
    name = loc("Robber"),

    rarity = lp.rarities.EPIC,

    shape = lp.targets.KING_SHAPE,

    --[[
    
    TODO:
    In the future, when we allow for UPGRADED robber:
    We should make it so the robber multiplies price by -1!!!

    That could lead to really creative synergies.
    ]]
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


