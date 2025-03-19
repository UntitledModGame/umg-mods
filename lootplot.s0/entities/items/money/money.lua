
local loc = localization.localize
local interp = localization.newInterpolator
local helper = require("shared.helper")


local function defItem(id, name, etype)
    etype.image = etype.image or id

    etype.name = loc(name)

    return lp.defineItem("lootplot.s0:"..id, etype)
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
    basePointsGenerated = 8,
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





defItem("golden_horseshoe", "Golden Horseshoe", {
    activateDescription = loc("50% chance to double your money.\nIf that fails, set money to 0."),
    rarity = lp.rarities.UNCOMMON,

    triggers = {"PULSE"},

    onActivate = function(ent)
        local SUCCESS_CHANCE = 0.55
        if lp.SEED:randomMisc() < SUCCESS_CHANCE then
            local money = lp.getMoney(ent) or 0
            lp.addMoney(ent, money)
        else
            lp.setMoney(ent, 0)
        end
        --[[
        shhhh, LMAO!! 
        Dont tell anyone that its actually 55% success rate!
        To communicate secretly, to determine whether someone 
        knows about the horseshoe's true nature,
        we shall use code-words:

        Instead of saying:
        "Do you know about the horseshoe's real chances?"
        you should say:
        "In the horseshoe we trust"

        And if someone says that to you, You should reply with:
        "The horseshoe trusts us, comrade"

        ^^^ this will be our secret message.
        With this, we will know how to identify each other.
        Whatever you do, DO NOT spoil the gag publically.
        If you spoil anything in the discord, BAN BAN BAN BAN. BAAANNNN!
        Thank you, my comrades. o7 o7 o7
        ]]
    end,

    basePrice = 0,
    baseMaxActivations = 5,
})





--[[
-- TODO: Rework this item at some point.

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
]]




--[[
-- TODO: Rework this item at some point.
defItem("gold_crown", "Gold Crown", {
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

]]



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
    activateDescription = loc("When {lootplot:TRIGGER_COLOR}Pulsed{/lootplot:TRIGGER_COLOR}, earn {lootplot:MONEY_COLOR}$2{/lootplot:MONEY_COLOR}\nWhen {lootplot:TRIGGER_COLOR}Rerolled{/lootplot:TRIGGER_COLOR}, lose {lootplot:MONEY_COLOR}$2"),

    sticky = true,

    baseMaxActivations = 6,

    basePrice = 8,

    rarity = lp.rarities.RARE,

    triggers = {"PULSE", "REROLL"},

    onTriggered = function(ent, triggerName)
        if triggerName == "REROLL" then
            lp.addMoney(ent, -2)
        elseif triggerName == "PULSE" then
            lp.addMoney(ent, 2)
        end
    end,
})


