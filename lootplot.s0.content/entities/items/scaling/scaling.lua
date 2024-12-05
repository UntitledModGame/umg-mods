local loc = localization.localize
local interp = localization.newInterpolator

local helper = require("shared.helper")



local function defItem(id, etype)
    etype.image = etype.image or id

    return lp.defineItem("lootplot.s0.content:"..id, etype)
end


local function defineHelmet(id, etype)
    etype.rarity = etype.rarity or lp.rarities.RARE
    etype.shape = etype.shape or lp.targets.KingShape(1)

    etype.basePrice = etype.basePrice or 10
    etype.baseMaxActivations = etype.baseMaxActivations or 1

    defItem(id,etype)
end





defineHelmet("iron_helmet", {
    name = loc("Iron Helmet"),

    triggers = {"PULSE"},

    basePrice = 10,
    mineralType = "iron",

    target = {
        type = "ITEM",
        description = interp("Buff all target items: +2 points."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 2, selfEnt)
        end,
    }
})



defItem("moon_knife", {
    name = loc("Moon Knife"),
    activateDescription = loc("Gain 1 point permanently"),

    triggers = {"PULSE"},

    basePointsGenerated = -10,
    rarity = lp.rarities.UNCOMMON,

    basePrice = 9,

    baseMaxActivations = 3,

    onActivate = function(ent)
        lp.modifierBuff(ent, "pointsGenerated", 1)
    end
})



defineHelmet("ruby_helmet", {
    name = loc("Ruby Helmet"),

    triggers = {"PULSE"},

    basePrice = 12,

    mineralType = "ruby",

    target = {
        type = "ITEM",
        description = loc("Buff all target items:\n+1 activations. (Capped at 20)"),
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



local function hasRerollTrigger(ent)
    if ent.triggers then
        for _,t in ipairs(ent.triggers) do
            if t == "REROLL" then
                return true
            end
        end
    end
    return false
end

defineHelmet("emerald_helmet", {
    name = loc("Emerald Helmet"),

    triggers = {"REROLL"},

    basePrice = 10,
    mineralType = "emerald",

    target = {
        type = "ITEM",
        description = loc("If target has {lootplot:TRIGGER_COLOR}REROLL trigger{/lootplot:TRIGGER_COLOR}, buff target {lootplot:POINTS_MOD_COLOR}+5 points."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 5, selfEnt)
        end,
        filter = function(selfEnt, ppos, targetEnt)
            return hasRerollTrigger(targetEnt)
        end
    }
})


defineHelmet("doom_helmet", {
    name = loc("Doom Helmet"),

    triggers = {"PULSE"},

    basePrice = 14,
    basePointsGenerated = 1,

    target = {
        type = "ITEM",
        description = loc("If item is DOOMED, buff item +10 points"),
        filter = function(selfEnt, ppos, targItem)
            return targItem.doomCount
        end,
        activate = function (selfEnt, ppos, targItem)
            lp.modifierBuff(targItem, "pointsGenerated", 10, selfEnt)
        end
    },

    rarity = lp.rarities.EPIC,
})



defItem("skull", {
    name = loc("Skull"),

    activateDescription = interp("Permanently gains {lootplot:POINTS_MOD_COLOR}+6 Points-Generated"),

    listen = {
        trigger = "DESTROY"
    },
    shape = lp.targets.KING_SHAPE,

    basePrice = 10,
    basePointsGenerated = 1,

    onActivate = function(ent)
        lp.modifierBuff(ent, "pointsGenerated", 6)
    end,

    rarity = lp.rarities.RARE,
})

