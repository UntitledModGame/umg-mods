
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



Tumbling cat:
Same as copycat, but rotates the spawned cat
shape = UP-2



Golden Screw item:
Activates on: ROTATE
Earns $2


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


Screw: 
TODO.

]]


defItem("gear", "Gear", {
    shape = lp.targets.KingShape(1),

    triggers = {"PULSE", "ROTATE"},

    rarity = lp.rarities.LEGENDARY,

    basePrice = 16,
    baseMaxActivations = 4,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.rotateItem(targetEnt, 1)
        end,
        description = loc("Rotate target item")
    }
})




local function defRecord(id, name, etype)
    etype.triggers = {"ROTATE"}

    etype.rarity = lp.rarities.EPIC

    etype.baseMaxActivations = 5
    etype.basePrice = 15

    defItem(id, name, etype)
end




local BLUE_RECORD_BUFF = 20

defRecord("record_blue", "Blue Record", {
    activateDescription = loc("Add {lootplot:POINTS_COLOR}+%{buff} points{/lootplot:POINTS_COLOR} to all {lootplot.targets:COLOR}target items", {
        buff = BLUE_RECORD_BUFF
    }),

    manaCost = 1,

    shape = lp.targets.CircleShape(2),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", BLUE_RECORD_BUFF, selfEnt)
        end
    }
})



local GREEN_RECORD_BUFF = 3

defRecord("record_green", "Green Record", {
    activateDescription = loc("Add {lootplot:POINTS_COLOR}+%{buff} points{/lootplot:POINTS_COLOR} to all {lootplot.targets:COLOR}target items", {
        buff = GREEN_RECORD_BUFF
    }),

    shape = lp.targets.CircleShape(2),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", GREEN_RECORD_BUFF, selfEnt)
        end
    }
})


defRecord("record_red", "Red Record", {
    activateDescription = loc("Add {lootplot:POINTS_MULT_COLOR}+0.1 mult{/lootplot:POINTS_MULT_COLOR} to all {lootplot.targets:COLOR}target items"),

    shape = lp.targets.CircleShape(2),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "multGenerated", 0.1, selfEnt)
        end
    }
})

defItem("record_golden", "Golden Record", {
    triggers = {"ROTATE"},

    baseMoneyGenerated = 3,
    basePrice = 9,

    rarity = lp.rarities.RARE,
})


defItem("spanner", "Spanner", {
    shape = lp.targets.UpShape(4),

    triggers = {"PULSE"},

    rarity = lp.rarities.RARE,

    basePrice = 6,
    baseMaxActivations = 4,

    activateDescription = loc("Rotates {lootplot.targets:COLOR}target items"),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.rotateItem(targetEnt, 1)
        end,
    }
})


--[[

TODO:

white_record
(Something rule-bendy?)

]]





