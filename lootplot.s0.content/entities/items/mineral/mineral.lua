
local loc = localization.localize

--[[

===================================================
Mineral items:
----
Do something basic, (like adds mult, or adds points)
but usually have self-scaling.
===================================================

TODO:
This entire file is overly complex and overly coupled.
Argh!!! stupid. So stupid. 
Please dont take inspiration from this file, its bad.

(At least the complexity is 100% localized)

]]

local function defineMineral(mineralType, name, etype)
    etype.baseMaxActivations = etype.baseMaxActivations or 10
    etype.mineralType = mineralType

    lp.defineItem(name, etype)
end



local function defineSword(mineral_type, name, strength, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_sword"
    local image = mineral_type .. "_sword"

    local swordType = {
        image = image,
        name = loc(name .. " Sword"),

        basePointsGenerated = math.floor(4 * strength),

        rarity = etype.rarity or lp.rarities.UNCOMMON,

        basePrice = 4,
    }
    for k,v in pairs(etype) do
        swordType[k] = swordType[k] or v
    end

    defineMineral(mineral_type, etypeName, swordType)
end


local function floorTo01(x)
    -- floors to nearest 0.1
    return math.floor(x * 10) / 10
end


local function defineSpear(mineral_type, name, strength, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_spear"
    local image = mineral_type .. "_spear"

    local spearType = {
        image = image,
        name = loc(name .. " Spear"),

        baseMultGenerated = floorTo01(0.2 * strength),

        rarity = etype.rarity or lp.rarities.RARE,

        basePrice = 4,
    }
    for k,v in pairs(etype) do
        spearType[k] = v
    end

    defineMineral(mineral_type, etypeName, spearType)
end



local function definePickaxe(mineral_type, name, strength, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_pickaxe"
    local image = mineral_type .. "_pickaxe"

    local pickType = {
        image = image,
        name = loc(name .. " Pickaxe"),

        mineralType = mineral_type,

        basePrice = 4,
        basePointsGenerated = 10,

        doomCount = 30,

        rarity = lp.rarities.RARE,
    }
    for k,v in pairs(etype) do
        pickType[k] = pickType[k] or v
    end

    defineMineral(mineral_type, etypeName, pickType)
end





local function defineAxe(mineral_type, name, strength, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_axe"
    local image = mineral_type .. "_axe"

    local axeType = {
        image = image,
        name = loc(name .. " Axe"),

        mineralType = mineral_type,

        rarity = etype.rarity or lp.rarities.UNCOMMON,

        basePrice = 6,
        basePointsGenerated = math.floor(2 * strength),

        shape = lp.targets.KNIGHT_SHAPE,

        activateDescription = loc("Earn points for every target item."),

        target = {
            type = "ITEM",
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



local function defineHammer(mineral_type, name, strength, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_hammer"
    local image = mineral_type .. "_hammer"

    local hammerType = {
        image = image,
        name = loc(name .. " Hammer"),

        mineralType = mineral_type,

        rarity = etype.rarity or lp.rarities.EPIC,

        basePrice = 10,
        baseMultGenerated = floorTo01(0.1 * strength),

        shape = lp.targets.HorizontalShape(2),

        activateDescription = loc("Gives {lootplot:POINTS_MULT_COLOR}mult{/lootplot:POINTS_MULT_COLOR} for every slot without an item."),

        target = {
            type = "SLOT_NO_ITEM",
            activate = function(selfEnt, ppos, targetEnt)
                lp.addPointsMult(selfEnt, selfEnt.multGenerated or 0)
            end
        }
    }

    for k,v in pairs(etype) do
        hammerType[k] = hammerType[k] or v
    end

    defineMineral(mineral_type, etypeName, hammerType)
end





local function defineMineralClass(mineral_type, name, strength, etype)
    defineSword(mineral_type, name, strength, etype)
    defineAxe(mineral_type, name, strength, etype)
    definePickaxe(mineral_type, name, strength,  etype)
    defineSpear(mineral_type, name, strength,  etype)
    defineHammer(mineral_type, name, strength,  etype)
end



--[[
"basic" mineral type.
Doesnt do anything special; has decent stats
]]
defineMineralClass("iron", "Iron", 2, {
    baseMaxActivations = 10,
    triggers = {"PULSE"}
})


--[[
EMERALD TOOLS:

Activated when rerolled
]]
defineMineralClass("emerald", "Emerald", 4, {
    baseMaxActivations = 10,
    triggers = {"REROLL"}
})



--[[
Activates multiple times, like boomerang.
(anti-synergy with octopus/activator builds!!)
(since octopuses dont matter for ruby-items.)
]]
defineMineralClass("ruby", "Ruby", 1, {
    baseMaxActivations = 5,
    triggers = {"PULSE"},
    repeatActivations = true,
})



--[[

Cobalt costs mana to activate

]]
defineMineralClass("cobalt", "Cobalt", 50, {
    triggers = {"PULSE"},
    manaCost = 1
})


