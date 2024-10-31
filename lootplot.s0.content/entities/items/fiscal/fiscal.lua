
local loc = localization.localize
local interp = localization.newInterpolator
local helper = require("shared.helper")


local function defFiscal(id, etype)
    etype.image = etype.image or id

    return lp.defineItem("lootplot.s0.content:"..id, etype)
end


defFiscal("gold_sword", {
    basePrice = 8,
    name = loc("Golden Sword"),
    rarity = lp.rarities.RARE,
    baseMoneyGenerated = 1,
    baseMaxActivations = 1,
    tierUpgrade = helper.propertyUpgrade("moneyGenerated", 1, 3)
})


defFiscal("gold_axe", {
    name = loc("Golden Axe"),

    rarity = lp.rarities.RARE,
    basePrice = 10,

    shape = lp.targets.KNIGHT_SHAPE,

    baseMoneyGenerated = 1,
    baseMaxActivations = 1,
    tierUpgrade = helper.propertyUpgrade("moneyGenerated", 1, 2),

    target = {
        description = loc("Earn money."),
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.addMoney(selfEnt, selfEnt.moneyGenerated or 0)
        end
    }
})


local goldBarDesc = localization.newInterpolator("After %{count} activations, give $10")
local GOLD_BAR_ACTS = 8

defFiscal("gold_bar", {
    name = loc("Gold Bar"),

    description = function(ent)
        return goldBarDesc({
            count = GOLD_BAR_ACTS - (ent.totalActivationCount or 0)
        })
    end,

    basePointsGenerated = 3,
    basePrice = 4,

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


local BISHOP_RING_DESC = localization.newInterpolator("Earn points equal to %{val}% of current balance.")

defFiscal("bishop_ring", {
    name = loc("Bishop Ring"),

    description = function(ent)
        return BISHOP_RING_DESC({
            val = ent.tier * 20
        })
    end,

    tierUpgrade = {
        description = loc("Increases percentage!")
    },

    basePrice = 6,
    basePointsGenerated = 0,

    lootplotProperties = {
        modifiers = {
            pointsGenerated = percentageOfBalanceGetter(0.20)
        }
    },

    rarity = lp.rarities.RARE,
})


local KING_RING_DESC = localization.newInterpolator("Earn money equal to %{val}% of current balance.\n(Max of $20)")

defFiscal("king_ring", {
    name = loc("King Ring"),

    description = function(ent)
        return KING_RING_DESC({
            val = ent.tier * 5
        })
    end,

    tierUpgrade = {
        description = loc("Increases percentage!")
    },

    basePrice = 6,
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




defFiscal("lucky_horseshoe", {
    name = loc("Lucky Horseshoe"),

    rarity = lp.rarities.RARE,

    shape = lp.targets.ON_SHAPE,

    basePrice = 2,

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
                    assert(server.entities.key, "YIKES")
                    lp.forceSpawnItem(ppos, server.entities.key, selfEnt.lootplotTeam)
                else
                    lp.addMoney(selfEnt, 5)
                end
            end
        end
    }
})


defFiscal("gold_watch", {
    name = loc("Gold Watch"),
    description = loc("Increases price by 10%,\n(Max 200)"),

    tierUpgrade = helper.propertyUpgrade("price", 5, 5),
    rarity = lp.rarities.EPIC,

    onActivate = function(ent)
        local x = ent.price * 0.10
        lp.modifierBuff(ent, "price", x, ent)
    end,

    lootplotProperties = {
        maximums = {
            price = 200
        }
    },
})


defFiscal("a_small_loan", {
    name = loc("A Small Loan"),

    triggers = {"BUY"},
    description = loc("Destroys slot and earns money when purchased."),

    basePrice = 5,
    baseMoneyGenerated = 25,

    canItemFloat = true,
    rarity = lp.rarities.RARE,

    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        local slotEnt = ppos and lp.posToSlot(ppos)
        if slotEnt then
            -- this will almost certainly be a shop-slot.
            lp.destroy(slotEnt)
        end
    end
})


defFiscal("robbers_bag", {
    name = loc("Robbers Bag"),
    description = loc("Multiplies money by -1.5"),

    basePrice = 5,

    rarity = lp.rarities.EPIC,
    doomCount = 3,

    onActivate = function(ent)
        local money = lp.getMoney(ent) or 0
        lp.setMoney(ent, money * -1.5)
    end
})



defFiscal("contract", {
    name = loc("Contract"),

    rarity = lp.rarities.UNCOMMON,

    basePrice = 8,
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




defFiscal("gold_knuckles", {
    name = loc("Gold Knuckles"),

    rarity = lp.rarities.RARE,

    triggers = {},

    basePrice = 6,
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






defFiscal("the_negotiator", {
    name = loc("The Negotiator"),

    basePrice = 10,

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



local DBT_DESC = interp("Gain {lootplot:POINTS_COLOR}%{points}{/lootplot:POINTS_COLOR} points.\n(money count cubed)\nThen, multiply money by -1.")

defFiscal("death_by_taxes", {
    name = loc("Death by Taxes"),

    basePrice = 20,
    rarity = lp.rarities.LEGENDARY,

    description = function(ent)
        local money = lp.getMoney(ent) or 0
        return DBT_DESC({
            points = money ^ 3
        })
    end,

    onActivate = function(ent)
        local money = lp.getMoney(ent) or 0
        lp.setMoney(ent, -money)
        lp.addPoints(ent, money^3)
    end
})