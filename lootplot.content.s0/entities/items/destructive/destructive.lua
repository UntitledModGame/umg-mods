local loc = localization.localize

lp.defineItem("lootplot.content.s0:dark_skull", {
    image = "dark_skull",
    name = loc("Dark Skull"),
    basePointsGenerated = 5,

    rarity = lp.rarities.UNCOMMON,
    minimumLevelToSpawn = 2,

    targetType = "ITEM",
    targetShape = lp.targets.KING_SHAPE,
    targetActivationDescription = function(selfEnt)
        return loc("{lp_targetColor}Destroys target item, generate {c r=0.4 g=0.4}%{pointsGenerated}{/c} point(s).", selfEnt)
    end,
    targetActivate = function(selfEnt, ppos, targetEnt)
        lp.destroy(targetEnt)
        lp.addPoints(selfEnt, selfEnt.pointsGenerated)
    end
})


lp.defineItem("lootplot.content.s0:profit_purger", {
    image = "profit_purger",
    name = loc("Profit Purger"),
    baseMoneyGenerated = 1,

    rarity = lp.rarities.EPIC,
    minimumLevelToSpawn = 2,

    targetType = "SLOT",
    targetShape = lp.targets.BishopShape(2),
    targetActivationDescription = function(selfEnt)
        return loc("{lp_targetColor}Destroys target slot, earn(s) {c r=0.5 b=0.4}%{moneyGenerated}{/c}", selfEnt)
    end,
    targetActivate = function(selfEnt, ppos, targetEnt)
        lp.destroy(targetEnt)
        lp.addMoney(selfEnt, selfEnt.moneyGenerated)
    end
})


lp.defineItem("lootplot.content.s0:dark_flint", {
    image = "dark_flint",
    name = loc("Dark Flint"),
    rarity = lp.rarities.COMMON,
    description = loc("When destroyed, generate +10 points."),
    triggers = {"DESTROY"},
    basePointsGenerated = 10
})


lp.defineItem("lootplot.content.s0:reaper", {
    image = "reaper",
    name = loc("Reaper"),
    basePointsGenerated = 4,

    rarity = lp.rarities.RARE,
    minimumLevelToSpawn = 2,

    targetType = "ITEM",
    targetShape = lp.targets.RookShape(1),
    targetActivationDescription = loc("{lp_targetColor}Destroy target items, permanently gain +3 points-generated"),
    targetActivate = function(selfEnt, ppos, targetEnt)
        lp.destroy(targetEnt)
        lp.modifierBuff(selfEnt, "pointsGenerated", 3)
    end
})


lp.defineItem("lootplot.content.s0:empty_cauldron", {
    image = "empty_cauldron",
    name = loc("Empty Cauldron"),
    basePointsGenerated = 5,

    rarity = lp.rarities.UNCOMMON,
    minimumLevelToSpawn = 2,

    targetType = "SLOT",
    targetShape = lp.targets.KING_SHAPE,
    targetActivationDescription = function(selfEnt)
        return loc("{lp_targetColor}Destroys target slot, gain {c r=0.4 g=0.4}%{pointsGenerated}{/c} point(s).", selfEnt)
    end,
    targetActivate = function(selfEnt, ppos, targetEnt)
        lp.destroy(targetEnt)
        lp.addPoints(selfEnt, selfEnt.pointsGenerated)
    end
})
