

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
local BONUS_DEBUFF = 1

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
    shape = lp.targets.RookShape(1),

    rarity = lp.rarities.RARE,
})

end

