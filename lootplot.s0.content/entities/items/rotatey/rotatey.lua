
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
  Rotate item


On LEVEL_UP:
Rotate all target-items
(CIRCLE-3 SHAPE)


Green Record:
When rotated, buff target items, +5 points

Red Record:
When rotated, buff target items, +1 mult


Upside down helmet item:
If target item has been rotated, buff item +4 points


Slot that rotates items


Screw: 
TODO.

]]


defItem("gear", "Gear", {
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


