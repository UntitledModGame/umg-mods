
local loc = localization.localize

--[[

PLANNING:


Treasure chest:
Needs key to unlock (trigger = UNLOCK)
Spawns arbitrary item


Treasure sack:
Activates on PULSE
Spawns arbitrary item


Treasure briefcase:
Activates on PULSE
Spawns arbitrary item

]]




local function defineTreasure(id, name, description, gen, etype)
    etype = etype or {}

    etype.name = loc(name)

    etype.description = etype.description or loc("Transforms into a " .. description)

    lp.defineItem("lootplot.s0.content:" .. id, etype)
end


local function defSack(id, name, description, gen, etype)
    etype.triggers = {"PULSE"}
    etype.basePrice = etype.basePrice or 6
    defineTreasure(id, name, description, gen, etype)
end


local function defChest(id, name, description, gen, etype)
    etype.triggers = {"UNLOCK"}
    etype.basePrice = etype.basePrice or 8
    defineTreasure(id, name, description, gen, etype)
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














