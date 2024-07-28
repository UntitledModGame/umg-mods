lp.defineItem("kiwi", {
    image = "kiwi",

    name = "Kiwi",
    description = "The fruit, not the bird!",
    baseBuyPrice = 5,

    rarity = lp.rarities.RARE,
    baseTraits = {},

    targetShape = lp.targets.ROOK_SHAPE,
    targetType = "ITEM",
    activateTargets = function(ent, ppos, targetEnt)
        lp.tryActivateEntity(targetEnt)
    end,
})

