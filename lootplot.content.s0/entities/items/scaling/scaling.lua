local loc = localization.localize

lp.defineItem("lootplot.content.s0:spartan_helmet", {
    image = "spartan_helmet",

    name = loc("Spartan Helmet"),

    rarity = lp.rarities.RARE,

    shape = lp.targets.RookShape(1),

    target = {
        type = "ITEM",
        description = loc("{lootplot.targets:COLOR}Buff all target items: +1 generated points."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 1, selfEnt)
        end
    }
})
