local loc = localization.localize

local function defseed(image, name, itemid)
    return lp.defineItem("lootplot.content.s0:"..image, {
        image = image,
        name = loc(name),

        targetType = "SLOT",
        targetShape = lp.targets.LARGE_KING_SHAPE,
        targetTrait = "lootplot.content.s0:BOTANIC",
        targetActivationDescription = function()
            local etype = (client or server).entities["lootplot.content.s0:"..itemid]
            return loc("{lp_targetColor}Spawn %{name}", etype)
        end,
        targetActivate = function(selfEnt, ppos, targetEnt)
            local etype = server.entities["lootplot.content.s0:"..itemid]
            if etype then
                return lp.trySpawnItem(ppos, etype, selfEnt.lootplotTeam)
            end
        end
    })
end

defseed("shrub_seeds", "Shrub Seeds", "shrub")
defseed("blue_seeds", "Blue Seeds", "blue_shrub")

lp.defineItem("lootplot.content.s0:shrub", {
    image = "shrub",
    name = loc("Shrub"),
    basePointsGenerated = 1,
    rarity = lp.rarities.UNIQUE,
})

lp.defineItem("lootplot.content.s0:blue_shrub", {
    image = "shrub",
    triggers = {"DESTROY"},
    name = loc("Blue shrub"),
    description = loc("Activates when destroyed"),
    basePointsGenerated = 3,
    rarity = lp.rarities.UNIQUE,
})
