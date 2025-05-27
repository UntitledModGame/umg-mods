

--[[

BONUS-ANTI:

----------

Items that work fine with low-bonus,
OR, items that REDUCE bonus.

----------

NOTE:
We already have some anti-bonus items: hammer mineral items.
(see mineral.lua)


=====================
ITEM IDEAS
=====================

ITEM:
Lose 3 bonus
Add 0.4 mult

ITEM:
Lose 3 bonus
Earn 30 points

ITEM:
Buff items +10 points, -1 bonus



]]

local loc = localization.localize
local interp = localization.newInterpolator


local helper = require("shared.helper")



local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    etype.unlockAfterWins = 2

    return lp.defineItem("lootplot.s0:"..id, etype)
end







do
local PTS_BUFF = 15
local BONUS_DEBUFF = 1

defItem("ocarina", "Ocarina", {
    triggers = {"PULSE"},

    activateDescription = loc("Give items {lootplot:POINTS_COLOR}+%{points} points{/lootplot:POINTS_COLOR}.\nSubtracts {lootplot:BONUS_COLOR}-%{bonus} bonus{/lootplot:BONUS_COLOR} from items.", {
        points = PTS_BUFF,
        bonus = BONUS_DEBUFF
    }),

    basePrice = 10,
    baseMaxActivations = 6,
    baseMoneyGenerated = -1,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "bonusGenerated", -BONUS_DEBUFF, selfEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", PTS_BUFF, selfEnt)
        end
    },
    shape = lp.targets.DownShape(2),

    rarity = lp.rarities.RARE,
})

end



local ACTIVATE_IF_NEGATIVE_BONUS_DESC =
loc("(Only works if {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} is negative!)")

local ACTIVATE_IF_NEGATIVE_BONUS = function(ent)
    return (lp.getPointsBonus(ent) or 1) < 0
end


local PULSE_ROTATE_TRIGGER = {"PULSE", "ROTATE"}


defItem("blue_carton", "Blue Carton", {
    triggers = PULSE_ROTATE_TRIGGER,

    activateDescription = ACTIVATE_IF_NEGATIVE_BONUS_DESC,
    canActivate = ACTIVATE_IF_NEGATIVE_BONUS,

    basePrice = 8,
    baseMaxActivations = 6,
    baseBonusGenerated = 20,
    baseMoneyGenerated = 0.5,

    rarity = lp.rarities.RARE,
})



defItem("green_carton", "Green Carton", {
    triggers = PULSE_ROTATE_TRIGGER,

    activateDescription = ACTIVATE_IF_NEGATIVE_BONUS_DESC,
    canActivate = ACTIVATE_IF_NEGATIVE_BONUS,

    basePrice = 8,
    baseMaxActivations = 6,
    basePointsGenerated = 100,
    baseMoneyGenerated = 0.5,

    rarity = lp.rarities.RARE,
})



defItem("red_carton", "Red Carton", {
    triggers = PULSE_ROTATE_TRIGGER,

    activateDescription = ACTIVATE_IF_NEGATIVE_BONUS_DESC,
    canActivate = ACTIVATE_IF_NEGATIVE_BONUS,

    basePrice = 8,
    baseMaxActivations = 6,
    baseMultGenerated = 2.5,
    baseMoneyGenerated = 0.5,

    rarity = lp.rarities.RARE,
})



do
local BUKKE_BASE_MULT = 0.5
local BUKKE_FULL_MULT = 3

defItem("bukkehorn", "Bukkehorn", {
    triggers = {"PULSE"},
    activateDescription = loc("If {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} is negative, earn {lootplot:POINTS_MULT_COLOR}%{fullMult} mult{/lootplot:POINTS_MULT_COLOR} instead", {
        fullMult = BUKKE_FULL_MULT
    }),

    basePrice = 8,
    baseMaxActivations = 6,
    baseMultGenerated = BUKKE_BASE_MULT,

    lootplotProperties = {
        modifiers = {
            multGenerated = function(ent)
                if (lp.getPointsBonus(ent) or 0) < 0 then
                    return (BUKKE_FULL_MULT - BUKKE_BASE_MULT)
                end
                return 0
            end
        }
    },

    rarity = lp.rarities.RARE,
})
end



defItem("flint", "Flint", {
    triggers = {"PULSE", "DESTROY"},

    basePrice = 6,
    baseMaxActivations = 6,
    baseMultGenerated = 2,
    baseBonusGenerated = -10,

    lives = 40,

    rarity = lp.rarities.UNCOMMON,
})



defItem("ouroboros", "Ouroboros", {
    triggers = {"PULSE", "ROTATE"},

    activateDescription = loc("Sets {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} to -10"),

    basePrice = 8,
    baseMaxActivations = 6,
    baseMultGenerated = 1.5,

    onActivate = function(ent)
        lp.setPointsBonus(ent, -10)
    end,

    rarity = lp.rarities.RARE,
})



defItem("interdimensional_shield", "Interdimensional Shield", {
    triggers = {"PULSE"},

    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}Pulse{/lootplot:TRIGGER_COLOR} on items.\nIf {lootplot:BONUS_COLOR}bonus{/lootplot:BONUS_COLOR} is negative, triggers 3 times instead of 1."),

    rarity = lp.rarities.RARE,

    basePrice = 12,
    baseMaxActivations = 2,

    shape = lp.targets.KingShape(1),

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            return lp.hasTrigger(targetEnt, "PULSE")
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("PULSE", targetEnt)
            if lp.getPointsBonus(selfEnt) < 0 then
                lp.tryTriggerEntity("PULSE", targetEnt)
                lp.tryTriggerEntity("PULSE", targetEnt)
            end
        end
    }
})




defItem("crystal_ball", "Crystal Ball", {
    triggers = {"PULSE", "LEVEL_UP"},

    activateDescription = loc("If {lootplot:BONUS_COLOR}bonus{/lootplot:BONUS_COLOR} is negative, buffs items points equal to the {lootplot:BONUS_COLOR}negative bonus.{/lootplot:BONUS_COLOR}"),

    basePrice = 12,
    baseMaxActivations = 2,

    shape = lp.targets.KNIGHT_SHAPE,

    rarity = lp.rarities.EPIC,

    canActivate = ACTIVATE_IF_NEGATIVE_BONUS,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            local bonus = lp.getPointsBonus(selfEnt)
            if bonus < 0 then
                lp.modifierBuff(targetEnt, "pointsGenerated", -bonus)
            end
        end
    },

    doomCount = 15,
})



do
local MAX = 50

defItem("interdimensional_coins", "Interdimensional Coins", {
    triggers = {"PULSE"},

    activateDescription = loc("If {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} is negative, earn {lootplot:MONEY_COLOR}money{/lootplot:MONEY_COLOR} equal to the negative {lootplot:BONUS_COLOR}bonus.{/lootplot:BONUS_COLOR} (Capped at $%{max}!)", {
        max = MAX
    }),

    basePrice = 9,
    baseMaxActivations = 2,

    rarity = lp.rarities.EPIC,

    canActivate = ACTIVATE_IF_NEGATIVE_BONUS,

    onActivate = function(ent)
        local bonus = lp.getPointsBonus(ent)
        if bonus and bonus < 0 then
            local money = math.min(-bonus, MAX)
            lp.addMoney(ent, money)
        end
    end,

    doomCount = 3,
})

end




do

defItem("interdimensional_briefcase", "Interdimensional Briefcase", {
    triggers = {"PULSE"},

    activateDescription = loc("If {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} is negative, earn {lootplot:POINTS_MULT_COLOR}multiplier{/lootplot:POINTS_MULT_COLOR} equal to the negative bonus."),

    basePrice = 9,
    baseMaxActivations = 6,

    rarity = lp.rarities.EPIC,

    canActivate = ACTIVATE_IF_NEGATIVE_BONUS,

    onActivate = function(ent)
        local bonus = lp.getPointsBonus(ent)
        if bonus and bonus < 0 then
            local mult = -bonus
            lp.addPointsMult(ent, mult)
        end
    end,
})

end








defItem("interdimensional_net", "Interdimensional Net", {
    rarity = lp.rarities.UNCOMMON,

    basePrice = 7,
    basePointsGenerated = 60,
    baseBonusGenerated = -2,
    baseMaxActivations = 30,

    listen = {
        type = "ITEM",
        trigger = "PULSE"
    },
    shape = lp.targets.KingShape(1),
})

