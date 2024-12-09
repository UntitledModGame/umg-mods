
local loc = localization.localize

--[[

PLANNING:
3 types of items:




]]


local function defineTreasure(id, name, description, gen, etype)
    etype = etype or {}

    etype.name = loc(name)

    etype.triggers = {""}
    etype.description = loc()

    lp.defineItem("lootplot.s0.content:" .. id, etype)
end


--[[

=============

TREASURE SACK:
Activates on PULSE: Spawns a random RARE item

FOOD SACK:
Activates on PULSE: Spawns a random FOOD item

========

TODO: think of other types of sacks!!!
We could have a lot more interesting mechanics.

INSPIRATION:
Sack-alfa: gives +10 points to spawned item
Sack-bravo: gives `repeater` to spawned item
Sack-charl: gives REROLL trigger to spawned item
Sack-delta: gives DOOMED-10 to spawned item

OR MAYBE; ALTERNATIVELY:
Sacks should randomly give spawned items properties?
EG:
10% chance to have REROLL trigger
10% chance to be repeater
10% chance to have +10 points

]]














