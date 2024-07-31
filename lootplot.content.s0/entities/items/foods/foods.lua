

local loc = localization.localize



lp.defineItem("bb", {
    image = "blueberry",

    name = loc("Blueberry"),
    description = loc("A Blue berry!"),

    rarity = lp.rarities.UNCOMMON,
    baseTraits = {},

    targetType = "ITEM",
    targetShape = lp.targets.ABOVE_SHAPE,
    targetActivationDescription = loc("Gives +1 points generates to target item"),

    targetActivate = function (selfEnt, ppos, targetEnt)
        properties.addPermanent(targetEnt, "pointsGenerated", 1, selfEnt)
    end
})


lp.defineItem("lychee", {
    image = "lychee",

    name = loc("Lychee"),

    rarity = lp.rarities.UNCOMMON,
    baseTraits = {},

    targetType = "ITEM",
    targetShape = lp.targets.ABOVE_SHAPE,
    targetActivationDescription = loc("Gives +1 activations to target item"),

    targetActivate = function (selfEnt, ppos, targetEnt)
        properties.addPermanent(targetEnt, "maxActivations", 1, selfEnt)
    end
})

