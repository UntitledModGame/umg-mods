local loc = localization.localize

local function defineGlove(id, name, description, giveShape)
    return lp.defineItem("lootplot.content.s0:"..id, {
        image = id,
        name = loc(name),

        targetType = "ITEM",
        targetShape = lp.targets.ABOVE_SHAPE,
        targetActivate = function(selfEnt, ppos, targetItemEnt)
            lp.targets.setTargetShape(targetItemEnt, giveShape)
        end
    })
end
