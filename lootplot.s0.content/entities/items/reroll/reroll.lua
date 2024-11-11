

local loc = localization.localize
local helper = require("shared.helper")

local consts = require("shared.constants")


local function defineDice(id, name, etype)
    etype.name = loc(name)
    etype.rarity = assert(etype.rarity)
    etype.basePrice = 6
    etype.image = etype.image or id

    return lp.defineItem("lootplot.s0.content:"..id, etype)
end




-- White Die: 
-- When rerolled, earn $2
defineDice("white_die", "White Die", {
    triggers = {"REROLL"},
    rarity = lp.rarities.EPIC,
    baseMoneyGenerated = 2,
    baseMaxActivations = 3,
    tierUpgrade = helper.propertyUpgrade("moneyGenerated", 2, 3)
})



defineDice("black_die", "Black Die", {
    triggers = {"REROLL"},
    rarity = lp.rarities.RARE,

    shape = lp.targets.KING_SHAPE,

    baseMaxActivations = 5,
    tierUpgrade = helper.propertyUpgrade("maxActivations", 5, 3),

    target = {
        type = "ITEM",
        description = loc("{lootplot:TRIGGER_COLOR}{wavy}PULSES{/wavy}{/lootplot:TRIGGER_COLOR} item."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("PULSE", targetEnt)
        end
    }
})




--[[
====================
GRUBBY SUB-ARCHETYPE:
====================
]]

defineDice("triple_dice", "Triple Dice", {
    triggers = {"REROLL"},

    rarity = lp.rarities.RARE,

    baseMoneyGenerated = 2,
    tierUpgrade = helper.propertyUpgrade("moneyGenerated",2,3),

    basePrice = 8,
    baseMaxActivations = 10,
    basePointsGenerated = 30,

    grubMoneyCap = consts.GRUB_MONEY_CAP_LOW
})



local PTS = 20
defineDice("quad_dice", "Quad Dice", {
    triggers = {"REROLL"},

    rarity = lp.rarities.UNCOMMON,

    basePrice = 8,
    baseMaxActivations = 10,
    basePointsGenerated = PTS,
    tierUpgrade = helper.propertyUpgrade("pointsGenerated",PTS,3),

    grubMoneyCap = consts.GRUB_MONEY_CAP_LOW,
})
