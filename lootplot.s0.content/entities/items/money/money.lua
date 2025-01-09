
local loc = localization.localize
local interp = localization.newInterpolator
local helper = require("shared.helper")


local function defItem(id, name, etype)
    etype.image = etype.image or id

    etype.name = loc(name)

    return lp.defineItem("lootplot.s0.content:"..id, etype)
end


--[[

--[===[
NOTE:::

I actually really liked these items!!!
(Especially old golden-axe!)

Perhaps reuse the behaviour for something else?

]===]


defItem("gold_sword", {
    basePrice = 6,
    name = loc("Golden Sword"),
    rarity = lp.rarities.RARE,
    baseMoneyGenerated = 1,
    baseMaxActivations = 1,
    triggers = {"PULSE"},
})


defItem("gold_axe", {
    name = loc("Golden Axe"),

    rarity = lp.rarities.EPIC,

    shape = lp.targets.KNIGHT_SHAPE,

    basePrice = 10,
    baseMaxActivations = 1,
    baseMoneyGenerated = 0.5,

    target = {
        description = loc("Earn money for every target item."),
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.addMoney(selfEnt, selfEnt.moneyGenerated or 0)
        end
    },

    triggers = {"PULSE"},
})

]]



local GOLD_BAR_ACTS = 10

helper.defineDelayItem("gold_bar", "Gold Bar", {
    basePointsGenerated = 3,
    baseMaxActivations = 2,
    basePrice = 4,

    rarity = lp.rarities.UNCOMMON,
    triggers = {"PULSE"},

    delayCount = GOLD_BAR_ACTS,
    delayDescription = loc("Earns {lootplot:MONEY_COLOR}$10"),

    delayAction = function(selfEnt)
        lp.addMoney(selfEnt, 10)
        lp.destroy(selfEnt)
    end
})





defItem("lucky_horseshoe", "Lucky Horseshoe", {
    activateDescription = loc("50% chance to destroy slot.\n40% Chance to earn $5.\n10% Chance to spawn a KEY."),
    rarity = lp.rarities.RARE,

    shape = lp.targets.ON_SHAPE,
    triggers = {"PULSE"},

    basePrice = 2,
    baseMaxActivations = 1,

    target = {
        type = "SLOT",
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




defItem("gold_knuckles", "Gold Knuckles", {
    activateDescription = loc("Destroy target item(s), earns $2 for each"),

    rarity = lp.rarities.RARE,

    triggers = {"PULSE"},

    basePrice = 6,
    baseMaxActivations = 10,
    baseMoneyGenerated = 2,

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, ent)
            lp.addMoney(selfEnt,2)
            lp.destroy(ent)
        end,
    }
})






local DBT_DESC = interp("Gain {lootplot:POINTS_COLOR}%{points}{/lootplot:POINTS_COLOR} points.\n(money count cubed)\nThen, multiply money by -1.")

defItem("death_by_taxes", "Death by Taxes", {
    basePrice = 20,
    baseMaxActivations = 2,
    rarity = lp.rarities.LEGENDARY,
    triggers = {"PULSE"},

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



defItem("gold_crown", "Gold Crown", {
    --[[
    TODO: 
    THIS ITEM IS POORLY DESIGNED!!! 
    ]]
    shape = lp.targets.KING_SHAPE,

    basePrice = 10,
    baseMaxActivations = 1,

    canItemFloat = true,

    baseMoneyGenerated = 2,

    target = {
        description = loc("Earn money for every {lootplot:INFO_COLOR}FLOATING{/lootplot:INFO_COLOR} target item."),
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            return lp.canItemFloat(targetEnt) and (not lp.posToSlot(ppos))
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.addMoney(selfEnt, selfEnt.moneyGenerated or 0)
        end
    },

    rarity = lp.rarities.EPIC,
    triggers = {"PULSE"},
})




local SCISSORS_MONEY_EARNED = 2

defItem("golden_scissors", "Golden Scissors", {
    --[[
    useful for "cutting through" cloud slots,
    and getting free items.
    ]]
    triggers = {"PULSE"},

    activateDescription = loc("Destroy all target-slots. Earn $%{amount} for each slot destroyed.", {
        amount = SCISSORS_MONEY_EARNED
    }),

    basePrice = 10,
    baseMaxActivations = 1,

    shape = lp.targets.UpShape(3),
    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            lp.addMoney(selfEnt, SCISSORS_MONEY_EARNED)
            lp.destroy(targetEnt)
        end
    },

    rarity = lp.rarities.RARE,
})




defItem("coins_and_emerald", "Coins and Emerald", {
    --[[
    anti-synergy with reroll builds
    ]]
    activateDescription = loc("Destroys itself if {lootplot:TRIGGER_COLOR}Reroll{/lootplot:TRIGGER_COLOR} is triggered."),

    sticky = true,

    baseMoneyGenerated = 1,
    baseMaxActivations = 1,

    basePrice = 8,

    rarity = lp.rarities.RARE,

    triggers = {"PULSE", "REROLL"},

    onTriggered = function(ent, triggerName)
        if triggerName == "REROLL" then
            lp.destroy(ent)
        end
    end,
})


