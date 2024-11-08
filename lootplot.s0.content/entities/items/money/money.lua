
local loc = localization.localize
local interp = localization.newInterpolator
local helper = require("shared.helper")


local function defItem(id, etype)
    etype.image = etype.image or id

    return lp.defineItem("lootplot.s0.content:"..id, etype)
end


defItem("gold_sword", {
    basePrice = 8,
    name = loc("Golden Sword"),
    rarity = lp.rarities.RARE,
    baseMoneyGenerated = 1,
    baseMaxActivations = 1,
    tierUpgrade = helper.propertyUpgrade("moneyGenerated", 1, 3)
})


defItem("gold_axe", {
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
local GOLD_BAR_ACTS = 10

defItem("gold_bar", {
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





defItem("lucky_horseshoe", {
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




defItem("gold_knuckles", {
    name = loc("Gold Knuckles"),

    rarity = lp.rarities.RARE,

    triggers = {},

    basePrice = 6,
    baseMoneyGenerated = 2,
    tierUpgrade = helper.propertyUpgrade("moneyGenerated", 2, 2),

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "ITEM",
        filter = function(ent)
            return (not ent.lives) or (ent.lives == 0)
        end,
        activate = function(selfEnt, ppos, ent)
            lp.addMoney(selfEnt,selfEnt.moneyGenerated)
            lp.destroy(ent)
        end,
        description = "Destroy item, and earn money!",
    }
})






local DBT_DESC = interp("Gain {lootplot:POINTS_COLOR}%{points}{/lootplot:POINTS_COLOR} points.\n(money count cubed)\nThen, multiply money by -1.")

defItem("death_by_taxes", {
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