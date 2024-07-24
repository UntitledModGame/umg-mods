lp.defineItem("kiwi", {
    image = "kiwi",

    name = "Kiwi",
    description = "https://www.youtube.com/watch?v=Qk4KcP1VGIc",
    baseBuyPrice = 5,

    rarity = lp.rarities.COMMON,
    baseTraits = {},

    targetShape = lp.targets.ROOK_SHAPE,
    targetType = "ITEM",
    activateTargets = function(ent, ppos, targetEnt)
        lp.tryActivateEntity(targetEnt)
    end,
})

