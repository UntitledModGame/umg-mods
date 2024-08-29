local loc = localization.localize

local function defineGlove(id, name, description, giveShape)
    return lp.defineItem("lootplot.content.s0:"..id, {
        image = id,
        name = loc(name),

        targetType = "ITEM",
        targetActivationDescription = loc("{lp_targetColor}" .. description),
        targetShape = lp.targets.ABOVE_SHAPE,
        targetActivate = function(selfEnt, ppos, targetItemEnt)
            if targetItemEnt.targetShape then
                -- dont wanna give shape to non-shape items.
                -- HMM: Maybe this should change in future??
                lp.targets.setTargetShape(targetItemEnt, giveShape)
            end
        end
    })
end

defineGlove("quartz_glove",
    "Quartz Glove",
    "Give ROOK shape to item.",
    lp.targets.PlusShape(10, "ROOK-10")
)

defineGlove("ruby_glove",
    "Ruby Glove",
    "Give KING shape to item.",
    lp.targets.KING_SHAPE
)

defineGlove("copper_glove",
    "Copper Glove",
    "Give KNIGHT shape to item.",
    lp.targets.KNIGHT_SHAPE
)
