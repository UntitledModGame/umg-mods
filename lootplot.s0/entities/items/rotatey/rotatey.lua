
local loc = localization.localize
local constants = require("shared.constants")

local helper = require("shared.helper")


local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    etype.unlockAfterWins = constants.UNLOCK_AFTER_WINS.ROTATEY

    etype.baseMaxActivations = etype.baseMaxActivations or 10

    return lp.defineItem("lootplot.s0:"..id, etype)
end


--[[


Gear:
On PULSE,ROTATE:
Rotates all target items
KING-1


Shuriken:
When rotated, gain +20 points
Activates on: PULSE
Earns points: 5



On item purchased:
Rotate purchased item twice




Blue Record:
When rotated, buff target items, +6 points

Green Record:
When rotated, buff target items, +1 mult (max of 20)

Red Record:
When rotated, buff target items, +1 activations (max of 30)

Gold Record:
When rotated, earn $1 for every slot without an item
shape=ROOK-3


Upside down helmet item:
If target item has been rotated, buff item +4 points


Slot that rotates items
(DONE!)



]]


defItem("gear", "Gear", {
    activateDescription = loc("Rotates items"),

    shape = lp.targets.KingShape(1),

    triggers = {"ROTATE"},

    rarity = lp.rarities.RARE,

    basePrice = 10,
    baseMaxActivations = 4,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.rotateItem(targetEnt, 1)
        end,
    }
})




defItem("spanner", "Spanner", {
    triggers = {"PULSE", "REROLL"},

    rarity = lp.rarities.UNCOMMON,

    basePrice = 6,
    baseMoneyGenerated = -2,
    baseMultGenerated = 2,
    baseMaxActivations = 4,

    activateDescription = loc("Rotates items"),

    shape = lp.targets.UnionShape(
        lp.targets.NorthEastShape(1),
        lp.targets.SouthWestShape(1)
    ),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.rotateItem(targetEnt, 1)
        end,
    }
})




-- On Skip:
-- Earn $3. Rotate items.
defItem("copper_spanner", "Copper Spanner", {
    triggers = {"LEVEL_UP"},

    rarity = lp.rarities.RARE,

    basePrice = 6,
    baseMaxActivations = 4,
    baseMoneyGenerated = 3,

    sticky = true,

    activateDescription = loc("Rotates items"),

    shape = lp.targets.QueenShape(4),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.rotateItem(targetEnt, 1)
        end,
    }
})



do
local NUM_ACT = 4

defItem("copper_plate", "Copper Plate", {
    triggers = {"ROTATE"},

    rarity = lp.rarities.RARE,

    basePrice = 8,
    baseMaxActivations = 3,

    activateDescription = loc("Gives {lootplot:POINTS_MULT_COLOR}+0.2 mult{/lootplot:POINTS_MULT_COLOR} to slot.\nActivates the slot %{n} times", {
        n = NUM_ACT
    }),

    shape = lp.targets.ON_SHAPE,
    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, slotEnt)
            lp.modifierBuff(slotEnt, "multGenerated", 0.2, selfEnt)
            for i=1, NUM_ACT do
                lp.wait(ppos,0.15)
                lp.queueWithEntity(slotEnt, function(e)
                    lp.tryActivateEntity(e)
                end)
            end
        end
    }
})

end






defItem("shuriken", "Shuriken", {
    triggers = {"PULSE", "ROTATE"},

    rarity = lp.rarities.RARE,

    basePrice = 10,
    basePointsGenerated = 5,
    baseMaxActivations = 10,

    onTriggered = function(ent, name)
        if name == "ROTATE" then
            lp.modifierBuff(ent, "pointsGenerated", 5)
        end
    end,

    activateDescription = loc("When rotated, gain {lootplot:POINTS_COLOR}+5 points"),
})



defItem("screw", "Screw", {
    triggers = {"PULSE"},

    rarity = lp.rarities.RARE,

    basePrice = 8,
    baseMaxActivations = 10,

    activateDescription = loc("Rotates items"),

    shape = lp.targets.KNIGHT_SHAPE,
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, itemEnt)
            lp.rotateItem(itemEnt, 1)
        end
    }
})









local function defRecord(id, name, etype)
    etype.rarity = etype.rarity or lp.rarities.EPIC

    etype.triggers = etype.triggers or {"ROTATE"}

    etype.baseMaxActivations = 6
    etype.basePrice = etype.basePrice or 15

    defItem(id, name, etype)
end



local GREEN_RECORD_BUFF = 6

defRecord("record_green", "Green Record", {
    activateDescription = loc("Add {lootplot:POINTS_COLOR}+%{buff} points{/lootplot:POINTS_COLOR} to items", {
        buff = GREEN_RECORD_BUFF
    }),

    rarity = lp.rarities.RARE,

    shape = lp.targets.RookShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", GREEN_RECORD_BUFF, selfEnt)
        end
    }
})


defRecord("record_red", "Red Record", {
    activateDescription = loc("Add {lootplot:POINTS_MULT_COLOR}+0.1 mult{/lootplot:POINTS_MULT_COLOR} to items"),

    rarity = lp.rarities.EPIC,

    shape = lp.targets.RookShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "multGenerated", 0.1, selfEnt)
        end
    }
})


defRecord("record_blue", "Blue Record", {
    activateDescription = loc("Add {lootplot:BONUS_COLOR}+0.5 bonus{/lootplot:BONUS_COLOR} to items"),

    rarity = lp.rarities.EPIC,

    shape = lp.targets.RookShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "bonusGenerated", 0.5, selfEnt)
        end
    }
})



defRecord("record_golden", "Golden Record", {
    baseMoneyGenerated = 2,
    basePrice = 9,

    rarity = lp.rarities.RARE,
})


defRecord("record_white", "White Record", {
    baseMultGenerated = 3,
    basePrice = 12,

    rarity = lp.rarities.RARE,
})



defItem("cd_rom", "CD-ROM", {
    triggers = {"ROTATE"},

    baseMultGenerated = 10,
    basePointsGenerated = 150,
    baseBonusGenerated = 30,
    basePrice = 12,

    rarity = lp.rarities.LEGENDARY,
})




defItem("pumpkin", "Pumpkin", {
    triggers = {"PULSE"},

    basePrice = 10,
    baseMaxActivations = 1,

    activateDescription = loc("If item has {lootplot:TRIGGER_COLOR}Rotate{/lootplot:TRIGGER_COLOR} trigger, transform into a clone of it.\nOtherwise, rotate items."),

    shape = lp.targets.RookShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targEnt)
            if lp.hasTrigger(targEnt, "ROTATE") then
                local selfPos = lp.getPos(selfEnt)
                if selfPos then
                    lp.forceCloneItem(targEnt, selfPos)
                end
            else
                lp.rotateItem(targEnt, 1)
            end
        end,
    },

    rarity = lp.rarities.UNCOMMON,
})




defItem("dirt_maker", "Dirt Maker", {
    triggers = {"ROTATE", "UNLOCK"},

    basePrice = 10,
    baseMaxActivations = 10,

    basePointsGenerated = 50,

    activateDescription = loc("Spawns dirt slots."),

    shape = lp.targets.KNIGHT_SHAPE,

    target = {
        type = "NO_SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            lp.trySpawnSlot(ppos, server.entities.dirt_slot, selfEnt.lootplotTeam)
        end,
    },

    rarity = lp.rarities.RARE,
})













do -- VAULTS:

local function defVault(id, name, etype)
    etype.triggers = etype.triggers or {"ROTATE", "UNLOCK"}

    etype.rarity = etype.rarity or lp.rarities.RARE

    etype.baseMaxActivations = 1
    etype.basePrice = etype.basePrice or 10

    defItem(id, name, etype)
end


local BONUS_BUFF = 4
defVault("blue_vault", "Blue Vault", {
    activateDescription = loc("Give {lootplot:BONUS_COLOR}+%{buff} Bonus{/lootplot:BONUS_COLOR} to slots", {
        buff = BONUS_BUFF
    }),

    doomCount = 15,

    shape = lp.targets.RookShape(1),
    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targEnt)
            lp.modifierBuff(targEnt, "bonusGenerated", BONUS_BUFF, selfEnt)
        end
    }
})


local MULT_BUFF = 0.5
defVault("red_vault", "Red Vault", {
    activateDescription = loc("Give {lootplot:POINTS_MULT_COLOR}+%{buff} Mult{/lootplot:POINTS_MULT_COLOR} to slots", {
        buff = MULT_BUFF
    }),

    doomCount = 15,

    shape = lp.targets.RookShape(1),
    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targEnt)
            lp.modifierBuff(targEnt, "multGenerated", MULT_BUFF, selfEnt)
        end
    }
})


defVault("golden_vault", "Golden Vault", {
    doomCount = 15,
    baseMoneyGenerated = 4,
})


end -- END VAULTS.



