


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



TODO:
We have wooden-shield and broken-shield.

Come up with something for these two items; thanks.
]]

local loc = localization.localize


local function defShield(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    etype.triggers = etype.triggers or {"PULSE"}

    etype.rarity = lp.rarities.RARE
    etype.basePrice = 10

    etype.baseMaxActivations = 4

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



defShield("negative_shield", "Negative Shield", {
    activateDescription = loc("Multiply {lootplot:POINTS_MULT_COLOR}multiplier{/lootplot:POINTS_MULT_COLOR} by -1.5.\nMultply {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR} by -1.5.");

    onActivate = function(ent)
        local mult = lp.getPointsMult(ent) or 1
        lp.setPointsMult(ent, mult * -1.5)

        local bonus = lp.getPointsBonus(ent) or 0
        lp.setPointsBonus(ent, bonus * -1.5)
    end,
})


