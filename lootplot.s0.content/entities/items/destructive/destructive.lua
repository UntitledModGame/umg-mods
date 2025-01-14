
local loc = localization.localize
local interp = localization.newInterpolator



local function defDestructive(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    if not etype.listen then
        etype.triggers = etype.triggers or {"PULSE"}
    end

    return lp.defineItem("lootplot.s0.content:"..id, etype)
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

    activateDescription = loc("Spawns a SELL slot."),

    rarity = lp.rarities.RARE,
    basePrice = 8,
    baseMaxActivations = 1,

    shape = lp.targets.RookShape(1),

    onActivate = function(ent)
        local posList = lp.targets.getTargets(ent) or {}
        for _,ppos in ipairs(posList) do
            lp.trySpawnSlot(ppos, server.entities.sell_slot, ent.lootplotTeam)
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

    activateDescription = loc("Gives all {lootplot.targets:COLOR}target slots{/lootplot.targets:COLOR} {lootplot:DOOMED_COLOR}DOOMED-6{/lootplot:DOOMED_COLOR}, and earn {lootplot:MONEY_COLOR}4${/lootplot:MONEY_COLOR} for each slot.\n(Only works if the {lootplot.targets:COLOR}slot{/lootplot.targets:COLOR} isn't doomed!)"),

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


defDestructive("mana_necklace", "Mana Necklace", {
    basePrice = 4,
    baseMaxActivations = 1,

    activateDescription = loc("Gives all {lootplot.targets:COLOR}target slots{/lootplot.targets:COLOR} {lootplot:DOOMED_COLOR}DOOMED-6{/lootplot:DOOMED_COLOR}, and {lootplot.mana:LIGHT_MANA_COLOR}+2 mana{/lootplot.mana:LIGHT_MANA_COLOR}.\n(Only works if the {lootplot.targets:COLOR}slot{/lootplot.targets:COLOR} isn't doomed!)"),

    rarity = lp.rarities.RARE,
    shape = lp.targets.ON_SHAPE,

    target = {
        type = "SLOT",
        activate = function(ent, ppos, slotEnt)
            lp.mana.addMana(slotEnt, 2)
            slotEnt.doomCount = 6
        end,
        filter = function(ent, ppos, slotEnt)
            if slotEnt and (not slotEnt.doomCount) then
                return true
            end
        end,
    }
})





defDestructive("bomb", "Bomb", {
    activateDescription = loc("Destroy target slots"),

    rarity = lp.rarities.UNCOMMON,
    doomCount = 1,

    basePrice = 2,
    baseMaxActivations = 1,
    basePointsGenerated = 100,

    shape = lp.targets.UnionShape(
        lp.targets.KingShape(1),
        lp.targets.ON_SHAPE
    ),

    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            -- TODO: Make an explosion animation here...?
            lp.destroy(targetEnt)
        end
    },
})





--[[

TODO: Refactor this item!
It's not interesting.

We can do WAY better, imo.
This item literally doesnt synergize with *anything.*

]]
defDestructive("goblet_of_blood", "Goblet of Blood", {
    rarity = lp.rarities.EPIC,
    doomCount = 10,

    basePointsGenerated = 1,

    activateDescription = loc("Doubles its own points-generated!"),

    basePrice = 8,
    baseMaxActivations = 10,

    listen = {
        trigger = "DESTROY",
        activate = function(selfEnt, ppos, targetEnt)
            local points = selfEnt.pointsGenerated
            lp.modifierBuff(selfEnt, "pointsGenerated", points, selfEnt)
        end,
    },

    shape = lp.targets.LARGE_KING_SHAPE,
})



defDestructive("pink_mitten", "Pink Mitten", {
    onActivate = function(ent)
        ent.lives = (ent.lives or 0) + 1
    end,

    rarity = lp.rarities.RARE,
    basePrice = 1,

    activateDescription = loc("Gains {lootplot:LIFE_COLOR}+1 life{/lootplot:LIFE_COLOR}\n(Maximum of 15)")
})




-- TODO:
-- Do something with this.

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



defDestructive("skull", "Skull", {
    activateDescription = loc("Spawns bone-items."),

    rarity = lp.rarities.RARE,

    basePrice = 6,

    shape = lp.targets.RookShape(1),

    target = {
        type = "NO_ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.trySpawnItem(ppos, server.entities.bone, selfEnt.lootplotTeam)
        end
    },
})



defDestructive("dagger", "Dagger", {
    activateDescription = loc("Destroys target items.\nEarns {lootplot:POINTS_COLOR}30 points{/lootplot:POINTS_COLOR} for each."),

    rarity = lp.rarities.UNCOMMON,

    basePrice = 4,

    shape = lp.targets.UpShape(1),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.destroy(targetEnt)
            lp.addPoints(selfEnt, 30)
        end
    },
})



defDestructive("black_boxing_glove", "Black Boxing Glove", {
    --[[
    TODO:
    This is a terribly designed item

    Make it better!  
    (but also perhaps make it SOMEWHAT similar to red-boxing-glove?)
    ]]
    rarity = lp.rarities.RARE,
    triggers = {"PULSE"},

    activateDescription = loc("Destroys target items. \nEarns {lootplot:POINTS_COLOR}30 points{/lootplot:POINTS_COLOR} for each."),

    repeatActivations = true,

    basePrice = 8,
    baseMaxActivations = 15,

    shape = lp.targets.UpShape(1),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.destroy(targetEnt)
            lp.addPoints(selfEnt, 30)
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



--[[

PINK SHIELD:
Gives lives to target items.

Needs more refining/planning.

"Give {lootplot:LIFE_COLOR}+1 lives{/lootplot:LIFE_COLOR} to all target-items with a {lootplot:TRIGGER_COLOR}Destroy{/lootplot:TRIGGER_COLOR} trigger"

defDestructive("pink_shield", "Pink Shield", {
    activateDescription = loc(" to all non-{lootplot:DOOMED_COLOR}DOOMED{/lootplot:DOOMED_COLOR} target items."),

    shape = lp.targets.KingShape(1),

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            return not targetEnt.doomCount
        end,
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.lives
        end,
    },
})

]]

