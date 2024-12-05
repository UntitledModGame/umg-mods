

local loc = localization.localize

local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)
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


--[[
TODO: define this as a food.
]]
defItem("vial_blue", "Blue Vial", {
    rarity = lp.rarities.RARE,
    doomCount = 1,

    shape = lp.targets.ON_SHAPE,
    target = {
        type = "SLOT",
        activate = function(ent, ppos, slotEnt)
            lp.mana.addMana(slotEnt, 3)
        end,
        description = loc("Gives {lootplot.mana:LIGHT_MANA_COLOR}+3 mana {/lootplot.mana:LIGHT_MANA_COLOR}to slot")
    }
})


defItem("holy_necklace", "Holy necklace", {
    rarity = lp.rarities.RARE,

    baseMoneyGenerated = 4,
    manaCost = 1,
})


defItem("unholy_necklace", "Unholy necklace", {
    rarity = lp.rarities.RARE,

    baseMoneyGenerated = -4,

    shape = lp.targets.ON_SHAPE,
    target = {
        type = "SLOT",
        activate = function(ent, ppos, slotEnt)
            lp.mana.addMana(slotEnt, 1)
        end,
        description = loc("Gives {lootplot.mana:LIGHT_MANA_COLOR}+1 mana{/lootplot.mana:LIGHT_MANA_COLOR} to slot")
    }
})


--[[


Crystal ball:
ON SHAPE
Gives +2 mana if money == 0


Mana heart:
UP SHAPE
Gives +1 lives to item
Uses 1 mana


]]