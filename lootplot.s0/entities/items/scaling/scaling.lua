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



defItem("moon_knife", {
    name = loc("Moon Knife"),
    activateDescription = loc("Gain 2 points permanently"),

    triggers = {"PULSE", "REROLL", "ROTATE"},

    basePointsGenerated = -10,
    rarity = lp.rarities.RARE,

    basePrice = 9,

    baseMaxActivations = 3,

    onActivate = function(ent)
        lp.modifierBuff(ent, "pointsGenerated", 2)
    end
})



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

    etype.rarity = etype.rarity or lp.rarities.RARE

    do
    local e1 = copy(etype)
    e1.baseMoneyGenerated = -8
    e1.triggers = {"PULSE"}
    e1.image = id
    defineHelmet(id .. "_v1", name, e1)
    end

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


local MULT_BUFF = 0.2

defMegaHelmet("mega_mult_helmet", "Mega Multiplier Helmet", {
    activateDescription = loc("Adds {lootplot:POINTS_MULT_COLOR}+%{buff} mult{/lootplot:POINTS_MULT_COLOR} to items", {
        buff = MULT_BUFF
    }),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "multGenerated", MULT_BUFF, selfEnt)
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