
local loc = localization.localize
local interp = localization.newInterpolator

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

        activateDescription = loc("Permanently gain {lootplot:POINTS_COLOR}+%{buff} points{/lootplot:POINTS_COLOR} when activated", {
            buff = strength
        }),

        onActivate = function(ent)
            lp.modifierBuff(ent, "pointsGenerated", strength, ent)
        end,

        mineralType = mineral_type,

        basePrice = 12,
        basePointsGenerated = -strength,

        rarity = lp.rarities.RARE,
    }
    for k,v in pairs(etype) do
        pickType[k] = pickType[k] or v
    end

    defineMineral(mineral_type, etypeName, pickType)
end



local AXE_DESC = interp("Earn {lootplot:POINTS_COLOR}%{points} points{/lootplot:POINTS_COLOR} for every target item.")

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

        activateDescription = function(ent)
            return AXE_DESC({
                points = ent.pointsGenerated or 0
            })
        end,

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




local HAMMER_DESC = interp("Destroys a random target item")

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
        baseMultGenerated = floorTo01(0.5 * strength),

        shape = lp.targets.RookShape(1),

        activateDescription = HAMMER_DESC,

        onActivate = function(ent)
            local items = lp.targets.getConvertedTargets(ent)
            local e = table.random(items)
            lp.destroy(e)
        end,

        target = {
            type = "ITEM",
        }
    }

    for k,v in pairs(etype) do
        hammerType[k] = hammerType[k] or v
    end

    defineMineral(mineral_type, etypeName, hammerType)
end



local CROSSBOW_DESC = "Gives {lootplot:POINTS_COLOR}+%{buff} points{/lootplot:POINTS_COLOR} to all target items."

local function defineCrossbow(mineral_type, name, strength, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_crossbow"
    local image = mineral_type .. "_crossbow"

    local buffAmount = math.ceil((strength * 2) ^ 0.5)
    -- arbitrary balancing function. 
    -- Time is a resource, so buffing faster is much stronger.
    -- (As a result, gold/mana crossbows are OP, others are weaker. 
    --  This adjustment seeks to balance that.)
    -- QUESTION: How was this function derived/obtained?
    -- ANSWER: desmos + outta my ass.

    local crossbowType = {
        image = image,
        name = loc(name .. " Crossbow"),

        mineralType = mineral_type,

        rarity = etype.rarity or lp.rarities.RARE,

        basePrice = 12,

        shape = lp.targets.UpShape(2),

        activateDescription = loc(CROSSBOW_DESC, {
            buff = strength
        }),

        target = {
            type = "ITEM",
            activate = function(selfEnt, ppos, targetEnt)
                lp.modifierBuff(targetEnt, "pointsGenerated", buffAmount)
            end
        }
    }

    for k,v in pairs(etype) do
        crossbowType[k] = crossbowType[k] or v
    end

    defineMineral(mineral_type, etypeName, crossbowType)
end





local function defineMineralClass(mineral_type, name, strength, etype)
    defineSword(mineral_type, name, strength, etype)
    defineAxe(mineral_type, name, strength, etype)
    definePickaxe(mineral_type, name, strength,  etype)
    defineSpear(mineral_type, name, strength,  etype)
    defineHammer(mineral_type, name, strength,  etype)
    defineCrossbow(mineral_type, name, strength,  etype)
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
defineMineralClass("cobalt", "Cobalt", 60, {
    triggers = {"PULSE"},
    manaCost = 1,
    baseMaxActivations = 8
})




--[[

Golden items cost $1 to activate

]]
defineMineralClass("golden", "Golden", 15, {
    triggers = {"PULSE"},
    baseMoneyGenerated = -1,
    baseMaxActivations = 8
})




--[[

Sticky items start with `sticky` component

]]
defineMineralClass("sticky", "Sticky", 4, {
    triggers = {"PULSE"},
    sticky = true,
    baseMaxActivations = 8
})


