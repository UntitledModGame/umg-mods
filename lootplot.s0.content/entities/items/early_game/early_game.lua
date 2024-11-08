
local loc = localization.localize
local interp = localization.newInterpolator

local helper = require("shared.helper")


local function defItem(id, etype)
    etype.image = etype.image or id

    return lp.defineItem("lootplot.s0.content:"..id, etype)
end




--[[
This gives the user good intuition behind how the
destroy-lives systems interact with each other.
]]
lp.defineItem("lootplot.s0.content:rocks", {
    image = "rocks",

    basePrice = 3,
    basePointsGenerated = 10,

    lives = 1,
    name = loc("Rocks"),
    rarity = lp.rarities.COMMON,
    triggers = {"DESTROY"},
})



local KEY_DESC = localization.newInterpolator("After %{count} activations, turn into a key")

local KEY_BAR_COUNT = 15
lp.defineItem("lootplot.s0.content:key_bar", {
    image = "key_bar",

    name = loc("Key Bar"),
    description = function(ent)
        return KEY_DESC({
            count = KEY_BAR_COUNT - (ent.totalActivationCount or 0)
        })
    end,

    basePrice = 4,
    basePointsGenerated = 3,

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
})




--[[
Purpose of STICK is to give intuition
about how multiple triggers work. (REROLL, PULSE trigger)
]]
lp.defineItem("lootplot.s0.content:stick", {
    image = "stick",
    name = loc("Stick"),

    triggers = {"REROLL", "PULSE"},

    rarity = lp.rarities.COMMON,

    basePointsGenerated = 2,
    basePrice = 3,

    tierUpgrade = helper.propertyUpgrade("pointsGenerated", 2, 3)
})




--[[
TODO: this item seems a bit weird.
But its purpose is to give intuition about the `mult` system.
]]
defItem("leather", {
    name = loc("Leather"),
    description = loc("If has less than $5,\ngain a 5x multiplier"),

    rarity = lp.rarities.COMMON,

    lootplotProperties = {
        multipliers = {
            pointsGenerated = function(ent)
                if (lp.getMoney(ent) or 1000) < 5 then
                    return 5
                end
                return 1
            end
        }
    },

    basePrice = 2,

    baseMaxActivations = 15,

    basePointsGenerated = 4,
    tierUpgrade = helper.propertyUpgrade("pointsGenerated", 4, 3)
})



--[[
purpose is to give intuition about how target-system works
]]
defItem("net", {
    name = loc("Net"),
    triggers = {},

    rarity = lp.rarities.COMMON,

    basePrice = 3,

    listen = {
        trigger = "PULSE"
    },
    shape = lp.targets.KING_SHAPE,

    baseMaxActivations = 3,
    tierUpgrade = helper.propertyUpgrade("maxActivations", 3, 3),

    basePointsGenerated = 1,
})



local COINS_DESC = interp("30% Chance to earn {lootplot:MONEY_COLOR}$%{amount}.\n{wavy}TOTAL EARNED: $%{totalEarned}")
defItem("coins", {
    name = loc("Coins"),
    init = function(ent)
        ent.totalEarned = 0
    end,
    activateDescription = function(ent)
        return COINS_DESC({
            amount = lp.tiers.getTier(ent),
            totalEarned = ent.totalEarned
        })
    end,

    rarity = lp.rarities.COMMON,

    basePointsGenerated = 4,
    basePrice = 4,

    tierUpgrade = {
        description = loc("Gains $1 extra")
    },

    onActivate = function(ent)
        if lp.SEED:randomMisc()<=0.3 then
            local m = lp.tiers.getTier(ent)
            lp.addMoney(ent, m)
            ent.totalEarned = ent.totalEarned + m
            sync.syncComponent(ent, "totalEarned")
        end
    end
})






lp.defineItem("lootplot.s0.content:bone", {
    image = "bone",

    name = loc("Bone"),
    triggers = {"PULSE"},
    activateDescription = loc("Destroys itself and gain 1 life"),

    basePrice = 1,

    lives = 1,
    rarity = lp.rarities.COMMON,
    onActivate = function(selfEnt)
        selfEnt.lives = selfEnt.lives + 1
        lp.destroy(selfEnt)
    end
})





--[[

The purpose of pink-guppy is to make players more aware of
the existance of octopus.

Because in reality, octopus is VERY CENTRAL to the game.

]]
local GUPPY_COUNT = 12
local GUPPY_DESC = interp("After %{count} activations,\nturn into an Octopus")

lp.defineItem("lootplot.s0.content:pink_guppy", {
    image = "pink_guppy",

    name = loc("Pink Guppy"),
    triggers = {"PULSE"},

    description = function(ent)
        return GUPPY_DESC({
            count = GUPPY_COUNT - (ent.totalActivationCount or 0)
        })
    end,

    basePrice = 3,
    basePointsGenerated = 4,

    rarity = lp.rarities.COMMON,

    onActivate = function(ent)
        if (ent.totalActivationCount or 0) >= (GUPPY_COUNT-1) then
            local ppos = lp.getPos(ent)
            local etype = server.entities.pink_octopus
            assert(etype,"?")
            if ppos and etype then
                local item = lp.forceSpawnItem(ppos, etype, ent.lootplotTeam)
                if item then
                    item.tier = ent.tier
                end
            end
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
    activateDescription = loc("Makes a toot sound"),
    rarity = lp.rarities.COMMON,

    baseMaxActivations = 10,
    basePrice = 3,

    basePointsGenerated = 4,
    tierUpgrade = helper.propertyUpgrade("pointsGenerated", 4, 3),

    -- just for the funni
    onActivateClient = function(ent)
        activateToot:play(ent, 0.6, 1 + math.random()/2)
    end,
    onDestroyClient = function(ent)
        dedToot:play(ent, 1, 1 + math.random()/2)
    end,
})


