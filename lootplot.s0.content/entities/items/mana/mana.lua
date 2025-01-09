

local loc = localization.localize

local helper = require("shared.helper")

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



defItem("mana_goo", "Mana Goo", {
    triggers = {"PULSE"},
    basePrice = 10,
    manaCost = -1,
    baseMaxActivations = 3,
    sticky = true,
    rarity = lp.rarities.RARE
})




local MANA_BAR_DELAY = 6
helper.defineDelayItem("mana_bar", "Mana Bar", {
    delayCount = MANA_BAR_DELAY,
    delayAction = function(ent)
        local slot = lp.itemToSlot(ent)
        if slot then
            lp.mana.addMana(slot, 2)
            lp.destroy(ent)
        end
    end,

    delayDescription = loc("Destroy self, and give {lootplot.mana:LIGHT_MANA_COLOR}+2 mana{/lootplot.mana:LIGHT_MANA_COLOR} to slot."),

    triggers = {"PULSE"},

    basePrice = 4,
    baseMaxActivations = 1,
    basePointsGenerated = 6,

    rarity = lp.rarities.UNCOMMON,
})





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
    },
    triggers = {"PULSE"},
})



defItem("vial_blue", "Blue Vial", {
    activateDescription = loc("Gives {lootplot.mana:LIGHT_MANA_COLOR}+2 mana {/lootplot.mana:LIGHT_MANA_COLOR}to target slot"),

    rarity = lp.rarities.RARE,
    doomCount = 1,

    shape = lp.targets.ON_SHAPE,
    target = {
        type = "SLOT",
        activate = function(ent, ppos, slotEnt)
            lp.mana.addMana(slotEnt, 2)
        end,
    },
    triggers = {"PULSE"},
})



defItem("holy_necklace", "Holy necklace", {
    rarity = lp.rarities.RARE,

    baseMoneyGenerated = 4,
    manaCost = 1,
    triggers = {"PULSE"},
})


defItem("mana_rocks", "Mana Rocks", {
    --[[
    (similar to `rocks` in early-game.)
    ]]
    rarity = lp.rarities.RARE,

    basePrice = 7,
    basePointsGenerated = 30,

    manaCost = -1,
    lives = 2,
    triggers = {"DESTROY"},
})



defItem("unholy_necklace", "Unholy necklace", {
    activateDescription = loc("Gives {lootplot.mana:LIGHT_MANA_COLOR}+1 mana{/lootplot.mana:LIGHT_MANA_COLOR} to target slot"),

    rarity = lp.rarities.RARE,

    baseMoneyGenerated = -4,

    shape = lp.targets.UpShape(1),
    target = {
        type = "SLOT",
        activate = function(ent, ppos, slotEnt)
            lp.mana.addMana(slotEnt, 1)
        end,
    },
    triggers = {"PULSE"},
})



defItem("crystal_ball", "Crystal Ball", {
    rarity = lp.rarities.EPIC,
    activateDescription = loc("Gives {lootplot.mana:LIGHT_MANA_COLOR}+1 mana{/lootplot.mana:LIGHT_MANA_COLOR} to target slots"),

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
    },
    triggers = {"PULSE"},
})


defItem("mana_heart", "Mana Heart", {
    name = loc("Heart Fruit"),
    activateDescription = loc("Gives +1 lives to target items."),

    doomCount = 6,

    rarity = lp.rarities.RARE,
    shape = lp.targets.UP_SHAPE,

    manaCost = 1,
    basePrice = 4,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.lives = (targetEnt.lives or 0) + 1
        end
    },
    triggers = {"PULSE"},
})

