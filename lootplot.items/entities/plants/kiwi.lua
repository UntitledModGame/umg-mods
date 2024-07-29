lp.defineItem("kiwi", {
    image = "kiwi",

    name = "Kiwi",
    baseBuyPrice = 5,

    rarity = lp.rarities.RARE,
    baseTraits = {},

    baseMoneyGenerated = -1,

    targetShape = lp.targets.ROOK_SHAPE,
    targetType = "ITEM",
    activateTargets = function(ent, ppos, targetEnt)
        lp.tryActivateEntity(targetEnt)
    end,
    targetActivationDescription = localization.localize("Pulses item.")
})

