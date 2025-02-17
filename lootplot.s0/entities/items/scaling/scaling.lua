local loc = localization.localize
local interp = localization.newInterpolator

local helper = require("shared.helper")



local function defItem(id, etype)
    etype.image = etype.image or id

    return lp.defineItem("lootplot.s0:"..id, etype)
end

--[[

TODO::

golden_helmet needs something!!!
Related to money, prefereably.



]]


local function defineHelmet(id, name, etype)
    etype.rarity = etype.rarity or lp.rarities.RARE
    etype.name = loc(name)
    etype.shape = etype.shape or lp.targets.KingShape(1)

    etype.basePrice = etype.basePrice or 10
    etype.baseMaxActivations = etype.baseMaxActivations or 6

    defItem(id,etype)
end





defineHelmet("iron_helmet", "Iron Helmet", {
    activateDescription = loc("Give items {lootplot:POINTS_COLOR}+1 points."),

    triggers = {"PULSE"},

    basePrice = 10,
    baseMaxActivations = 6,
    mineralType = "iron",

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 1, selfEnt)
        end,
    }
})



do
local KNIFE_TRIGGERS = {"PULSE", "REROLL", "ROTATE"}
local KNIFE_ACTIVATIONS = 6
local KNIFE_PRICE = 9

defItem("moon_knife", {
    name = loc("Moon Knife"),
    activateDescription = loc("Gain 2 points permanently"),

    triggers = KNIFE_TRIGGERS,

    basePointsGenerated = -10,
    rarity = lp.rarities.UNCOMMON,

    basePrice = KNIFE_PRICE,

    baseMaxActivations = KNIFE_ACTIVATIONS,

    onActivate = function(ent)
        lp.modifierBuff(ent, "pointsGenerated", 2)
    end
})

defItem("demon_knife", {
    name = loc("Demon Knife"),
    activateDescription = loc("Gain {lootplot:POINTS_MULT_COLOR}+0.1 multiplier{/lootplot:POINTS_MULT_COLOR} permanently"),

    triggers = KNIFE_TRIGGERS,

    baseMultGenerated = -2,
    baseBonusGenerated = -8,
    rarity = lp.rarities.RARE,

    basePrice = KNIFE_PRICE,

    baseMaxActivations = KNIFE_ACTIVATIONS,

    onActivate = function(ent)
        lp.modifierBuff(ent, "multGenerated", 0.1)
    end
})


local BONUS_BUFF = 0.4
defItem("ghost_knife", {
    name = loc("Moon Knife"),
    activateDescription = loc("Gain {lootplot:BONUS_COLOR}+%{buff} bonus{/lootplot:BONUS_COLOR} permanently", {
        buff = BONUS_BUFF
    }),

    triggers = KNIFE_TRIGGERS,

    baseBonusGenerated = -8,
    rarity = lp.rarities.RARE,

    basePrice = KNIFE_PRICE,

    baseMaxActivations = KNIFE_ACTIVATIONS,

    onActivate = function(ent)
        lp.modifierBuff(ent, "bonusGenerated", BONUS_BUFF)
    end
})
end



defineHelmet("ruby_helmet", "Ruby Helmet", {
    activateDescription = loc("Give +1 activations to items.\n(Capped at 20)"),

    triggers = {"PULSE"},

    rarity = lp.rarities.LEGENDARY,

    basePrice = 12,

    mineralType = "ruby",

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            if (targetEnt.maxActivations or 0) < 20 then
                lp.modifierBuff(targetEnt, "maxActivations", 1, selfEnt)
            end
        end,
        filter = function(selfEnt, ppos, targetEnt)
            return (targetEnt.maxActivations or 0) < 20
        end
    },
})



defineHelmet("emerald_helmet", "Emerald Helmet", {
    activateDescription = loc("Give items {lootplot:POINTS_MOD_COLOR}+1 points."),

    triggers = {"REROLL", "PULSE"},

    basePrice = 10,
    baseMaxActivations = 10,
    mineralType = "emerald",

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 1, selfEnt)
        end,
    }
})




defineHelmet("deathly_helmet", "Deathly Helmet", {
    activateDescription = loc("Give items {lootplot:POINTS_MOD_COLOR}+10 points"),

    triggers = {},
    listen = {
        type = "ITEM",
        trigger = "DESTROY",
    },

    basePrice = 10,
    baseMaxActivations = 10,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 10, selfEnt)
        end,
    }
})



local function copy(t)
    local ret = {}
    for k,v in pairs(t) do
        ret[k]=v
    end
    return ret
end


local function defMegaHelmet(id, name, etype)
    etype.shape = etype.shape or lp.targets.RookShape(1)

    etype.basePrice = 12
    etype.baseMaxActivations = 10

    etype.rarity = etype.rarity or lp.rarities.EPIC

    do
    local e2 = copy(etype)
    e2.triggers = {"LEVEL_UP", "UNLOCK"}
    e2.image = id
    defineHelmet(id .. "_v2", name, e2)
    end
end



do
local POINTS_BUFF = 15

defMegaHelmet("mega_points_helmet", "Mega Points Helmet", {
    activateDescription = loc("Adds {lootplot:POINTS_MOD_COLOR}+%{buff} points{/lootplot:POINTS_MOD_COLOR} to items", {
        buff = POINTS_BUFF
    }),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", POINTS_BUFF, selfEnt)
        end
    }
})



local BONUS_BUFF = 1

defMegaHelmet("mega_bonus_helmet", "Mega Bonus Helmet", {
    activateDescription = loc("Adds {lootplot:BONUS_COLOR}+%{buff} bonus{/lootplot:BONUS_COLOR} to items", {
        buff = BONUS_BUFF
    }),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "bonusGenerated", BONUS_BUFF, selfEnt)
        end
    }
})




end