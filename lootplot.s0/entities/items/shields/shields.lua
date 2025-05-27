


--[[

================================
SHIELD ITEMS:
-----------------

The purpose of "Shield items" is to "protect"
against large negative-values.

For example, items like these:
"Sets money to -$20!"
"Lose 10,000 points!"
"Reduce mult by 8!"

Shield-items generally aren't useful UNLESS you have items like these ^^^



NOTE:
wooden-shield, level-shield are in different files.
(activator.lua)

]]

local loc = localization.localize


local SHIELD_WIN_UNLOCK = 2

local function defShield(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    etype.triggers = etype.triggers or {"PULSE"}

    etype.unlockAfterWins = etype.unlockAfterWins or SHIELD_WIN_UNLOCK

    etype.rarity = lp.rarities.RARE
    etype.basePrice = 10

    etype.baseMaxActivations = etype.baseMaxActivations or 4

    return lp.defineItem("lootplot.s0:"..id, etype)
end





defShield("money_shield", "Money Shield", {
    activateDescription = loc("If {lootplot:MONEY_COLOR}money{/lootplot:MONEY_COLOR} is negative, make {lootplot:MONEY_COLOR}money{/lootplot:MONEY_COLOR} positive."),

    onActivate = function(ent)
        local mon = lp.getMoney(ent) or 100
        if mon < 0 then
            lp.setMoney(ent, mon * -1)
        end
    end,

    basePointsGenerated = 10
})




defShield("bonus_shield", "Bonus Shield", {
    activateDescription = loc("If {lootplot:BONUS_COLOR}bonus{/lootplot:BONUS_COLOR} is negative, make {lootplot:BONUS_COLOR}bonus{/lootplot:BONUS_COLOR} positive."),

    onActivate = function(ent)
        local pts = lp.getPointsBonus(ent) or 100
        if pts < 0 then
            lp.setPointsBonus(ent, pts * -1)
        end
    end,
})




defShield("points_shield", "Points Shield", {
    activateDescription = loc("If {lootplot:POINTS_COLOR}points{/lootplot:POINTS_COLOR} is negative, make {lootplot:POINTS_COLOR}points{/lootplot:POINTS_COLOR} positive."),

    onActivate = function(ent)
        local pts = lp.getPoints(ent) or 100
        if pts < 0 then
            lp.setPoints(ent, pts * -1)
        end
    end,
})




defShield("multiplier_shield", "Multiplier Shield", {
    activateDescription = loc("If {lootplot:POINTS_MULT_COLOR}multiplier{/lootplot:POINTS_MULT_COLOR} is negative, make {lootplot:POINTS_MULT_COLOR}multiplier{/lootplot:POINTS_MULT_COLOR} positive.");

    onActivate = function(ent)
        local mult = lp.getPointsMult(ent) or 100
        if mult < 0 then
            lp.setPointsMult(ent, mult * -1)
        end
    end,
})

