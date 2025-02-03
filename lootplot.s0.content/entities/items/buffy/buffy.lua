
--[[

Buffy items:

Items that respond to buffing / scaling.

]]

local loc = localization.localize
local interp = localization.newInterpolator

local helper = require("shared.helper")


local function defItem(id, etype)
    etype.image = etype.image or id
    return lp.defineItem("lootplot.s0:"..id, etype)
end


defItem("blue_knights_helmet", {
    name = "Blue Knight's Helmet",
    triggers = {"PULSE"},
})

