
local helper = require("shared.helper")
local loc = localization.localize


local function defineMineral(mineralType, name, etype)
    etype.baseMaxActivations = etype.baseMaxActivations or 10

    etype.mineralType = mineralType

    lp.defineItem(name, etype)
end



local function defineSword(mineral_type, name, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_sword"
    local image = mineral_type .. "_sword"
    local pgen = 4

    local swordType = ({
        image = image,
        name = loc(name .. " Sword"),

        basePointsGenerated = pgen,

        rarity = etype.rarity or lp.rarities.COMMON,

        basePrice = 4,
    })
    for k,v in pairs(etype) do
        swordType[k] = swordType[k] or v
    end

    defineMineral(mineral_type, etypeName, swordType)
end




local function definePickaxe(mineral_type, name, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_pickaxe"
    local image = mineral_type .. "_pickaxe"
    local pgen = 10

    local pickType = {
        image = image,
        name = loc(name .. " Pickaxe"),

        doomCount = 15,

        mineralType = mineral_type,

        basePrice = 4,
        basePointsGenerated = pgen,
        baseMaxActivations = 5,

        rarity = etype.rarity or lp.rarities.UNCOMMON,
    }
    for k,v in pairs(etype) do
        pickType[k] = pickType[k] or v
    end

    defineMineral(mineral_type, etypeName, pickType)
end





local function defineAxe(mineral_type, name, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_axe"
    local image = mineral_type .. "_axe"

    local axeType = {
        image = image,
        name = loc(name .. " Axe"),
        mineralType = mineral_type,

        rarity = etype.rarity or lp.rarities.UNCOMMON,

        basePrice = 5,
        basePointsGenerated = 2,

        shape = lp.targets.KNIGHT_SHAPE,

        target = {
            type = "ITEM",
            description = loc("Earn points for every target item."),
            activate = function(selfEnt, ppos, targetEnt)
                lp.addPoints(selfEnt, selfEnt.pointsGenerated or 0)
            end
        }
    }

    for k,v in pairs(etype) do
        axeType[k] = axeType[k] or v
    end

    defineMineral(mineral_type, etypeName, axeType)
end





local function defineMineralClass(mineral_type, name, etype)
    defineSword(mineral_type, name, etype)
    defineAxe(mineral_type, name, etype)
    definePickaxe(mineral_type, name, etype)
end



--[[
"basic" mineral type.
Doesnt do anything special; has decent stats
]]
defineMineralClass("iron", "Iron", {
    baseMaxActivations = 15,
})


--[[
Activates on reroll
]]
defineMineralClass("emerald", "Emerald", {
    triggers = {"REROLL"}
})


--[[
Activates multiple times, like boomerang.
(anti-synergy with octopus/activator builds!!)
(since octopuses dont matter for ruby-items.)
]]
defineMineralClass("ruby", "Ruby", {
    baseMaxActivations = 3,
    description = loc("Uses all activations at once!"),
    repeatActivations = true
})



--[[

Can be used in BOTH reroll AND 

]]
defineMineralClass("cobalt", "Cobalt", {
    triggers = {"PULSE", "REROLL"},
    rarity = lp.rarities.RARE
})


