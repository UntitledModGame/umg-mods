

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
TODO: define these as foods.
]]
defItem("mana_syrup", "Mana Syrup", {
    -- This item is extremely OP btw.
    doomCount = 1,

    rarity = lp.rarities.LEGENDARY,
    basePrice = 12,

    activateDescription = loc("Reduces {lootplot.mana:LIGHT_MANA_COLOR}Mana Cost{/lootplot.mana:LIGHT_MANA_COLOR} of target items by 1.\n(If item has no mana cost, increases by 1!)"),

    shape = lp.targets.UP_SHAPE,
    target = {
        type = "ITEM",
        activate = function(ent, ppos, itemEnt)
            itemEnt.manaCost = (itemEnt.manaCost or 0) - 1
        end,
    }
})

defItem("vial_blue", "Blue Vial", {
    rarity = lp.rarities.RARE,
    doomCount = 1,

    shape = lp.targets.ON_SHAPE,
    target = {
        type = "SLOT",
        activate = function(ent, ppos, slotEnt)
            lp.mana.addMana(slotEnt, 2)
        end,
        description = loc("Gives {lootplot.mana:LIGHT_MANA_COLOR}+2 mana {/lootplot.mana:LIGHT_MANA_COLOR}to slot")
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



defItem("crystal_ball", "Crystal Ball", {
    rarity = lp.rarities.EPIC,
    description = loc("Gives {lootplot.mana:LIGHT_MANA_COLOR}+1 mana{/lootplot.mana:LIGHT_MANA_COLOR} to target slots"),

    canActivateEntity = function(ent)
        return lp.getMoney(ent) < 0
    end,

    grubMoneyCap = 0,

    shape = lp.targets.ON_SHAPE,
    target = {
        type = "SLOT",
        activate = function(ent, ppos, slotEnt)
            lp.mana.addMana(slotEnt, 1)
        end,
    }
})


defItem("mana_heart", "Mana Heart", {
    name = loc("Heart Fruit"),

    rarity = lp.rarities.UNCOMMON,
    shape = lp.targets.UP_SHAPE,

    activateDescription = loc("Gives +1 lives to target items."),

    manaCost = 2,
    basePrice = 12,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.lives = (targetEnt.lives or 0) + 1
        end
    },
})

