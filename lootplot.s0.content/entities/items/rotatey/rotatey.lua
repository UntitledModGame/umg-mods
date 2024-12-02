
--[[

Gear:
On PULSE,ROTATE:
Rotates all target items
KING-1


Shuriken:
On PULSE:
Earn points
(When rotated, gain +1 mult)


Tumbling cat:
Same as copycat, but rotates the spawned cat
shape = UP-2



Screw: 
TODO.

]]


local loc = localization.localize

local function defItem(id, etype)
    etype.image = etype.image or id
    return lp.defineItem("lootplot.s0.content:"..id, etype)
end



defItem("gear", {
    shape = lp.targets.KingShape(1),

    triggers = {"PULSE", "ROTATE"},

    baseMaxActivations = 4,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.rotateItem(targetEnt, 1)
        end,
        description = loc("Rotate target item")
    }
})


