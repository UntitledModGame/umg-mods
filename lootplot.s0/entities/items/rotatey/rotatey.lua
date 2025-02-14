
local loc = localization.localize

local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

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

    triggers = {"PULSE", "ROTATE"},

    rarity = lp.rarities.RARE,

    basePrice = 16,
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
    baseMoneyGenerated = -1,
    baseMultGenerated = 2,
    baseMaxActivations = 4,

    activateDescription = loc("Rotates items"),

    shape = lp.targets.UpShape(4),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.rotateItem(targetEnt, 1)
        end,
    }
})




-- On level up:
-- Earn $3. Rotate items.
defItem("bronze_spanner", "Spanner", {
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









local RECORD_TRIGGERS = {"ROTATE", "REROLL"}

local function defRecord(id, name, etype)
    etype.triggers = RECORD_TRIGGERS

    etype.rarity = etype.rarity or lp.rarities.EPIC

    etype.baseMaxActivations = 5
    etype.basePrice = 15

    defItem(id, name, etype)
end



local GREEN_RECORD_BUFF = 2

defRecord("record_green", "Green Record", {
    activateDescription = loc("Add {lootplot:POINTS_COLOR}+%{buff} points{/lootplot:POINTS_COLOR} to items", {
        buff = GREEN_RECORD_BUFF
    }),

    rarity = lp.rarities.RARE,

    shape = lp.targets.CircleShape(2),
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

    shape = lp.targets.CircleShape(2),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "multGenerated", 0.1, selfEnt)
        end
    }
})


defItem("record_blue", "Blue Record", {
    triggers = RECORD_TRIGGERS,
    activateDescription = loc("Add {lootplot:BONUS_COLOR}+1 bonus{/lootplot:BONUS_COLOR} to items"),

    rarity = lp.rarities.EPIC,

    shape = lp.targets.CircleShape(2),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "bonusGenerated", 1, selfEnt)
        end
    }
})



defItem("record_golden", "Golden Record", {
    triggers = RECORD_TRIGGERS,

    baseMoneyGenerated = 3,
    basePrice = 9,

    rarity = lp.rarities.RARE,
})


defItem("record_white", "White Record", {
    triggers = RECORD_TRIGGERS,

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




defItem("dirt_maker", "Dirt Maker", {
    triggers = {"ROTATE"},

    basePrice = 10,
    baseMaxActivations = 10,

    basePointsGenerated = 50,

    activateDescription = loc("Spawns dirt slots."),

    shape = lp.targets.RookShape(2),

    target = {
        type = "NO_SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            lp.trySpawnSlot(ppos, server.entities.dirt_slot, selfEnt.lootplotTeam)
        end,
    },

    rarity = lp.rarities.RARE,
})


