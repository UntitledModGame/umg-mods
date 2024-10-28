
local helper = require("shared.helper")
local loc = localization.localize


local function defineMineral(mineralType, name, etype)
    etype.baseMaxActivations = etype.baseMaxActivations or 10

    etype.mineralType = mineralType

    lp.defineItem(name, etype)
end



local function defineSword(mineral_type, name, mineralMult, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_sword"
    local image = mineral_type .. "_sword"
    local pgen = 4

    local swordType = ({
        image = image,
        name = loc(name .. " Sword"),

        lootplotProperties = {
            multipliers = {
                pointsGenerated = mineralMult
            }
        },

        basePointsGenerated = pgen,
        tierUpgrade = helper.propertyUpgrade("pointsGenerated", pgen, 3),

        rarity = lp.rarities.UNCOMMON,

        basePrice = 4,
    })
    for k,v in pairs(etype) do
        swordType[k] = swordType[k] or v
    end

    defineMineral(mineral_type, etypeName, swordType)
end




local function definePickaxe(mineral_type, name, mineralMult, etype)
    --[[
    TODO:
    What should pickaxe do???
    Maybe something to do with scaling? Or "mining"...?
    hmm... 
    ]]
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_pickaxe"
    local image = mineral_type .. "_pickaxe"
    local pgen = 2

    local pickType = {
        image = image,
        name = loc(name .. " Pickaxe"),

        mineralType = mineral_type,
        tierUpgrade = helper.propertyUpgrade("pointsGenerated", pgen, 3),
        basePointsGenerated = pgen,

        rarity = lp.rarities.UNCOMMON,

        basePrice = 4,
    }
    for k,v in pairs(etype) do
        pickType[k] = pickType[k] or v
    end

    defineMineral(mineral_type, etypeName, pickType)
end





local function defineAxe(mineral_type, name, mineralMult, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_axe"
    local image = mineral_type .. "_axe"
    local shape = lp.targets.KNIGHT_SHAPE
    if mineral_type == "cobalt" then
        -- HACK: default shape for cobalt-sword is rook-1.
        -- We make cobalt-axe bigger shape to compensate.
        shape = lp.targets.QueenShape(2)
    end

    local axeType = {
        image = image,
        name = loc(name .. " Axe"),
        mineralType = mineral_type,

        lootplotProperties = {
            multipliers = {
                pointsGenerated = mineralMult / 2
            }
        },

        rarity = lp.rarities.RARE,

        basePrice = 5,
        basePointsGenerated = 2,
        tierUpgrade = helper.propertyUpgrade("pointsGenerated", 2, 3),

        shape = shape,

        target = {
            type = "ITEM",
            description = loc("{lootplot.targets:COLOR}Earn points for every target item."),
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



local function canUpgrade(ent1, ent2)
    return ent1.mineralType
        and ent1.mineralType == ent2.mineralType
        and lp.tiers.getTier(ent1) == lp.tiers.getTier(ent2)
end

local function definePiece(mineral_type, name)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_pieces"
    local image = mineral_type .. "_pieces"
    defineMineral(mineral_type, etypeName, {
        name = loc(name .. " Pieces"),
        image = image,
        description = loc("Can upgrade " .. name .. " tools!"),

        basePointsGenerated = 3,
        tierUpgrade = helper.propertyUpgrade("pointsGenerated", 3, 3),

        mineralType = mineral_type,
        rarity=lp.rarities.COMMON,

        onCombine = function(selfEnt, targetItem)
            if canUpgrade(selfEnt, targetItem) then
                lp.tiers.upgradeTier(targetItem, selfEnt)
            end
        end,
        canCombine = function(selfEnt, targetItem)
            return canUpgrade(selfEnt, targetItem)
        end
    })
end



local function defineMineralClass(mineral_type, name, mineralMult, etype)
    defineSword(mineral_type, name, mineralMult, etype)
    defineAxe(mineral_type, name, mineralMult, etype)
    -- definePickaxe(mineral_type, name, mineralMult, etype)

    definePiece(mineral_type, name)
end



--[[
"basic" mineral type.
Doesnt do anything special; has decent stats
]]
defineMineralClass("iron", "Iron", 1, {
    baseMaxActivations = 15,
})


--[[
Activates on reroll
]]
defineMineralClass("emerald", "Emerald", 1, {
    triggers = {"REROLL"}
})


--[[
Activates multiple times, like boomerang.
(anti-synergy with octopus/activator builds!!)
(since octopuses dont matter for ruby-items.)
]]
defineMineralClass("ruby", "Ruby", 1, {
    baseMaxActivations = 4,
    description = loc("Uses all activations at once!"),
    onActivate = function(selfEnt)
        local ppos = lp.getPos(selfEnt)
        if ppos then
            return lp.queueWithEntity(selfEnt, function ()
                lp.tryActivateEntity(selfEnt)
                lp.wait(ppos, 0.33)
            end)
        end
    end
})



--[[
Activates when a target-item is destroyed!!!

]]
defineMineralClass("cobalt", "Cobalt", 2, {
    shape = lp.targets.RookShape(1),
    triggers = {},
    listen = {
        trigger = "DESTROY"
    }
})



lp.defineItem("lootplot.s0.content:diamond", {
    image = "diamond",
    name = loc("Diamond"),
    description = loc("Can upgrade ANY mineral or tool item"),

    rarity = lp.rarities.EPIC,

    onCombine = function(selfEnt, targetItem)
        if targetItem.mineralType then
            lp.tiers.upgradeTier(targetItem, selfEnt)
        end
    end,
    canCombine = function(selfEnt, targetItem)
        return targetItem.mineralType
    end
})

