lp.defineItem("lootplot.content.s0:spartan_helmet", {
    image = "spartan_helmet",

    name = localization.localize("Spartan Helmet"),

    targetType = "ITEM",
    targetShape = lp.targets.PlusShape(1),
    targetActivationDescription = localization.localize("Give +0.5 permanent pointsGenerated to all target items"),
    targetActivate = function(selfEnt, ppos, targetEnt)
        properties.addPermanent(targetEnt, "pointsGenerated", 0.5, selfEnt)
    end

    -- onActivate = function(selfEnt)
    --     local targets = lp.targets.getTargets(selfEnt)
    --     if #targets > 0 then
    --         local targetEnt = table.pick_random(targets)
    --         properties.addPermanent(targetEnt, "pointsGenerated", 0.5, selfEnt)
    --     end
    -- end
})
