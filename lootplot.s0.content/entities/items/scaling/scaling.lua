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
    defItem(id,etype)
end



local BASIC_BUFF_UPGRADE_DESC = {
    description = loc("Increases buff amount!")
}


local function upgradeFilter(selfEnt, ppos, targetEnt)
    return lp.tiers.getTier(targetEnt) > 1
end

defineHelmet("spartan_helmet", {
    name = loc("Spartan Helmet"),

    basePrice = 10,

    tierUpgrade = BASIC_BUFF_UPGRADE_DESC,

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
    description = loc("Gain 1 point permanently when activated"),

    basePointsGenerated = -10,
    rarity = lp.rarities.UNCOMMON,

    baseMaxActivations = 2,
    tierUpgrade = helper.propertyUpgrade("maxActivations", 1, 2),

    onActivate = function(ent)
        lp.modifierBuff(ent, "pointsGenerated", 1)
    end
})



defineHelmet("cobalt_helmet", {
    name = loc("Cobalt Helmet"),

    basePrice = 12,

    tierUpgrade = BASIC_BUFF_UPGRADE_DESC,

    target = {
        type = "ITEM",
        description = interp("Buff all {wavy}{lootplot:COMBINE_COLOR}UPGRADED{/lootplot:COMBINE_COLOR}{/wavy} target items: +%{tier} activations."),
        activate = function(selfEnt, ppos, targetEnt)
            local x = lp.tiers.getTier(selfEnt)
            lp.modifierBuff(targetEnt, "maxActivations", x, selfEnt)
        end,
        filter = upgradeFilter
    }
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

    shape = lp.targets.KING_SHAPE,

    basePrice = 10,

    tierUpgrade = BASIC_BUFF_UPGRADE_DESC,

    target = {
        type = "SLOT_OR_ITEM",
        description = interp("If target has reroll trigger, buff target +%{tier} points."),
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

    triggers = {},
    basePrice = 14,

    description = interp("Gains +%{tier} Points-Generated every activation"),
    basePointsGenerated = 1,

    rarity = lp.rarities.EPIC,

    onActivate = function(ent)
        local x = lp.tiers.getTier(ent)
        lp.modifierBuff(ent, "pointsGenerated", x)
    end,

    listen = {
        trigger = "DESTROY"
    }
})

