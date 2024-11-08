

local loc = localization.localize
local helper = require("shared.helper")


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
    tierUpgrade = helper.propertyUpgrade("moneyGenerated", 2, 3)
})



defineDice("red_die", "Red Die", {
    triggers = {"REROLL"},
    rarity = lp.rarities.RARE,

    shape = lp.targets.KING_SHAPE,

    tierUpgrade = helper.propertyUpgrade("maxActivations", 5, 3),

    target = {
        type = "ITEM",
        description = loc("{lootplot.targets:COLOR}Triggers item."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("PULSE", targetEnt)
        end
    }
})


defineDice("black_die", "Black Die", {
    rarity = lp.rarities.RARE,

    shape = lp.targets.KING_SHAPE,

    tierUpgrade = helper.propertyUpgrade("maxActivations", 5, 3),

    target = {
        type = "ITEM",
        description = loc("{lootplot.targets:COLOR}Trigger REROLL for item."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("REROLL", targetEnt)
        end
    }
})


