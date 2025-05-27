

local loc = localization.localize

local helper = require("shared.helper")
local constants = require("shared.constants")


local CHESTPLATE_SHAPE = lp.targets.HorizontalShape(3)


local function defChestplate(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    if not etype.listen then
        etype.triggers = etype.triggers or {"PULSE"}
    end

    etype.shape = etype.shape or CHESTPLATE_SHAPE

    etype.rarity = etype.rarity or lp.rarities.RARE
    etype.basePrice = etype.basePrice or 10

    etype.baseMaxActivations = etype.baseMaxActivations or 4

    return lp.defineItem("lootplot.s0:"..id, etype)
end



defChestplate("deathly_chestplate", "Deathly Chestplate", {
    listen = {
        type = "ITEM",
        trigger="DESTROY"
    },

    lootplotTags = {constants.tags.DESTRUCTIVE},
    unlockAfterWins = constants.UNLOCK_AFTER_WINS.DESTRUCTIVE,

    activateDescription = loc("Give items {lootplot:POINTS_COLOR}+10 points"),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, itemEnt)
            lp.modifierBuff(itemEnt, "pointsGenerated", 10, selfEnt)
        end
    }
})



do
local PTS_REQ = 50
local BUFF = 4

defChestplate("hardened_chestplate", "Hardened Chestplate", {
    activateDescription = loc("If items generate more than {lootplot:POINTS_COLOR}%{req} points{/lootplot:POINTS_COLOR}, Give items {lootplot:POINTS_COLOR}+%{buff} points", {
        req = PTS_REQ,
        buff = BUFF
    }),

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, itemEnt)
            return (itemEnt.pointsGenerated or 0) > PTS_REQ
        end,
        activate = function(selfEnt, ppos, itemEnt)
            lp.modifierBuff(itemEnt, "pointsGenerated", BUFF, selfEnt)
        end
    }
})
end



defChestplate("iron_chestplate", "Iron Chestplate", {
    activateDescription = loc("Give items {lootplot:BONUS_COLOR}+1 bonus"),

    baseMoneyGenerated = -1,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, itemEnt)
            lp.modifierBuff(itemEnt, "bonusGenerated", 1, selfEnt)
        end
    }
})



defChestplate("copper_chestplate", "Copper Chestplate", {
    activateDescription = loc("Increase price of items by {lootplot:MONEY_COLOR}$3{/lootplot:MONEY_COLOR}.\nRotate items."),

    baseMoneyGenerated = -1,
    unlockAfterWins = constants.UNLOCK_AFTER_WINS.ROTATEY,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, itemEnt)
            lp.modifierBuff(itemEnt, "price", 3, selfEnt)
            lp.rotateItem(itemEnt, 1)
        end
    }
})



defChestplate("golden_chestplate", "Golden Chestplate", {
    activateDescription = loc("Earn {lootplot:MONEY_COLOR}$1{/lootplot:MONEY_COLOR} for every targeted item."),

    baseMoneyGenerated = -3,
    baseMaxActivations = 2,
    rarity = lp.rarities.EPIC,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, itemEnt)
            lp.addMoney(selfEnt, 1)
        end
    }
})



defChestplate("magical_chestplate", "Magical Chestplate", {
    activateDescription = loc("Buff item's {lootplot:POINTS_COLOR}points{/lootplot:POINTS_COLOR} by the current {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR}"),

    rarity = lp.rarities.LEGENDARY,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, itemEnt)
            local b = lp.getPointsBonus(selfEnt) or 0
            if b ~= 0 then
                lp.modifierBuff(itemEnt, "pointsGenerated", b, selfEnt)
            end
        end
    }
})




defChestplate("ethereal_tunic", "Ethereal Tunic", {
    activateDescription = loc("If items have negative bonus, give items {lootplot:POINTS_MULT_COLOR}+1 multiplier"),

    baseMoneyGenerated = -2,

    unlockAfterWins = 3,

    rarity = lp.rarities.EPIC,

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, itemEnt)
            return (itemEnt.bonusGenerated or 0xff) < 0
        end,
        activate = function(selfEnt, ppos, itemEnt)
            lp.modifierBuff(itemEnt, "multGenerated", 1, selfEnt)
        end
    }
})



