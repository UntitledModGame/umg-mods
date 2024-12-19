

--[[

File for items that give global-multipliers.

]]

local loc = localization.localize


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
Then, set mult to 0.


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




