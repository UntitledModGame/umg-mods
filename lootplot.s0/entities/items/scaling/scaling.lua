local loc = localization.localize
local interp = localization.newInterpolator

local helper = require("shared.helper")



local function defItem(id, etype)
    etype.image = etype.image or id

    return lp.defineItem("lootplot.s0:"..id, etype)
end

--[[

TODO::

golden_helmet needs something!!!
Related to money, prefereably.



]]


local function defineHelmet(id, etype)
    etype.rarity = etype.rarity or lp.rarities.RARE
    etype.shape = etype.shape or lp.targets.KingShape(1)

    etype.basePrice = etype.basePrice or 10
    etype.baseMaxActivations = etype.baseMaxActivations or 6

    defItem(id,etype)
end





defineHelmet("iron_helmet", {
    name = loc("Iron Helmet"),
    activateDescription = interp("Give all target items {lootplot:POINTS_COLOR}+2 points."),

    triggers = {"PULSE"},

    basePrice = 10,
    mineralType = "iron",

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 2, selfEnt)
        end,
    }
})



defItem("moon_knife", {
    name = loc("Moon Knife"),
    activateDescription = loc("Gain 2 points permanently"),

    triggers = {"PULSE", "REROLL", "ROTATE"},

    basePointsGenerated = -10,
    rarity = lp.rarities.RARE,

    basePrice = 9,

    baseMaxActivations = 3,

    onActivate = function(ent)
        lp.modifierBuff(ent, "pointsGenerated", 2)
    end
})



defineHelmet("ruby_helmet", {
    name = loc("Ruby Helmet"),
    activateDescription = loc("Give +1 activations to all target items.\n(Capped at 20)"),

    triggers = {"PULSE"},

    rarity = lp.rarities.LEGENDARY,

    basePrice = 12,

    mineralType = "ruby",

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            if (targetEnt.maxActivations or 0) < 20 then
                lp.modifierBuff(targetEnt, "maxActivations", 1, selfEnt)
            end
        end,
        filter = function(selfEnt, ppos, targetEnt)
            return (targetEnt.maxActivations or 0) < 20
        end
    },
})



defineHelmet("emerald_helmet", {
    name = loc("Emerald Helmet"),
    activateDescription = loc("Give target items {lootplot:POINTS_MOD_COLOR}+1 points."),

    triggers = {"REROLL", "PULSE"},

    basePrice = 10,
    mineralType = "emerald",

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 1, selfEnt)
        end,
    }
})


defineHelmet("doom_helmet", {
    name = loc("Doom Helmet"),

    triggers = {"PULSE"},

    activateDescription = loc("Give all targetted items on {lootplot:DOOMED_COLOR}DOOMED{/lootplot:DOOMED_COLOR} slots {lootplot:POINTS_MOD_COLOR}+3 points."),

    basePrice = 14,

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targItem)
            local slotEnt = lp.posToSlot(ppos)
            return slotEnt and slotEnt.doomCount
        end,
        activate = function (selfEnt, ppos, targItem)
            lp.modifierBuff(targItem, "pointsGenerated", 3, selfEnt)
        end
    },

    rarity = lp.rarities.EPIC,
})


defineHelmet("demon_helmet", {
    name = loc("Demon Helmet"),

    activateDescription = loc("Give all target {lootplot:REPEATER_COLOR}REPEATER{/lootplot:REPEATER_COLOR} items {lootplot:POINTS_MOD_COLOR}+4 points"),
    triggers = {"PULSE"},

    basePrice = 12,

    repeatActivations = true,
    baseMaxActivations = 1,

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targItem)
            return targItem.repeatActivations
        end,
        activate = function (selfEnt, ppos, targItem)
            lp.modifierBuff(targItem, "pointsGenerated", 10, selfEnt)
        end
    },

    rarity = lp.rarities.EPIC,
})




--[[

NEW ITEM IDEAS:




Sticky helmet:
Give all STICKY items +6 points




]]
