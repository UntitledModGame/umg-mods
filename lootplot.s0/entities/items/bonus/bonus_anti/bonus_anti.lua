

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


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)
    return lp.defineItem("lootplot.s0:"..id, etype)
end



do
local ACTIV_BUFF = 2
local BONUS_DEBUFF = 3

defItem("anvil", "Anvil", {
    triggers = {"PULSE"},

    activateDescription = loc("Give items {lootplot:INFO_COLOR}+%{activs} activations{/lootplot:INFO_COLOR}.\nSubtracts {lootplot:BONUS_COLOR}-%{bonus} bonus{/lootplot:BONUS_COLOR} from items.", {
        activs = ACTIV_BUFF,
        bonus = BONUS_DEBUFF
    }),

    basePrice = 8,
    baseMaxActivations = 6,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "bonusGenerated", -BONUS_DEBUFF, selfEnt)
            lp.modifierBuff(targetEnt, "maxActivations", ACTIV_BUFF, selfEnt)
        end
    },
    shape = lp.targets.UnionShape(
        lp.targets.NorthEastShape(1),
        lp.targets.NorthWestShape(1)
    ),

    rarity = lp.rarities.RARE,
})

end




do
local PTS_BUFF = 10

defItem("sapphire", "Sapphire", {
    triggers = {"PULSE"},

    activateDescription = loc("If {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} is negative, gains +%{buff} points", {
        buff = PTS_BUFF,
    }),

    onActivate = function(ent)
        lp.modifierBuff(ent, "pointsGenerated", PTS_BUFF, ent)
    end,

    basePrice = 8,
    basePointsGenerated = 30,
    baseMaxActivations = 4,

    rarity = lp.rarities.RARE,
})

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
    baseMultGenerated = 1,
    baseBonusGenerated = -10,

    lives = 40,

    rarity = lp.rarities.UNCOMMON,
})

