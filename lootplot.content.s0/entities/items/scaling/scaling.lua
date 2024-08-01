lp.defineItem("lootplot.content.s0:spartan_helmet", {
    image = "spartan_helmet",

    name = localization.localize("Spartan Helmet"),

    targetType = "ITEM",
    targetShape = lp.targets.PlusShape(1),
    targetActivationDescription = localization.localize("Give all target items +0.5 to the generated points permanently."),
    targetActivate = function(selfEnt, ppos, targetEnt)
        lp.modifierBuff(targetEnt, "pointsGenerated", 0.5, selfEnt)
    end
})
