lp.defineItem("lootplot.content.s0:spartan_helmet", {
    image = "spartan_helmet",

    name = localization.localize("Spartan Helmet"),

    rarity = lp.rarities.RARE,

    shape = lp.targets.RookShape(1),

    target = {
        type = "ITEM",
        description = localization.localize("{lp_targetColor}Buff all target items: +0.5 generated points."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 0.5, selfEnt)
        end
    }
})
