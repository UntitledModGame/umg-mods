
local helper = require("shared.helper")
local loc = localization.localize


local function defineMineral(name, etype)
    etype.baseMaxActivations = etype.baseMaxActivations or 10

    etype.tierUpgrade = true

    lp.defineItem(name, etype)
end



local function defineSword(mineral_type, name, basePower, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_sword"
    local image = mineral_type .. "_sword"
    local pgen = basePower * 3

    local swordType = ({
        tierUpgrade = helper.propertyUpgrade("pointsGenerated", pgen, 3),
        basePointsGenerated = pgen,
        image = image,
        name = loc(name .. " Sword"),

        rarity = lp.rarities.UNCOMMON,

        basePrice = 4,
    })
    for k,v in pairs(etype) do
        swordType[k] = swordType[k] or v
    end

    defineMineral(etypeName, swordType)
end




local function definePickaxe(mineral_type, name, basePower, etype)
    --[[
    TODO:
    What should pickaxe do???
    Maybe something to do with scaling? Or "mining"...?
    hmm... 
    ]]
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_pickaxe"
    local image = mineral_type .. "_pickaxe"
    local pgen = basePower

    local pickType = {
        tierUpgrade = helper.propertyUpgrade("pointsGenerated", pgen, 3),
        basePointsGenerated = pgen,
        image = image,
        name = loc(name .. " Pickaxe"),

        rarity = lp.rarities.UNCOMMON,

        basePrice = 4,
    }
    for k,v in pairs(etype) do
        pickType[k] = pickType[k] or v
    end

    defineMineral(etypeName, pickType)
end





local function defineAxe(mineral_type, name, basePower, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_axe"
    local image = mineral_type .. "_axe"

    local axeType = {
        image = image,
        name = loc(name .. " Axe"),

        rarity = lp.rarities.RARE,

        basePrice = 5,
        basePointsGenerated = basePower,

        shape = lp.targets.KNIGHT_SHAPE,

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

    defineMineral(etypeName, axeType)
end



local function definePiece(mineral_type, name)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_piece"
    local image = mineral_type .. "_piece"
    defineMineral(etypeName, {
        name = loc(name .. " Piece"),
        image = image,
        basePointsGenerated = 3,

        onCombine = function(ent, targetItem)
            lp.tiers.upgradeTier(targetItem, ent)
        end,
        canCombine = function(ent, targetItem)
            return ent.mineral
        end
    })
end



local function defineMineralClass(mineral_type, name, basePower, etype)
    defineSword(mineral_type, name, basePower, etype)
    defineAxe(mineral_type, name, basePower, etype)
    -- definePickaxe(mineral_type, name, basePower, etype)

    -- definePiece(mineral_type, name)
end



--[[
"basic" mineral type.
Doesnt do anything special; has decent stats
]]
defineMineralClass("iron", "Iron", 4, {})


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
defineMineralClass("ruby", "Ruby", 2, {
    baseMaxActivations = 4,
    onActivate = function(selfEnt)
        local ppos = lp.getPos(selfEnt)
        if ppos then
            return lp.queueWithEntity(selfEnt, function ()
                lp.tryActivateEntity(selfEnt)
                lp.wait(ppos, 0.2)
            end)
        end
    end
})



--[[
Activates when a target-item is destroyed!!!

defineMineralClass("cobalt", "Cobalt")
]]

