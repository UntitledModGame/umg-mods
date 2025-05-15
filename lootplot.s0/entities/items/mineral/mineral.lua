
local loc = localization.localize
local interp = localization.newInterpolator

local helper = require("shared.helper")

local consts = require("shared.constants")

--[[

===================================================
Mineral items:
----
Do something basic, (like adds mult, or adds points)
but usually have self-scaling.
===================================================

]]

local DEFAULT_MAX_ACTIVATIONS = 10

local function defineMineral(mineralType, name, etype)
    etype.baseMaxActivations = etype.baseMaxActivations or DEFAULT_MAX_ACTIVATIONS
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

        basePointsGenerated = math.floor(10 * strength),
        baseBonusGenerated = -1,

        rarity = etype.rarity or lp.rarities.UNCOMMON,

        basePrice = 6,
    }
    for k,v in pairs(etype) do
        swordType[k] = swordType[k] or v
    end

    defineMineral(mineral_type, etypeName, swordType)
end



local function defineGreatsword(mineral_type, name, strength, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_greatsword"
    local image = mineral_type .. "_greatsword"

    local mult = math.max(2, strength)

    local swordType = {
        image = image,
        name = loc(name .. " Great-Sword"),

        description = loc("Comes with a {lootplot:POINTS_MULT_COLOR}%{mult}x points multiplier{/lootplot:POINTS_MULT_COLOR}", {
            mult = mult
        }),

        lootplotProperties = {
            multipliers = {
                pointsGenerated = mult
            }
        },

        basePointsGenerated = 20,

        rarity = etype.rarity or lp.rarities.EPIC,

        basePrice = 18,
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



local SPEAR_PULSE_DESC = loc("{lootplot:TRIGGER_COLOR}Pulses{/lootplot:TRIGGER_COLOR} items.")

local function defineSpear(mineral_type, name, strength, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_spear"
    local image = mineral_type .. "_spear"

    local spearType = {
        image = image,
        name = loc(name .. " Spear"),

        init = helper.rotateRandomly,

        activateDescription = SPEAR_PULSE_DESC,

        baseMultGenerated = floorTo01(0.2 * strength),

        shape = lp.targets.NorthEastShape(1),
        target = {
            type = "ITEM",
            activate = function(selfEnt, ppos, itemEnt)
                lp.tryTriggerEntity("PULSE", itemEnt)
            end,
            filter = function(selfEnt, ppos, itemEnt)
                return lp.hasTrigger(itemEnt, "PULSE")
            end,
            activateWithNoValidTargets = true
        },

        rarity = etype.rarity or lp.rarities.RARE,

        basePrice = 6,
    }
    for k,v in pairs(etype) do
        spearType[k] = v
    end

    defineMineral(mineral_type, etypeName, spearType)
end



local function defineShovel(mineral_type, name, strength, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_shovel"
    local image = mineral_type .. "_shovel"

    local shovelType = {
        image = image,
        name = loc(name .. " Shovel"),

        activateDescription = loc("Permanently gain {lootplot:POINTS_COLOR}+%{buff} points{/lootplot:POINTS_COLOR} when activated", {
            buff = strength
        }),

        onActivate = function(ent)
            lp.modifierBuff(ent, "pointsGenerated", strength, ent)
        end,

        mineralType = mineral_type,

        basePrice = 16,
        basePointsGenerated = -strength,
        baseMaxActivations = (etype.baseMaxActivations or DEFAULT_MAX_ACTIVATIONS) * 3,

        rarity = lp.rarities.EPIC,
    }
    for k,v in pairs(etype) do
        shovelType[k] = shovelType[k] or v
    end

    defineMineral(mineral_type, etypeName, shovelType)
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

        basePrice = 8,
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




local SCYTHE_DESC = interp("Destroys items")

local function defineScythe(mineral_type, name, strength, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_scythe"
    local image = mineral_type .. "_scythe"

    local scytheType = {
        image = image,
        name = loc(name .. " Scythe"),

        mineralType = mineral_type,

        rarity = etype.rarity or lp.rarities.RARE,

        basePrice = 10,
        baseMultGenerated = floorTo01(0.5 * strength),

        shape = lp.targets.RookShape(1),

        activateDescription = SCYTHE_DESC,

        target = {
            type = "ITEM",
            activate = function(selfEnt, ppos, itemEnt)
                lp.destroy(itemEnt)
            end,
            activateWithNoValidTargets = true
        }
    }

    for k,v in pairs(etype) do
        scytheType[k] = scytheType[k] or v
    end

    defineMineral(mineral_type, etypeName, scytheType)
end



local function defineHammer(mineral_type, name, strength, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_hammer"
    local image = mineral_type .. "_hammer"

    local mult = strength + 1

    local hammerType = {
        image = image,
        name = loc(name .. " Hammer"),

        description = loc("If {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} is negative, earn {lootplot:POINTS_MULT_COLOR}%{mult}x points.{/lootplot:POINTS_MULT_COLOR}", {
            mult = mult
        }),

        lootplotProperties = {
            multipliers = {
                pointsGenerated = function(ent)
                    if lp.getPointsBonus(ent) < 0 then
                        return mult
                    end
                    return 1
                end
            }
        },

        basePointsGenerated = 15,

        rarity = etype.rarity or lp.rarities.UNCOMMON,

        basePrice = 12,
    }
    for k,v in pairs(etype) do
        hammerType[k] = v
    end

    defineMineral(mineral_type, etypeName, hammerType)
end





local CROSSBOW_DESC = "Gives {lootplot:POINTS_COLOR}+%{buff} points{/lootplot:POINTS_COLOR} to items."

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

        init = helper.rotateRandomly,

        mineralType = mineral_type,

        rarity = etype.rarity or lp.rarities.RARE,

        basePrice = 16,

        shape = lp.targets.NorthWestShape(2),

        activateDescription = loc(CROSSBOW_DESC, {
            buff = buffAmount
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




local PICKAXE_DESCRIPTION = loc("Destroys items/slots with {lootplot:TRIGGER_COLOR}Destroy{/lootplot:TRIGGER_COLOR} trigger")

local function definePickaxe(mineral_type, name, strength, etype)
    local namespace = umg.getModName() .. ":"
    local etypeName = namespace .. mineral_type .. "_pickaxe"
    local image = mineral_type .. "_pickaxe"

    local etype1 = {
        image = image,
        name = loc(name .. " Pickaxe"),

        isEntityTypeUnlocked = helper.unlockAfterWins(1),

        init = helper.rotateRandomly,

        activateDescription = PICKAXE_DESCRIPTION,

        shape = lp.targets.NorthEastShape(1),
        target = {
            type = "ITEM_OR_SLOT",
            filter = function (ent, ppos, targetEnt)
                return lp.hasTrigger(targetEnt, "DESTROY")
            end,
            activate = function(ent, ppos, targetEnt)
                if lp.hasTrigger(targetEnt, "DESTROY") then
                    lp.destroy(targetEnt)
                end
            end,

            activateWithNoValidTargets = true
        },

        baseBonusGenerated = strength * 2,
        basePrice = 6,

        rarity = etype.rarity or lp.rarities.RARE,
    }
    for k,v in pairs(etype) do
        etype1[k] = v
    end

    defineMineral(mineral_type, etypeName, etype1)
end





local function defineMineralClass(mineral_type, name, strength, etype)
    defineSword(mineral_type, name, strength, etype)
    defineAxe(mineral_type, name, strength, etype)
    definePickaxe(mineral_type, name, strength,  etype)
    defineShovel(mineral_type, name, strength, etype)
    defineSpear(mineral_type, name, strength,  etype)
    defineHammer(mineral_type, name, strength,  etype)
    defineScythe(mineral_type, name, strength,  etype)
    defineCrossbow(mineral_type, name, strength,  etype)
    defineGreatsword(mineral_type, name, strength,  etype)
end



--[[
"basic" mineral type.
Doesnt do anything special; has decent stats
]]
defineMineralClass("iron", "Iron", 3, {
    baseMaxActivations = 10,
    triggers = {"PULSE"}
})


--[[
EMERALD TOOLS:

Activated when rerolled
]]
defineMineralClass("emerald", "Emerald", 2, {
    triggers = {"REROLL"},
    baseMaxActivations = 10,

    isEntityTypeUnlocked = helper.unlockAfterWins(consts.UNLOCK_AFTER_WINS.REROLL),
})



--[[
Activates multiple times, like boomerang.
(anti-synergy with octopus/activator builds!!)
(since octopuses dont matter for ruby-items.)
]]
defineMineralClass("ruby", "Ruby", 2, {
    baseMaxActivations = 3,
    triggers = {"PULSE"},
    repeatActivations = true,
})



--[[

-- Cobalt (does something??)
-- What should this do? originally; it used to cost mana.



defineMineralClass("cobalt", "Cobalt", 6, {
    triggers = {"PULSE"},
    baseMaxActivations = 8
})

]]



--[[

Golden items cost money to activate

]]
defineMineralClass("golden", "Golden", 15, {
    triggers = {"PULSE"},
    baseMoneyGenerated = -2,
    baseMaxActivations = 8
})






local GRUB_MONEY_CAP = assert(consts.DEFAULT_GRUB_MONEY_CAP)

--[[

Grubby items have `grubby` component.
We dont define all of them because we dont wanna bloat item pool.
]]
do
local etype = {
    triggers = {"PULSE"},
    grubMoneyCap = GRUB_MONEY_CAP,
    baseMaxActivations = 8,
    isEntityTypeUnlocked = helper.unlockAfterWins(consts.UNLOCK_AFTER_WINS.GRUBBY),
}

local strength = 6
defineSword("grubby", "Grubby", strength, etype)
-- defineAxe("grubby", "Grubby", strength, etype)
-- defineHammer("grubby", "Grubby", strength,  etype)
defineSpear("grubby", "Grubby", strength, etype)
defineCrossbow("grubby", "Grubby", strength, etype)
defineScythe("grubby", "Grubby", strength,  etype)
end





--[[

Copper-items activate on rotate.

We only defined a few, because:
A) we dont wanna bloat item-pool
B) rotated items make it hard to organize your plot.
    It would feel weird having a rotated-spear, since it activates inconsistently.
]]
do
    local strength = 10
    local etype = {
        triggers = {"ROTATE"},
        baseMaxActivations = 8,

        isEntityTypeUnlocked = helper.unlockAfterWins(consts.UNLOCK_AFTER_WINS.ROTATEY)
    }

    -- defineSword("copper", "Copper", strength, etype)
    -- defineAxe("copper", "Copper", strength, etype)
    -- defineHammer("copper", "Copper", strength,  etype)
    defineScythe("copper", "Copper", strength,  etype)
    defineGreatsword("copper", "Copper", strength,  etype)
end

