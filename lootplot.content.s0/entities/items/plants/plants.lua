local loc = localization.localize

local function defseed(image, name, itemid)
    return lp.defineItem("lootplot.content.s0:"..image, {
        image = image,
        name = loc(name),

        targetType = "SLOT",
        targetShape = lp.targets.LARGE_KING_SHAPE,
        targetTrait = "lootplot.content.s0:PLANT_TRAIT",
        targetActivationDescription = function()
            local etype = server.entities["lootplot.content.s0:"..itemid]
            return loc("Spawn %{name}", etype)
        end,
        targetActivate = function(selfEnt, ppos, targetEnt)
            local etype = server.entities["lootplot.content.s0:"..itemid]
            if etype then
                return lp.trySpawnItem(ppos, etype)
            end
        end
    })
end

defseed("shrub_seeds", "Shrub Seeds", "shrub")
defseed("blue_seeds", "Blueberry Seeds", "blueberry")

lp.defineItem("lootplot.content.s0:shrub", {
    image = "shrub",
    name = loc("Shrub"),
    basePointsGenerated = 1,
    rarity = lp.rarities.UNIQUE,
})
