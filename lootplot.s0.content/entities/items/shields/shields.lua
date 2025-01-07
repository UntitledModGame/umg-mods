


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

]]

local loc = localization.localize


local function defShield(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    etype.triggers = etype.triggers or {"PULSE"}

    etype.rarity = lp.rarities.RARE
    etype.basePrice = 10

    etype.baseMaxActivations = 4

    return lp.defineItem("lootplot.s0.content:"..id, etype)
end




local MONEY_FLOOR = 3

defShield("money_shield", "Money Shield", {
    activateDescription = loc("If money is less than {lootplot:MONEY_COLOR}$%{amount}{/lootplot:MONEY_COLOR}, set money to {lootplot:MONEY_COLOR}$%{amount}", {
        amount = MONEY_FLOOR
    }),

    onActivate = function(ent)
        local mon = lp.getMoney(ent) or 100
        if mon < MONEY_FLOOR then
            lp.setMoney(ent, MONEY_FLOOR)
        end
    end,

    basePointsGenerated = 10
})



local POINTS_FLOOR = 0

defShield("points_shield", "Points Shield", {
    activateDescription = loc("If points are less than {lootplot:POINTS_COLOR}%{amount}{/lootplot:POINTS_COLOR}, set points to {lootplot:POINTS_COLOR}%{amount}", {
        amount = POINTS_FLOOR
    }),

    onActivate = function(ent)
        local mon = lp.getPoints(ent) or 100
        if mon < POINTS_FLOOR then
            lp.setPoints(ent, POINTS_FLOOR)
        end
    end,

    baseMultGenerated = 0.4
})




local MULT_FLOOR = 2

defShield("red_shield", "Red Shield", {
    activateDescription = loc("If multiplier is less than {lootplot:POINTS_MULT_COLOR}%{amount}{/lootplot:POINTS_MULT_COLOR}, set multiplier to {lootplot:POINTS_MULT_COLOR}%{amount}", {
        amount = MULT_FLOOR
    }),

    onActivate = function(ent)
        local mon = lp.getPointsMult(ent) or 100
        if mon < MULT_FLOOR then
            lp.setPointsMult(ent, MULT_FLOOR)
        end
    end,

    basePointsGenerated = 8
})


