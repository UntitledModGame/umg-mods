
local helper = require("shared.helper")


local loc = localization.localize


--[[
This gives the user good intuition behind how the
destroy-lives systems interact with each other.
]]
lp.defineItem("lootplot.s0.content:rocks", {
    image = "rocks",
    lootplotProperties = {
        modifiers = {
            -- generates points = 10 * current_level
            pointsGenerated = function(ent)
                local level = lp.getLevel(ent) or 1
                return 10 * level
            end
        },
        multipliers = {
            pointsGenerated = 2
        }
    },
    lives = 1,
    name = loc("Rocks"),
    rarity = lp.rarities.COMMON,
    triggers = {"DESTROY"},
    basePointsGenerated = 0
})



local KEY_DESC = localization.newInterpolator("After %{count} activations, turn into a key")

lp.defineItem("lootplot.s0.content:key_rocks", {
    image = "key_rocks",

    name = loc("Key Rocks"),
    description = function(ent)
        return KEY_DESC({
            count = 20 - (ent.totalActivationCount or 0)
        })
    end,

    rarity = lp.rarities.COMMON,

    onActivate = function(ent)
        if (ent.totalActivationCount or 0) >= 19 then
            local ppos = lp.getPos(ent)
            local etype = server.entities.key
            assert(etype,"?")
            if ppos and etype then
                lp.forceSpawnItem(ppos, etype, ent.lootplotTeam)
            end
        end
    end,

    basePointsGenerated = 3
})


--[[

TODO:
Do something good with the stick

]]
-- lp.defineItem("lootplot.s0.content:stick", {
--     image = "stick",

--     name = loc("Stick"),
--     description = loc("Turns into a boomerang after 3 activations"),

--     rarity = lp.rarities.COMMON,

--     basePointsGenerated = 3,
-- })





local boneDesc = localization.newInterpolator("When destroyed, permanently gain %{count} points-generated")

--[[
This gives the user good intuition behind how the
destroy-lives systems interact with each other.
]]
lp.defineItem("lootplot.s0.content:bone", {
    image = "bone",

    name = loc("Bone"),
    description = function(ent)
        return boneDesc({count = (ent.tier or 1) * 4})
    end,

    rarity = lp.rarities.COMMON,
    basePointsGenerated = 2,

    lives = 1,

    onDestroy = function(ent)
        lp.modifierBuff(ent, "pointsGenerated", 4 * (ent.tier or 1), ent)
    end
})




lp.defineItem("lootplot.s0.content:emerald_shards", {
    image = "emerald_shards",

    name = loc("Emerald Shards"),
    description = loc("When destroyed, reroll everything"),

    rarity = lp.rarities.COMMON,

    basePointsGenerated = 3,

    onDestroy = function(ent)
        local ppos = lp.getPos(ent)
        if ppos then
            helper.rerollPlot(ppos:getPlot())
        end
    end,
})



local activateToot = sound.Sound("trumpet_toot")
local dedToot = sound.Sound("trumpet_destroyed")

lp.defineItem("lootplot.s0.content:trumpet", {
    image = "trumpet",
    name = loc("Trumpet"),
    description = loc("Makes a toot sound"),
    rarity = lp.rarities.COMMON,

    baseMaxActivations = 10,

    basePointsGenerated = 3,
    onActivate = function(ent)
        activateToot:play(ent, 1, 0.5 + math.random())
    end,
    onDestroy = function(ent)
        dedToot:play(ent, 1, 0.5 + math.random())
    end,
})


