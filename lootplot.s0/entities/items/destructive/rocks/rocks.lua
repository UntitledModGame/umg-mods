
local loc = localization.localize
local interp = localization.newInterpolator

local constants = require("shared.constants")
local helper = require("shared.helper")


--[[


Clone rocks: 
Transform into target rocks


Anti-bonus rocks {
    [divides bonus by 2]

    rock (+PULSE): earns 50 pts 
    rock (+REROLL): earns 50 pts
}


Orange rock (+ROTATE):  Earn $0.5, give +50 points



Pro bonus rocks {
    ICE-CUBE: +10 bonus
    diamond: (+PULSE) generates +5 points 10 times
    emerald: (+PULSE) generates +5 points 10 times
}


Grubby rocks, +mult, +points, GRUB-10


Golden rocks: Earns points equal to current balance. +1 mult


Void-rock (+UNLOCK, LEVEL_UP)
(^^^ TODO: Come up with a cool idea for this)


]]

local function defRocks(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    etype.baseMaxActivations = etype.baseMaxActivations or 8
    etype.basePrice = etype.basePrice or 7 -- standard price for rocks

    etype.lootplotTags = {constants.tags.ROCKS}

    etype.unlockAfterWins = constants.UNLOCK_AFTER_WINS.DESTRUCTIVE

    if not etype.listen then
        etype.triggers = etype.triggers or {"DESTROY"}
    end

    return lp.defineItem("lootplot.s0:"..id, etype)
end



defRocks("clone_rocks", "Clone Rocks", {
    triggers = {"PULSE"},

    activateDescription = loc("If item has {lootplot:TRIGGER_COLOR}Destroy{/lootplot:TRIGGER_COLOR} trigger, transform into a clone of it."),

    rarity = lp.rarities.UNCOMMON,
    basePrice = 8,

    shape = lp.targets.RookShape(1),
    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            return lp.hasTrigger(targetEnt, "DESTROY") and targetEnt:type() ~= selfEnt:type()
        end,
        activate = function(selfEnt, ppos, targetEnt)
            local selfPos = lp.getPos(selfEnt)
            if selfPos then
                lp.forceCloneItem(targetEnt, selfPos)
            end
        end
    }
})




--[[
===================================================
Anti-bonus sub-archetype:
===================================================
]]
do
local HALF_BONUS_DESC = loc("Halves the current {lootplot:BONUS_COLOR}Bonus")
local function halfBonus(ent)
    local bonus = lp.getPointsBonus(ent) or 0
    lp.setPointsBonus(ent, bonus/2)
end

defRocks("jagged_rock", "Jagged Rock", {
    triggers = {"DESTROY", "PULSE"},

    activateDescription = HALF_BONUS_DESC,
    onActivate = halfBonus,

    rarity = lp.rarities.RARE,

    basePointsGenerated = 60,

    lives = 300
})


defRocks("alienrock", "Alienrock", {
    triggers = {"DESTROY", "REROLL"},

    activateDescription = HALF_BONUS_DESC,
    onActivate = halfBonus,

    rarity = lp.rarities.RARE,

    basePointsGenerated = 60,

    lives = 300
})


do
local PTS_BUFF = 5

defRocks("sapphire", "Sapphire", {
    triggers = {"DESTROY", "PULSE"},

    activateDescription = loc("If {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} is negative, gains +%{buff} points", {
        buff = PTS_BUFF,
    }),

    onActivate = function(ent)
        local bonus = lp.getPointsBonus(ent)
        if bonus < 0 then
            lp.modifierBuff(ent, "pointsGenerated", PTS_BUFF, ent)
        end
    end,

    basePrice = 8,
    basePointsGenerated = 30,
    baseMaxActivations = 6,

    lives = 100,

    rarity = lp.rarities.RARE,
})

end


end





--[[
===================================================
Pro-bonus sub-archetype:
===================================================
]]
defRocks("ice_cube", "Ice Cube", {
    triggers = {"DESTROY"},
    rarity = lp.rarities.RARE,

    baseBonusGenerated = 15,

    lives = 80
})









--[[
===================================================
Rotate rocks:
===================================================
]]
defRocks("orange_rock", "Orange Rock", {
    triggers = {"DESTROY", "ROTATE"},
    rarity = lp.rarities.RARE,

    basePointsGenerated = 60,
    baseMoneyGenerated = 0.5,

    lives = 120
})





----------------------------
-- GOLDSMITH sub-archetype:
----------------------------

local GOLDEN_ROCK_DESC = interp("Earn multiplier equal to the 10% of the current balance {lootplot:MONEY_COLOR}($%{balance}){/lootplot:MONEY_COLOR}")

defRocks("golden_rock", "Golden Rocks", {
    triggers = {"ROTATE", "DESTROY"},

    rarity = lp.rarities.RARE,

    description = function(ent)
        return GOLDEN_ROCK_DESC({
            balance = math.floor(lp.getMoney(ent) or 0)
        })
    end,

    lootplotProperties = {
        modifiers = {
            multGenerated = function(ent)
                return (lp.getMoney(ent) or 0) * 0.1
            end
        }
    },

    lives = 100,
})










------------------------------------
-- SPECIAL ROCKS / TOMBSTONE ITEMS:
------------------------------------


defRocks("tombstone", "Tombstone", {
    triggers = {"DESTROY", "UNLOCK"},

    activateDescription = loc("{lootplot:TRIGGER_COLOR}Pulses{/lootplot:TRIGGER_COLOR} items 3 times."),

    rarity = lp.rarities.EPIC,

    basePointsGenerated = 100,
    basePrice = 12,

    shape = lp.targets.KingShape(1),
    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            return lp.hasTrigger(targetEnt, "PULSE")
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("PULSE", targetEnt)

            lp.queueWithEntity(targetEnt, function(e)
                lp.tryTriggerEntity("PULSE", e)
            end)
            lp.wait(ppos, 0.2)

            lp.queueWithEntity(targetEnt, function(e)
                lp.tryTriggerEntity("PULSE", e)
            end)
            lp.wait(ppos, 0.2)
        end
    },

    lives = 100,
})


defRocks("dark_rock", "Dark Rock", {
    triggers = {"DESTROY", "PULSE"},

    activateDescription = loc("Destroys items"),

    rarity = lp.rarities.EPIC,

    basePointsGenerated = 200,
    basePrice = 12,
    baseMaxActivations = 6,

    shape = lp.targets.KingShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.destroy(targetEnt)
        end
    },

    lives = 150,
})





--[[
====================================================
Tombs: Give permanent buffs
====================================================
]]
defRocks("red_tomb", "Red Tomb", {
    triggers = {"DESTROY", "LEVEL_UP"},
    rarity = lp.rarities.RARE,

    activateDescription = loc("Gives items {lootplot:POINTS_MULT_COLOR}+0.5 multiplier{/lootplot:POINTS_MULT_COLOR}"),

    shape = lp.targets.RookShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targEnt)
            lp.modifierBuff(targEnt, "multGenerated", 0.5)
        end
    },

    lives = 120
})

defRocks("green_tomb", "Green Tomb", {
    triggers = {"DESTROY", "LEVEL_UP"},
    rarity = lp.rarities.RARE,

    activateDescription = loc("Gives items {lootplot:POINTS_COLOR}+6 points{/lootplot:POINTS_COLOR}"),

    shape = lp.targets.RookShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targEnt)
            lp.modifierBuff(targEnt, "pointsGenerated", 6)
        end
    },

    lives = 120
})


