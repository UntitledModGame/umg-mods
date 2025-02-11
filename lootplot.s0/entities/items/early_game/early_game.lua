
local loc = localization.localize
local interp = localization.newInterpolator

local helper = require("shared.helper")


local function defItem(id, etype)
    etype.image = etype.image or id

    return lp.defineItem("lootplot.s0:"..id, etype)
end




--[[
Rock-items give the user good intuition behind how the
destroy-lives systems interact with each other.
]]
defItem("rocks", {
    name = loc("Rocks"),
    description = loc("(Hint: Put this item in a sell-slot, and watch what happens!)"),

    basePrice = 3,
    basePointsGenerated = 15,

    lives = 1,
    rarity = lp.rarities.UNCOMMON,
    triggers = {"DESTROY"},
})








local NUM_KEY_ACTS = 10
helper.defineTransformItem("key_bar", "Key Bar", {
    transformId = "key",
    transformName = "Key",
    delayCount = NUM_KEY_ACTS,

    triggers = {"PULSE"},

    basePrice = 4,
    baseMaxActivations = 2,
    basePointsGenerated = 5,

    rarity = lp.rarities.UNCOMMON,
})





--[[
Purpose of STICK is to give intuition
about how multiple triggers work. (REROLL, PULSE trigger)
]]
defItem("stick", {
    image = "stick",
    name = loc("Stick"),

    triggers = {"REROLL", "PULSE"},

    rarity = lp.rarities.UNCOMMON,

    basePointsGenerated = 8,
    baseMaxActivations = 5,
    basePrice = 2,
})





--[[
Boomerang synergizes with BONUS archetype
]]
local BOOMERANG_POINT_ACTIVATION_COUNT = 10
local BOOMERANG_POINTS = 1

defItem("boomerang", {
    image = "boomerang",
    name = loc("Boomerang"),
    activateDescription = loc("Earns {lootplot:POINTS_COLOR}+%{points} points{/lootplot:POINTS_COLOR} %{n} times", {
        n = BOOMERANG_POINT_ACTIVATION_COUNT,
        points = BOOMERANG_POINTS
    }),

    triggers = {"PULSE"},

    rarity = lp.rarities.UNCOMMON,

    onActivate = function(ent)
        local ppos=lp.getPos(ent)
        if not ppos then return end

        for i=1, BOOMERANG_POINT_ACTIVATION_COUNT do
            lp.wait(ppos, 0.2)
            lp.queueWithEntity(ent, function(e)
                lp.addPoints(e, BOOMERANG_POINTS)
            end)
        end
    end,

    baseMaxActivations = 8,
    basePrice = 8,
})






--[[
purpose is to give intuition about how target-system works
]]
defItem("blue_net", {
    name = loc("Blue Net"),

    rarity = lp.rarities.UNCOMMON,

    basePrice = 5,

    listen = {
        trigger = "PULSE"
    },
    shape = lp.targets.KING_SHAPE,

    baseMaxActivations = 20,

    basePointsGenerated = 3,
})



local COINS_DESC = interp("20% Chance to earn {lootplot:MONEY_COLOR}$1.\n{wavy}TOTAL EARNED: $%{totalEarned}")
defItem("coins", {
    name = loc("Coins"),
    init = function(ent)
        ent.totalEarned = 0
    end,
    activateDescription = function(ent)
        return COINS_DESC({
            totalEarned = ent.totalEarned
        })
    end,

    rarity = lp.rarities.UNCOMMON,

    basePointsGenerated = 5,
    baseMaxActivations = 2,
    basePrice = 4,

    onActivate = function(ent)
        if lp.SEED:randomMisc()<=0.20 then
            lp.addMoney(ent, 1)
            ent.totalEarned = ent.totalEarned + 1
            sync.syncComponent(ent, "totalEarned")
        end
    end,

    triggers = {"PULSE"},
})






defItem("bone", {
    name = loc("Bone"),

    description = loc("Has 6 lives. (Try selling or destroying this item!)"),

    triggers = {"DESTROY"},

    basePrice = 0,
    basePointsGenerated = 20,

    lives = 6,
    rarity = lp.rarities.UNCOMMON,
})







--[[
TODO: This needs testing!

]]
defItem("4_leaf_clover", {
    name = loc("4 Leaf Clover"),

    triggers = {"REROLL"},

    description = loc("4% chance to turn into a {lootplot:INFO_COLOR} key."),

    basePrice = 6,
    basePointsGenerated = 10,
    baseMaxActivations = 50,

    rarity = lp.rarities.UNCOMMON,

    onActivate = function(ent)
        if lp.SEED:randomMisc() < 0.04 then
            local pos = lp.getPos(ent)
            if pos then
                lp.forceSpawnItem(pos, server.entities.key, ent.lootplotTeam)
            end
        end
    end
})






local activateToot, dedToot
if client then
    local dirObj = umg.getModFilesystem()
    audio.defineAudioInDirectory(
        dirObj:cloneWithSubpath("entities/items/early_game/sounds"), "lootplot.s0:", {"audio:sfx"}
    )
    activateToot = sound.Sound("lootplot.s0:trumpet_toot")
    dedToot = sound.Sound("lootplot.s0:trumpet_destroyed")
end

lp.defineItem("lootplot.s0:trumpet", {
    image = "trumpet",
    name = loc("Trumpet"),
    activateDescription = loc("Makes a toot sound"),
    rarity = lp.rarities.UNCOMMON,

    triggers = {"PULSE"},

    baseMaxActivations = 10,
    basePrice = 5,

    basePointsGenerated = 8,

    -- just for the funni
    onActivateClient = function(ent)
        activateToot:play(ent, 0.6, 1 + math.random()/2)
    end,
    onDestroyClient = function(ent)
        dedToot:play(ent, 1, 1 + math.random()/2)
    end,
})


