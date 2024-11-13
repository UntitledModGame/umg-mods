local loc = localization.localize
local interp = localization.newInterpolator

local helper = require("shared.helper")



local function defItem(id, etype)
    etype.image = etype.image or id

    return lp.defineItem("lootplot.s0.content:"..id, etype)
end


local function defineHelmet(id, etype)
    etype.rarity = etype.rarity or lp.rarities.RARE
    etype.shape = etype.shape or lp.targets.RookShape(1)
    etype.baseMaxActivations = etype.baseMaxActivations or 1
    etype.basePrice = etype.basePrice or 10
    defItem(id,etype)
end



local BASIC_HELMET_UPGRADE = helper.propertyUpgrade("maxActivations", 1, 3)


local function upgradeFilter(selfEnt, ppos, targetEnt)
    return lp.tiers.getTier(targetEnt) > 1
end

defineHelmet("iron_helmet", {
    name = loc("Iron Helmet"),

    basePrice = 10,

    tierUpgrade = BASIC_HELMET_UPGRADE,
    mineralType = "iron",

    target = {
        type = "ITEM",
        description = interp("Buff all {wavy}{lootplot:COMBINE_COLOR}UPGRADED{/lootplot:COMBINE_COLOR}{/wavy} target items: +%{tier} points."),
        activate = function(selfEnt, ppos, targetEnt)
            local x = lp.tiers.getTier(selfEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", x, selfEnt)
        end,
        filter = upgradeFilter
    }
})



defItem("moon_knife", {
    name = loc("Moon Knife"),
    activateDescription = loc("Gain 1 point permanently"),

    basePointsGenerated = -10,
    rarity = lp.rarities.UNCOMMON,

    basePrice = 9,

    baseMaxActivations = 3,
    tierUpgrade = helper.propertyUpgrade("maxActivations", 3, 2),

    onActivate = function(ent)
        lp.modifierBuff(ent, "pointsGenerated", 1)
    end
})



defineHelmet("ruby_helmet", {
    name = loc("Ruby Helmet"),

    basePrice = 12,

    mineralType = "ruby",
    tierUpgrade = BASIC_HELMET_UPGRADE,

    target = {
        type = "ITEM",
        description = interp("Buff all {wavy}{lootplot:COMBINE_COLOR}UPGRADED{/lootplot:COMBINE_COLOR}{/wavy} target items:\n+%{tier} activations. (Capped at 30)"),
        activate = function(selfEnt, ppos, targetEnt)
            if (targetEnt.maxActivations or 0) < 30 then
                local x = lp.tiers.getTier(selfEnt)
                lp.modifierBuff(targetEnt, "maxActivations", x, selfEnt)
            end
        end,
        filter = upgradeFilter
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

    shape = lp.targets.KING_SHAPE,

    basePrice = 10,
    tierUpgrade = BASIC_HELMET_UPGRADE,
    mineralType = "emerald",

    target = {
        type = "SLOT_OR_ITEM",
        description = interp("If target has {lootplot:TRIGGER_COLOR}REROLL trigger{/lootplot:TRIGGER_COLOR}, buff target +%{tier} points."),
        activate = function(selfEnt, ppos, targetEnt)
            local x = lp.tiers.getTier(selfEnt)
            lp.modifierBuff(targetEnt, "maxActivations", x, selfEnt)
        end,
        filter = function(selfEnt, ppos, targetEnt)
            return hasRerollTrigger(targetEnt)
        end
    }
})



defineHelmet("doom_helmet", {
    name = loc("Doom Helmet"),
    activateDescription = interp("Permanently gains {lootplot:POINTS_MOD_COLOR}+4 Points-Generated"),

    triggers = {},
    listen = {
        trigger = "DESTROY"
    },

    basePrice = 14,
    basePointsGenerated = 1,

    onActivate = function(ent)
        lp.modifierBuff(ent, "pointsGenerated", 4)
    end,

    rarity = lp.rarities.EPIC,
})

