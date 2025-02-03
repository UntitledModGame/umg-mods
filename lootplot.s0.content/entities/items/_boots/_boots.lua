
--[[
=====================
BOOTS:
=====================

Boots items are related to slots, somehow.


TODO:
Come up with something *emergent* for boots!!!

The old implementation was kinda trash,
because it wasnt emergent.

]]




local loc = localization.localize
local interp = localization.newInterpolator

local consts = require("shared.constants")


local function defBoots(id, name, etype)
    etype.image = etype.image or id
    etype.name = loc(name)

    etype.baseMaxActivations = 4

    return lp.defineItem("lootplot.s0:"..id, etype)
end

