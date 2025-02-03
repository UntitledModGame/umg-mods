
local loc = localization.localize

local function defItem(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)
    return lp.defineItem("lootplot.s0.content:"..id, etype)
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
    activateDescription = loc("Rotate target items"),

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
    shape = lp.targets.UpShape(4),

    triggers = {"PULSE"},

    rarity = lp.rarities.UNCOMMON,

    basePrice = 6,
    baseMoneyGenerated = -1,
    baseMaxActivations = 4,

    activateDescription = loc("Rotates all {lootplot.targets:COLOR}target items"),

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

    rarity = lp.rarities.EPIC,
})


defItem("record_white", "White Record", {
    triggers = RECORD_TRIGGERS,

    baseMultGenerated = 3,
    basePrice = 12,

    rarity = lp.rarities.EPIC,
})



defItem("cd_rom", "CD-ROM", {
    triggers = RECORD_TRIGGERS,

    baseMultGenerated = 10,
    basePointsGenerated = 150,
    baseBonusGenerated = 30,
    basePrice = 12,

    rarity = lp.rarities.LEGENDARY,
})



