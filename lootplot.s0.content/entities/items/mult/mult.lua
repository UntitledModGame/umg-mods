

--[[

File for items that give global-multipliers.

]]

local loc = localization.localize
local interp = localization.newInterpolator


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)
    return lp.defineItem("lootplot.s0.content:"..id, etype)
end

--[[

Red net:
When target item pulsed:
Give +0.2 mult


Red flag:
Give +mult, (somehow.)
^^^ TODO, PLAN ITEM.


----------------------------------------------------
We need more +mult items!!!
Just, some super basic ones.
----------------------------------------------------


Sponge: 
earn money equal to current multiplier. (Currently: $X)
Then, set mult to -1.


Pin:
Set mult to 1.5


Anchor:
Earn 50 points
Set mult to 1


=== SUPER GOOD IDEA: ===
Have more items that REDUCE the mult.
Items that put mult into negative,
*implicitly synergize with the above items*.



....

todo;
plan others.

...

]]





defItem("red_net", "Red Net", {
    rarity = lp.rarities.RARE,

    basePrice = 5,
    baseMaxActivations = 10,
    baseMultGenerated = 0.1,

    listen = {
        trigger = "PULSE"
    },
    shape = lp.targets.KING_SHAPE,
})



defItem("red_pin", "Red Pin", {
    activateDescription = loc("Set multiplier to {lootplot:POINTS_MULT_COLOR}1.5"),

    rarity = lp.rarities.RARE,

    triggers = {"PULSE"},

    basePrice = 3,
    baseMaxActivations = 3,

    onActivate = function(ent)
        lp.setPointsMult(ent, 1.5)
    end
})



defItem("sponge", "Sponge", {
    triggers = {"PULSE"},

    activateDescription = loc("earn money equal to current multiplier.\nThen, set mult to -1."),

    onActivate = function(ent)
        lp.addMoney(ent, lp.getPointsMult(ent) or 0)
        lp.setPointsMult(ent, -1)
    end,

    rarity = lp.rarities.EPIC,

    basePrice = 10,
    baseMaxActivations = 3,
})



defItem("anchor", "Anchor", {
    activateDescription = loc("Set {lootplot:POINTS_MULT_COLOR}mult{/lootplot:POINTS_MULT_COLOR} to 1"),

    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    basePrice = 7,
    baseMaxActivations = 3,
    basePointsGenerated = 60,

    onActivate = function(ent)
        lp.setPointsMult(ent, 0)
    end
})

