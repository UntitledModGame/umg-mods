
local helper = require("shared.helper")


local loc = localization.localize


--[[
This gives the user good intuition behind how the
destroy-lives systems interact with each other.
]]
lp.defineItem("lootplot.s0.content:rocks", {
    image = "rocks",

    basePrice = 3,


    lives = 1,
    name = loc("Rocks"),
    rarity = lp.rarities.COMMON,
    triggers = {"DESTROY"},
    basePointsGenerated = 0
})



local KEY_DESC = localization.newInterpolator("After %{count} activations, turn into a key")

local KEY_BAR_COUNT = 15
lp.defineItem("lootplot.s0.content:key_bar", {
    image = "key_bar",

    name = loc("Key Rocks"),
    description = function(ent)
        return KEY_DESC({
            count = KEY_BAR_COUNT - (ent.totalActivationCount or 0)
        })
    end,

    rarity = lp.rarities.COMMON,

    onActivate = function(ent)
        if (ent.totalActivationCount or 0) >= (KEY_BAR_COUNT-1) then
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






--[[
Purpose of `bone` is to give intuition 
about how the LISTENER system works.
]]
lp.defineItem("lootplot.s0.content:bone", {
    image = "bone",

    name = loc("Bone"),
    triggers = {"PULSE"},
    description = "Destroys itself when activated",

    basePrice = 1,

    lives = 5,
    rarity = lp.rarities.COMMON,
    onActivate = function(selfEnt)
        lp.destroy(selfEnt)
        if (selfEnt.price or 0) > 0.9 then
            lp.modifierBuff(selfEnt, "price", -1, selfEnt)
        end
    end
})




lp.defineItem("lootplot.s0.content:reroll_pearls", {
    image = "reroll_pearls",

    name = loc("Reroll Pearls"),
    description = loc("When destroyed, reroll everything"),

    rarity = lp.rarities.COMMON,

    basePointsGenerated = 3,
    tierUpgrade = helper.propertyUpgrade("pointsGenerated", 3, 3),

    onDestroy = function(ent)
        local ppos = lp.getPos(ent)
        if ppos then
            helper.rerollPlot(ppos:getPlot())
        end
    end,
})




local activateToot, dedToot
if client then
    local dirObj = umg.getModFilesystem()
    audio.defineAudioInDirectory(
        dirObj:cloneWithSubpath("entities/items/early_game/sounds"), "lootplot.s0.content:", {"audio:sfx"}
    )
    activateToot = sound.Sound("lootplot.s0.content:trumpet_toot")
    dedToot = sound.Sound("lootplot.s0.content:trumpet_destroyed")
end

lp.defineItem("lootplot.s0.content:trumpet", {
    image = "trumpet",
    name = loc("Trumpet"),
    description = loc("Makes a toot sound"),
    rarity = lp.rarities.COMMON,

    baseMaxActivations = 10,

    basePointsGenerated = 5,
    tierUpgrade = helper.propertyUpgrade("pointsGenerated", 5, 3),

    -- just for the funni
    onActivateClient = function(ent)
        activateToot:play(ent, 0.6, 1 + math.random()/2)
    end,
    onDestroyClient = function(ent)
        dedToot:play(ent, 1, 1 + math.random()/2)
    end,
})


