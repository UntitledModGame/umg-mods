

local loc = localization.localize

local function defItem(id, etype)
    etype.image = etype.image or id
    return lp.defineItem("lootplot.s0.content:"..id, etype)
end



--[[

ITEM/SYSTEM IDEAS:


Slot that gains 1 mana when a [RARITY]
item is on top of it.
([RARITY] is chosen randomly!!!)



Item: Adds 2 mana to all target slots
doomCount = 1
(Shape=ON)

Sparkling mana vial:
doomCount = 1
shape = ROOK-1
Gives 1 mana to all target slots
(Costs 1 mana)
(^^^ Whats cool about this item, is that it kinda "spreads" the mana out! And it works with shape too)




Unholy necklace:
Adds 1 mana to all target slots
COST $4 TO ACTIVATE
(Shape=ON)
(^^^^ NOTE: this item is kinda weak without pies/gloves)

Holy necklace
Earns $4
(Costs 1 mana)



Item: Adds 1 mana to all DOOMED target slots
doomCount = 1
(Shape=KING-1)

Item:
Activates on LEVEL_UP
Gives 1 mana to all target-slots
(Shape=KING-1)


Mana syrup: (similar to golden-syrup)
doomCount=1
(Shape=ON)
Decreases manaCost of item by 1
(Can go into negatives!)



===================================================
We need MORE items that USE mana!!!
===================================================

]]
