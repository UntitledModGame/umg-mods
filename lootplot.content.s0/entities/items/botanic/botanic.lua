
-- local loc = localization.localize

-- local function defseed(image, name, itemid)
--     return lp.defineItem("lootplot.s0.content:"..image, {
--         image = image,
--         name = loc(name),

--         rarity = lp.rarities.COMMON,
--         minimumLevelToSpawn = 4,

--         targetType = "SLOT",
--         targetShape = lp.targets.LARGE_KING_SHAPE,
--         targetTrait = "lootplot.s0.content:BOTANIC",
--         targetActivationDescription = function()
--             local etype = (client or server).entities["lootplot.s0.content:"..itemid]
--             return loc("{lootplot.targets:COLOR}Spawn %{name}", etype)
--         end,
--         targetActivate = function(selfEnt, ppos, targetEnt)
--             local etype = server.entities["lootplot.s0.content:"..itemid]
--             if etype then
--                 return lp.trySpawnItem(ppos, etype, selfEnt.lootplotTeam)
--             end
--         end
--     })
-- end

-- defseed("shrub_seeds", "Shrub Seeds", "shrub")
-- defseed("blue_seeds", "Blue Seeds", "blue_shrub")

-- lp.defineItem("lootplot.s0.content:shrub", {
--     image = "shrub",
--     name = loc("Shrub"),
--     basePointsGenerated = 1,
--     rarity = lp.rarities.UNIQUE,
-- })

-- lp.defineItem("lootplot.s0.content:blue_shrub", {
--     image = "shrub",
--     triggers = {"DESTROY"},
--     name = loc("Blue shrub"),
--     description = loc("Activates when destroyed"),
--     basePointsGenerated = 3,
--     rarity = lp.rarities.UNIQUE,
-- })
