


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





defShield("money_shield", "Money Shield", {
    activateDescription = loc("If money is negative, make money positive."),

    onActivate = function(ent)
        local mon = lp.getMoney(ent) or 100
        if mon < 0 then
            lp.setMoney(ent, mon * -1)
        end
    end,

    basePointsGenerated = 10
})




defShield("points_shield", "Points Shield", {
    activateDescription = loc("If points are negative, make points positive."),

    onActivate = function(ent)
        local pts = lp.getPoints(ent) or 100
        if pts < 0 then
            lp.setPoints(ent, pts * -1)
        end
    end,

    baseMultGenerated = 0.4
})





defShield("red_shield", "Red Shield", {
    activateDescription = loc("If multiplier is negative, make multiplier positive.");

    onActivate = function(ent)
        local mult = lp.getPointsMult(ent) or 100
        if mult < 0 then
            lp.setPointsMult(ent, mult * -1)
        end
    end,

    basePointsGenerated = 8
})


