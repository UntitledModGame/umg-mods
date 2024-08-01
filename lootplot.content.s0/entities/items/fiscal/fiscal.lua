local loc = localization.localize

lp.defineItem("lootplot.content.s0:gold_sword", {
    image = "gold_sword",
    name = loc("Golden Sword"),
    description = loc("Earn 1 money."),
    baseMoneyGenerated = 1
})

lp.defineItem("lootplot.content.s0:king_ring", {
    image = "king_ring",
    name = loc("King Ring"),
    description = loc("Earn money equal to 5% of current balance."),
    onActivate = function(selfEnt)
        local money = lp.getMoney(selfEnt)
        if money then
            lp.addMoney(selfEnt, money * 0.05)
        end
    end
})

lp.defineItem("lootplot.content.s0:gold_axe", {
    image = "gold_axe",
    name = loc("Golden Axe"),

    targetActivationDescription = loc("Earn money equal to 50% of points generated of target item."),
    targetType = "ITEM",
    targetShape = lp.targets.ABOVE_SHAPE,
    targetActivate = function(selfEnt, ppos, targetEnt)
        local generatedPoints = targetEnt.pointsGenerated or 0
        local money = generatedPoints / 2

        if money > 0 then
            lp.addMoney(selfEnt, money)
        end
    end
})

lp.defineItem("lootplot.content.s0:golden_fruit", {
    image = "golden_fruit",
    name = loc("Golden Fruit"),
    description = loc("After 3 activations, give 10 money."),
    doomCount = 3,
    onActivate = function(selfEnt)
        if selfEnt.totalActivationCount >= 3 then
            return lp.addMoney(selfEnt, 10)
        end
    end
})

lp.defineItem("lootplot.content.s0:bishop_ring", {
    image = "bishop_ring",
    name = loc("Bishop Ring"),
    description = loc("Generate points equal to 20% of the current balance."),
    onActivate = function(selfEnt)
        local money = lp.getMoney(selfEnt)
        if money then
            return lp.addPoints(selfEnt, money * 0.2)
        end
    end
})
