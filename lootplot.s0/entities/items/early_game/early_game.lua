
local loc = localization.localize
local interp = localization.newInterpolator

local helper = require("shared.helper")
local itemGenHelper = require("shared.item_gen_helper")

local constants = require("shared.constants")


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
    description = loc("(Hint: Put this in a sell-slot!)"),

    basePrice = 3,
    baseMultGenerated = 2,

    lives = 10,
    rarity = lp.rarities.UNCOMMON,
    triggers = {"DESTROY"},
})




do
local DARK_BAR_WEIGHTS = itemGenHelper.createRarityWeightAdjuster({
    COMMON = 0.4,
    UNCOMMON = 0.5,
    RARE = 1,
    EPIC = 0.333,
    LEGENDARY = 0.02,
})

local gen = itemGenHelper.createLazyGenerator(function(etype)
    return lp.hasTag(etype, constants.tags.ROCKS) or lp.hasTag(etype, constants.tags.DESTRUCTIVE)
end, DARK_BAR_WEIGHTS)

local NUM_KEY_ACTS = 4
helper.defineDelayItem("dark_bar", "Dark Bar", {
    delayCount = NUM_KEY_ACTS,

    isEntityTypeUnlocked = helper.unlockAfterWins(constants.UNLOCK_AFTER_WINS.DESTRUCTIVE),

    delayDescription = loc("Spawns a random destructive item"),

    delayAction = function(ent)
        local itemType = gen()
        local ppos = lp.getPos(ent)
        if ppos and itemType then
            local etype = server.entities[itemType]
            lp.forceSpawnItem(ppos, etype, ent.lootplotTeam)
        end
    end,

    triggers = {"PULSE"},

    basePrice = 4,
    baseMaxActivations = 4,
    baseMultGenerated = 0.3,

    rarity = lp.rarities.UNCOMMON,
})

end






local NUM_KEY_ACTS = 4
helper.defineTransformItem("key_bar", "Key Bar", {
    transformId = "key",
    transformName = "Key",
    delayCount = NUM_KEY_ACTS,

    triggers = {"PULSE"},

    basePrice = 4,
    baseMaxActivations = 4,
    baseMultGenerated = 0.3,

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

    basePointsGenerated = 10,
    baseBonusGenerated = 2,
    baseMaxActivations = 5,
    basePrice = 2,
})



--[[
Bowl gives +1 bonus,
And pulses item.

Gives intuition about bonus-system, and Reroll-triggers.
]]

defItem("empty_bowl", {
    image = "empty_bowl",
    name = loc("Empty Bowl"),
    triggers = {"PULSE", "REROLL"},

    init = function(ent)
        -- rotate in a random direction.
        lp.rotateItem(ent, math.floor(lp.SEED:randomMisc(0,3)))
    end,

    activateDescription = loc("{lootplot:TRIGGER_COLOR}Pulses{/lootplot:TRIGGER_COLOR} item."),

    baseBonusGenerated = -1,
    baseMaxActivations = 15,
    basePrice = 6,

    rarity = lp.rarities.UNCOMMON,

    shape = lp.targets.UpShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("PULSE", targetEnt)
        end
    },
})





--[[
Boomerang synergizes with BONUS archetype
]]
local BOOMERANG_POINT_ACTIVATION_COUNT = 5
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
            lp.wait(ppos, 0.1)
            lp.queueWithEntity(ent, function(e)
                lp.addPoints(e, BOOMERANG_POINTS)
                lp.incrementCombo(e, 1)
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
        type = "ITEM",
        trigger = "PULSE"
    },
    shape = lp.targets.KING_SHAPE,

    baseMaxActivations = 30,

    basePointsGenerated = 3,
})



defItem("coins", {
    name = loc("Coins"),

    triggers = {"PULSE"},

    basePointsGenerated = 8,
    baseMoneyGenerated = 0.5,
    baseMaxActivations = 2,
    basePrice = 8,

    rarity = lp.rarities.UNCOMMON,
})






defItem("bone", {
    name = loc("Bone"),

    description = loc("(Hint: Put this item in a sell-slot!)"),

    triggers = {"DESTROY"},

    basePrice = 0,
    basePointsGenerated = 20,

    lives = 6,
    rarity = lp.rarities.UNCOMMON,
})






do
local BUFF = 3

defItem("4_leaf_clover", {
    name = loc("4 Leaf Clover"),
    init = helper.rotateRandomly,

    activateDescription = loc("Give items/slots {lootplot:POINTS_COLOR}+%{buff} points", {
        buff = BUFF
    }),

    triggers = {"REROLL"},

    basePrice = 6,
    baseMaxActivations = 10,

    shape = lp.targets.UpShape(1),
    target = {
        type = "ITEM_OR_SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", BUFF, selfEnt)
        end
    },

    rarity = lp.rarities.UNCOMMON,
})

end





local activateToot, dedToot
if client then
    local dirObj = umg.getModFilesystem()
    audio.defineAudioInDirectory(
        dirObj:cloneWithSubpath("entities/items/early_game/sounds"), {"audio:sfx"}, "lootplot.s0:"
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
    baseMultGenerated = 0.2,

    -- just for the funni
    onActivateClient = function(ent)
        activateToot:play(ent, 0.6, 1 + math.random()/2)
    end,
    onDestroyClient = function(ent)
        dedToot:play(ent, 1, 1 + math.random()/2)
    end,
})


