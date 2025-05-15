
local loc = localization.localize
local interp = localization.newInterpolator

local helper = require("shared.helper")
local consts = require("shared.constants")



local function defDestructive(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    etype.lootplotTags = {consts.tags.DESTRUCTIVE}

    etype.isEntityTypeUnlocked = helper.unlockAfterWins(consts.UNLOCK_AFTER_WINS.DESTRUCTIVE)

    if not etype.listen then
        etype.triggers = etype.triggers or {"PULSE"}
    end

    return lp.defineItem("lootplot.s0:"..id, etype)
end


--[[


========================================
DESTRUCTIVE ARCHETYPE REFACTOR:
 --- IMPORTANT NOTES ---
========================================


The new destructive-archetype should not only about destroying items...
But also about *clearing space* of bad items.

For example:

ITEM: 
Spawns manure-items in a KING-1 shape.
(Each manure steals 15 points, and is sticky)
Give +2 mult for every turd that was spawned.

OR, with money:

ITEM: 
Spawns sticky-turds in a UP-3 shape.
Each turd steals $1 when activated.
Earn $3 for every turd that was spawned.

Or alternatively, a more aggressive form:

ITEM:
If there are no target items, give +8 mult.
Then, spawn manure-items in a ROOK-1 shape.
(^^^^ idea is- is that the player will a)


============
ANOTHER IDEA: 
"CONCENTRATION OF FIREPOWER":
============

If there's one item with REALLY good stats; 
IE:
Item: Super rock:
- has 1000 lives
- Earns 190 points

then it would make sense to concentrate all of the "firepower"
on that singular item!
^^^ lean into this, this is a neat idea






-------------------------------

===========
IDEAS FOR NEW DESTRUCTIVE ITEMS:
-------------------------

On target destroyed:
Try spawn a rock item

On target destroyed:
Give 1 mana to slot

On target destroyed:
Try spawn a COIN item:
(Coin: doomed-1, gives $1 when activated)

On Pulse:
(shape: KING)
If target has DESTROY trigger, give it +1 life


----

Golden rock:
When destroyed:
Earn $2


]]


defDestructive("empty_cauldron", "Empty Cauldron", {
    triggers = {"DESTROY"},

    activateDescription = loc("Clones the slot that it is on."),

    rarity = lp.rarities.RARE,
    basePrice = 8,
    baseMaxActivations = 1,

    shape = lp.targets.RookShape(1),

    onActivate = function(ent)
        local posList = lp.targets.getTargets(ent) or {}
        local selfSlot = lp.itemToSlot(ent)
        if not selfSlot then return end

        for _,ppos in ipairs(posList) do
            lp.forceCloneSlot(selfSlot, ppos)
        end
    end,

    target = {
        type = "NO_SLOT",
    }
})


defDestructive("candle", "Candle", {
    rarity = lp.rarities.LEGENDARY,

    activateDescription = loc("Clones the below item into target slots with {lootplot:DOOMED_COLOR}DOOMED-1."),

    basePrice = 15,
    baseMaxActivations = 1,

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "SLOT_NO_ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            local selfPos = lp.getPos(selfEnt)
            if not selfPos then return end
            local downPos = selfPos:move(0,1)
            local itemEnt = downPos and lp.posToItem(downPos)
            if itemEnt then
                local cloneItem = itemEnt:clone()
                cloneItem.doomCount = 1
                local ok = lp.trySetItem(ppos, cloneItem)
                if not ok then
                    cloneItem:delete() --RIP!
                end
            end
        end
    }
})



defDestructive("tooth_necklace", "Tooth Necklace", {
    basePrice = 4,
    baseMaxActivations = 1,

    rarity = lp.rarities.RARE,
    shape = lp.targets.ON_SHAPE,

    activateDescription = loc("Gives slots {lootplot:DOOMED_COLOR}DOOMED-6{/lootplot:DOOMED_COLOR}, and earn {lootplot:MONEY_COLOR}4${/lootplot:MONEY_COLOR} for each slot.\n(Only works if the slot isn't doomed!)"),

    target = {
        type = "SLOT",
        activate = function(ent, ppos, slotEnt)
            lp.addMoney(ent, 4)
            slotEnt.doomCount = 6
        end,
        filter = function(ent, ppos, slotEnt)
            if slotEnt and (not slotEnt.doomCount) then
                return true
            end
        end,
    }
})



-- LONE SWORD ITEMS:
do

defDestructive("water_sword", "Water Sword", {
    basePrice = 12,
    baseMaxActivations = 10,
    baseBonusGenerated = 15,

    rarity = lp.rarities.RARE,
    shape = lp.targets.RookShape(3),

    activateDescription = loc("Destroys items."),

    target = {
        type = "ITEM",
        activate = function(ent, ppos, itemEnt)
            lp.destroy(itemEnt)
        end,
        activateWithNoValidTargets = true
    }
})


defDestructive("lava_sword", "Lava Sword", {
    basePrice = 12,
    baseMaxActivations = 5,
    baseMultGenerated = 1,

    repeatActivations = true,

    rarity = lp.rarities.RARE,
    shape = lp.targets.RookShape(3),

    activateDescription = loc("Destroys items."),

    target = {
        type = "ITEM",
        activate = function(ent, ppos, itemEnt)
            lp.destroy(itemEnt)
        end,
        activateWithNoValidTargets = true
    }
})

end






defDestructive("pink_mitten", "Pink Mitten", {
    shape = lp.targets.KingShape(1),
    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targEnt)
            return lp.hasTrigger(targEnt, "DESTROY")
        end,
        activate = function(selfEnt, ppos, targEnt)
            targEnt.lives = (targEnt.lives or 0) + 1
        end,
    },

    rarity = lp.rarities.RARE,
    baseMultGenerated = 0.6,
    baseMaxActivations = 8,
    basePrice = 4,

    activateDescription = loc("Gives {lootplot:LIFE_COLOR}+1 life{/lootplot:LIFE_COLOR} to items with {lootplot:TRIGGER_COLOR}Destroy{/lootplot:TRIGGER_COLOR} trigger")
})



defDestructive("teddy", "Teddy", {
    listen = {
        type = "SLOT",
        trigger = "DESTROY",
        activate = function(selfEnt, ppos, slotEnt)
            local selfSlot = lp.itemToSlot(selfEnt)
            if selfSlot then
                local cloneSlot = lp.clone(selfSlot)
                lp.setSlot(ppos, cloneSlot)
            end
        end
    },

    activateDescription = loc("Replace destroyed slot with a clone of the slot that the teddy is on."),

    shape = lp.targets.KingShape(1),

    rarity = lp.rarities.RARE,
    basePrice = 8,
    baseMoneyGenerated = -3,
    baseMaxActivations = 30,
})





defDestructive("dark_teddy", "Dark Teddy", {
    shape = lp.targets.KingShape(1),

    listen = {
        type = "ITEM",
        trigger="DESTROY"
    },

    baseMultGenerated = 0.8,
    baseMaxActivations = 30,

    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}Level-Up{/lootplot:TRIGGER_COLOR} on items"),

    target = {
        type = "ITEM",
        filter = function (selfEnt, ppos, itemEnt)
            return lp.hasTrigger(itemEnt, "LEVEL_UP")
        end,
        activate = function(selfEnt, ppos, itemEnt)
            lp.tryTriggerEntity("LEVEL_UP", itemEnt)
        end
    },

    rarity = lp.rarities.EPIC
})






-- TODO:
-- Do something with this.

--[[

defDestructive("dark_skull", "Dark Skull", {
    activateDescription = loc("Spawns rock-items."),

    rarity = lp.rarities.EPIC,

    basePrice = 10,

    shape = lp.targets.RookShape(1),

    target = {
        type = "NO_ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.trySpawnItem(ppos, server.entities.rock, selfEnt.lootplotTeam)
        end
    },
})

]]





defDestructive("skull", "Skull", {
    activateDescription = loc("Destroy items with {lootplot:TRIGGER_COLOR}Destroy{/lootplot:TRIGGER_COLOR} trigger. Trigger {lootplot:TRIGGER_COLOR}Reroll{/lootplot:TRIGGER_COLOR} on items."),

    rarity = lp.rarities.UNCOMMON,

    basePrice = 10,
    baseMaxActivations = 10,

    baseMoneyGenerated = -1,

    shape = lp.targets.RookShape(1),

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targEnt)
            return lp.hasTrigger(targEnt, "REROLL")
                or lp.hasTrigger(targEnt, "DESTROY")
        end,
        activate = function(selfEnt, ppos, targEnt)
            lp.tryTriggerEntity("REROLL", targEnt)

            if lp.hasTrigger(targEnt, "DESTROY") then
                lp.destroy(targEnt)
            end
        end
    },
})



defDestructive("dagger", "Dagger", {
    activateDescription = loc("Destroys target items.\nEarns {lootplot:POINTS_COLOR}90 points{/lootplot:POINTS_COLOR} for each."),

    init = helper.rotateRandomly,

    rarity = lp.rarities.UNCOMMON,

    basePrice = 4,

    shape = lp.targets.UpShape(1),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.destroy(targetEnt)
            lp.addPoints(selfEnt, 90)
        end
    },
})


defDestructive("golden_dagger", "Golden Dagger", {
    activateDescription = loc("Destroys target items.\nEarns {lootplot:MONEY_COLOR}$2{/lootplot:MONEY_COLOR} for each."),

    init = helper.rotateRandomly,

    rarity = lp.rarities.RARE,

    basePrice = 4,
    baseMaxActivations = 2,

    shape = lp.targets.UpShape(1),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.destroy(targetEnt)
            lp.addMoney(selfEnt, 2)
        end
    },
})





defDestructive("unholy_bible", "Unholy Bible", {
    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}Destroy{/lootplot:TRIGGER_COLOR} on all target items.\n(Without actually destroying the items!)"),

    rarity = lp.rarities.LEGENDARY,

    basePrice = 13,

    shape = lp.targets.KingShape(1),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("DESTROY", targetEnt)
        end
    },
})



defDestructive("crimson_leather", "Crimson Leather", {
    activateDescription = loc("Gives {lootplot:POINTS_MULT_COLOR}+0.3 mult{/lootplot:POINTS_MULT_COLOR} to items, and then destroys them"),

    rarity = lp.rarities.RARE,

    basePrice = 9,
    baseMultGenerated = -6,
    baseMaxActivations = 4,

    shape = lp.targets.KingShape(1),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "multGenerated", 0.5, selfEnt)
            lp.destroy(targetEnt)
        end
    },
})



defDestructive("teal_leather", "Teal Leather", {
    activateDescription = loc("Gives {lootplot:BONUS_COLOR}+3 Bonus{/lootplot:BONUS_COLOR} to items, then destroys them"),

    rarity = lp.rarities.RARE,

    basePrice = 9,
    baseBonusGenerated = -30,
    baseMaxActivations = 4,

    shape = lp.targets.KingShape(1),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "bonusGenerated", 3, selfEnt)
            lp.destroy(targetEnt)
        end
    },
})




defDestructive("furnace", "Furnace", {
    triggers = {"REROLL", "PULSE"},

    activateDescription = loc("Convert items into {lootplot:INFO_COLOR}Clone-Rocks{/lootplot:INFO_COLOR}.\nEarn {lootplot:MONEY_COLOR}$1{/lootplot:MONEY_COLOR} for every item that was converted"),

    rarity = lp.rarities.EPIC,

    basePrice = 9,
    baseMaxActivations = 10,

    shape = lp.targets.KingShape(1),

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            return not lp.hasTrigger(targetEnt, "DESTROY")
        end,
        activate = function(selfEnt, ppos, targetEnt)
            local cloneRockEType = assert(server.entities.clone_rocks)
            local ok = lp.forceSpawnItem(ppos, cloneRockEType, selfEnt.lootplotTeam)
            if ok then
                lp.addMoney(selfEnt, 1)
            end
        end
    },
})



local KNUCKLES_EARN = 1

defDestructive("golden_knuckles", "Golden Knuckles", {
    activateDescription = loc("Destroy target item(s), earns {lootplot:MONEY_COLOR}$%{earn} for each", {
        earn = KNUCKLES_EARN
    }),

    rarity = lp.rarities.RARE,

    triggers = {"PULSE"},

    basePrice = 6,
    baseMaxActivations = 4,

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, ent)
            lp.addMoney(selfEnt,KNUCKLES_EARN)
            lp.destroy(ent)
        end,
    }
})



