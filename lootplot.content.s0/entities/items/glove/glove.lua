local loc = localization.localize

local function defineGlove(id, name, description, giveShape, rarity)
    return lp.defineItem("lootplot.content.s0:"..id, {
        image = id,
        name = loc(name),

        rarity = rarity,
        minimumLevelToSpawn = 4,

        targetType = "ITEM",
        targetActivationDescription = loc("{lp_targetColor}" .. description),
        targetShape = lp.targets.ABOVE_SHAPE,
        targetActivate = function(selfEnt, ppos, targetItemEnt)
            if targetItemEnt.targetShape then
                lp.targets.setTargetShape(targetItemEnt, giveShape)
            end
        end
    })
end

defineGlove("quartz_glove",
    "Quartz Glove",
    "Set item's shape to ROOK-10.",
    lp.targets.RookShape(10),
    lp.rarities.LEGENDARY
)

defineGlove("ruby_glove",
    "Ruby Glove",
    "Set item's shape to KING-1.",
    lp.targets.KING_SHAPE,
    lp.rarities.EPIC
)

defineGlove("copper_glove",
    "Copper Glove",
    "Set item's shape to KNIGHT.",
    lp.targets.KNIGHT_SHAPE,
    lp.rarities.RARE
)
