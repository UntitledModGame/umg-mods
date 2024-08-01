local loc = localization.localize

local function defineGlove(id, name, description, giveShape)
    return lp.defineItem("lootplot.content.s0:"..id, {
        image = id,
        name = loc(name),

        targetType = "ITEM",
        targetActivationDescription = loc(description),
        targetShape = lp.targets.ABOVE_SHAPE,
        targetActivate = function(selfEnt, ppos, targetItemEnt)
            lp.targets.setTargetShape(targetItemEnt, giveShape)
        end
    })
end

defineGlove("quartz_glove",
    "Quartz Glove",
    "Give ROOK shape to above item.",
    lp.targets.PlusShape(10, "ROOK-10")
)

defineGlove("ruby_glove",
    "Ruby Glove",
    "Give KING shape to above item.",
    lp.targets.KING_SHAPE
)

defineGlove("copper_glove",
    "Ruby Glove",
    "Give PLUS shape to above item.",
    lp.targets.PlusShape(1)
)

defineGlove("wooden_glove",
    "Ruby Glove",
    "Give ABOVE shape to above item.",
    lp.targets.ABOVE_SHAPE
)
