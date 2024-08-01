local loc = localization.localize

lp.defineItem("lootplot.content.s0:dark_skull", {
    image = "dark_skull",
    name = loc("Dark Skull"),
    basePointsGenerated = 4,

    targetType = "ITEM",
    targetShape = lp.targets.KING_SHAPE,
    targetActivationDescription = function(selfEnt)
        return loc("Destroys target item, generate {c r=0.4 g=0.4}%{pointsGenerated}{/c} point(s).", selfEnt)
    end,
    targetActivate = function(selfEnt, ppos, targetEnt)
        lp.destroy(targetEnt)
        lp.addPoints(selfEnt, selfEnt.pointsGenerated)
    end
})

lp.defineItem("lootplot.content.s0:profit_purger", {
    image = "profit_purger",
    name = loc("Profit Purger"),
    baseMoneyGenerated = 0.5,

    targetType = "SLOT",
    targetShape = lp.targets.CrossShape(2, "BISHOP-2"),
    targetActivationDescription = function(selfEnt)
        return loc("Destroys target slot, earn(s) {c r=0.5 b=0.4}%{moneyGenerated}{/c} for each.", selfEnt)
    end,
    targetActivate = function(selfEnt, ppos, targetEnt)
        lp.destroy(targetEnt)
        lp.addMoney(selfEnt, selfEnt.moneyGenerated)
    end
})

lp.defineItem("lootplot.content.s0:dark_flint", {
    image = "dark_flint",
    name = loc("Dark Flint"),
    description = loc("When destroyed, generate +10 points."),
    triggers = {"DESTROY"},
    basePointsGenerated = 10
})

lp.defineItem("lootplot.content.s0:reaper", {
    image = "reaper",
    name = loc("Reaper"),
    basePointsGenerated = 4,

    targetType = "ITEM",
    targetShape = lp.targets.PlusShape(1),
    targetActivationDescription = loc("Destroy all target item, permanently gain +0.2 to generated points of current item."),
    targetActivate = function(selfEnt, ppos, targetEnt)
        lp.destroy(targetEnt)
        lp.modifierBuff(selfEnt, "pointsGenerated", 0.2)
    end
})

lp.defineItem("lootplot.content.s0:empty_cauldron", {
    image = "empty_cauldron",
    name = loc("Empty Cauldron"),
    basePointsGenerated = 4,

    targetType = "SLOT",
    targetShape = lp.targets.KING_SHAPE,
    targetActivationDescription = function(selfEnt)
        return loc("Destroys target slot, gain {c r=0.4 g=0.4}%{pointsGenerated}{/c} point(s).", selfEnt)
    end,
    targetActivate = function(selfEnt, ppos, targetEnt)
        lp.destroy(targetEnt)
        lp.addPoints(selfEnt, selfEnt.pointsGenerated)
    end
})
