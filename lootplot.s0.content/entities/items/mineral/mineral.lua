
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



local MINERAL_TYPES = objects.Enum({
    iron = "iron",
    emerald = "emerald",
    cobalt = "cobalt",
    ruby = "ruby"
})



local TOOL_TYPES = objects.Enum({
    axe = true,
    sword = true,
    pickaxe = true,
    spear = true,
    hammer = true,
})


local SCALING_RATES_BY_MINERAL = {
    emerald = 2,
    iron = 2,
    ruby = 1,
    cobalt = 20,
}


local SCALING_RATES_BY_TOOL = {
    -- points:
    axe = 0.2,
    sword = 1,
    pickaxe = 2,

    -- mult:
    spear = 0.1,
    hammer = 0.05
}


local SCALED_PROPS_BY_TOOL = {
    axe = "pointsGenerated",
    sword = "pointsGenerated",
    pickaxe = "pointsGenerated",

    spear = "multGenerated",
    hammer = "multGenerated"
}


---@param mineralType string
---@param toolType string
---@return number
local function getBuffAmount(mineralType, toolType)
    local toolScaling = assert(SCALING_RATES_BY_TOOL[toolType])
    local mineralScaling = assert(SCALING_RATES_BY_MINERAL[mineralType])
    -- round to nearest 0.1
    return math.floor((toolScaling * mineralScaling) * 10) / 10
end


---@param mineralType string
---@param toolType string
---@return string
local function getBuffDescription(mineralType, toolType)
    local prefix = "When activated, "
    local amount = getBuffAmount(mineralType, toolType)
    local prop = assert(SCALED_PROPS_BY_TOOL[toolType])
    local action
    if prop == "multGenerated" then
        action = "permanently gain {lootplot:POINTS_MULT_COLOR}%{amount} mult."
    elseif prop == "pointsGenerated" then
        action = "permanently gain {lootplot:POINTS_COLOR}%{amount} points."
    else
        umg.melt("?")
    end
    return loc(prefix .. action, {
        amount = amount
    })
end


local function scale(ent, mineralType, toolType)
    local prop = assert(SCALED_PROPS_BY_TOOL[toolType])
    lp.modifierBuff(ent, prop, getBuffAmount(mineralType, toolType))
end

local function addScalingToEtype(etype, mineralType, toolType)
    if mineralType == MINERAL_TYPES.ruby
        or mineralType == MINERAL_TYPES.iron
            or mineralType == MINERAL_TYPES.emerald then
        -- ruby and iron scale the same:
        etype.onActivate = function(ent)
            scale(ent, mineralType, toolType)
        end
    elseif mineralType == MINERAL_TYPES.cobalt then
        -- cobalt costs mana:
        etype.onActivate = function(ent)
            local slotEnt = lp.itemToSlot(ent)
            if slotEnt and lp.mana.getManaCount(slotEnt) >= 1 then
                lp.mana.addMana(slotEnt,-1)
                scale(ent, mineralType, toolType)
            end
        end
    else
        umg.melt("you gotta put stuff here!")
    end

    etype.description = getBuffDescription(mineralType, toolType)
end



local function defineSword(mineral_type, name, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_sword"
    local image = mineral_type .. "_sword"
    local pgen = 4

    local swordType = {
        image = image,
        name = loc(name .. " Sword"),

        basePointsGenerated = pgen,

        rarity = etype.rarity or lp.rarities.UNCOMMON,

        basePrice = 4,
    }
    for k,v in pairs(etype) do
        swordType[k] = swordType[k] or v
    end
    addScalingToEtype(swordType, mineral_type, TOOL_TYPES.sword)

    defineMineral(mineral_type, etypeName, swordType)
end



local function defineSpear(mineral_type, name, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_spear"
    local image = mineral_type .. "_spear"

    local spearType = {
        image = image,
        name = loc(name .. " Spear"),

        baseMultGenerated = 0.2,

        rarity = etype.rarity or lp.rarities.RARE,

        basePrice = 4,
    }
    for k,v in pairs(etype) do
        spearType[k] = v
    end
    addScalingToEtype(spearType, mineral_type, TOOL_TYPES.spear)

    defineMineral(mineral_type, etypeName, spearType)
end



local function definePickaxe(mineral_type, name, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_pickaxe"
    local image = mineral_type .. "_pickaxe"
    local pgen = 10

    local pickType = {
        image = image,
        name = loc(name .. " Pickaxe"),

        mineralType = mineral_type,

        basePrice = 4,
        basePointsGenerated = pgen,

        rarity = lp.rarities.RARE,
    }
    for k,v in pairs(etype) do
        pickType[k] = pickType[k] or v
    end
    addScalingToEtype(pickType, mineral_type, TOOL_TYPES.pickaxe)

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

    addScalingToEtype(axeType, mineral_type, TOOL_TYPES.axe)

    defineMineral(mineral_type, etypeName, axeType)
end





local function defineMineralClass(mineral_type, name, etype)
    defineSword(mineral_type, name, etype)
    defineAxe(mineral_type, name, etype)
    definePickaxe(mineral_type, name, etype)
    defineSpear(mineral_type, name, etype)
end



--[[
"basic" mineral type.
Doesnt do anything special; has decent stats
]]
defineMineralClass("iron", "Iron", {
    baseMaxActivations = 10,
    triggers = {"PULSE"}
})


--[[
Activates on reroll
]]
defineMineralClass("emerald", "Emerald", {
    baseMaxActivations = 10,
    triggers = {"PULSE", "REROLL"}
})


--[[
Activates multiple times, like boomerang.
(anti-synergy with octopus/activator builds!!)
(since octopuses dont matter for ruby-items.)
]]
defineMineralClass("ruby", "Ruby", {
    baseMaxActivations = 4,
    triggers = {"PULSE"},
    repeatActivations = true,
})



defineMineralClass("cobalt", "Cobalt", {
    triggers = {"PULSE"},
})


