

local loc = localization.localize



lp.defineItem("bb", {
    image = "blueberry",

    name = loc("Blueberry"),
    description = loc("A Blue berry!"),

    rarity = lp.rarities.UNCOMMON,
    baseTraits = {},

    targetShape = lp.targets.ABOVE_SHAPE,

    targetActivate = function (selfEnt, ppos, targetEnt)
        --[[
        TODO:::
        Should we have a buffing system here?
        `lp.buff()`? 
        ]]
        targetEnt.basePointsGenerated = targetEnt.basePointsGenerated + 1
    end
})


lp.defineItem("lychee", {
    image = "lychee",

    name = loc("Lychee"),

    rarity = lp.rarities.UNCOMMON,
    baseTraits = {},

    targetShape = lp.targets.ABOVE_SHAPE,
    targetDescription = loc("Gives +1 activations to target item"),

    targetActivate = function (selfEnt, ppos, targetEnt)
        --[[
        TODO:::
        Should we have a buffing system here?

        API IDEA:
        `lp.buff(ent, "maxActivations", 1, srcEnt?)`
        ]]
        targetEnt.baseMaxActivations = targetEnt.baseMaxActivations + 1
    end
})

