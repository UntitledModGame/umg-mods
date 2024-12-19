
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

White Record:
When rotated, buff target items, +1 mult

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
    etype.shape = lp.targets.CircleShape(2)

    etype.rarity = lp.rarities.EPIC

    etype.baseMaxActivations = 5
    etype.basePrice = 15

    defItem(id, name, etype)
end


defRecord("record_green", "Green Record", {
    activateDescription = loc("Buff all {lootplot.targets:COLOR}target items{lootplot.targets:COLOR}, +1 mult\n(Maximum of 20 mult)"),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            if targetEnt.pointsGenerated then
                local _, _, mult = properties.computeProperty(targetEnt, "pointsGenerated")
                if mult < 20 then
                    lp.addMultiplierBuff(targetEnt, "pointsGenerated", 1, selfEnt)
                end
            end
        end
    }
})

defRecord("record_blue", "Blue Record", {
    activateDescription = loc("Buff all {lootplot.targets:COLOR}target items{lootplot.targets:COLOR}, +2 points"),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.addMultiplierBuff(targetEnt, "pointsGenerated", 2, selfEnt)
        end
    }
})


--[[
TODO: Is this way too OP?
Probably...
]]
defRecord("record_red", "Red Record", {
    activateDescription = loc("Buff all {lootplot.targets:COLOR}target items{lootplot.targets:COLOR}, +1 activation\n(Maximum of 20 activations)"),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            local maxAct = targetEnt.maxActivations or 0
            if maxAct < 30 then
                lp.addMultiplierBuff(targetEnt, "pointsGenerated", 1, selfEnt)
            end
        end
    }
})

defItem("record_golden", "Golden Record", {
    triggers = {"ROTATE"},
    baseMoneyGenerated = 3
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





