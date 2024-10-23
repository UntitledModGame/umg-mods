local loc = localization.localize


local function defineHelmet(id, etype)
    etype.image = etype.image or id
    etype.rarity = etype.rarity or lp.rarities.RARE
    etype.shape = etype.shape or lp.targets.RookShape(1)

    lp.defineItem("lootplot.s0.content:"..id, etype)
end


local function upgradeFilter(selfEnt, ppos, targetEnt)
    return lp.tiers.getTier(targetEnt) > 1
end

defineHelmet("spartan_helmet", {
    name = loc("Spartan Helmet"),

    target = {
        type = "ITEM",
        description = loc("{lootplot.targets:COLOR}Buff all {wavy}{lootplot:COMBINE_COLOR}UPGRADED{/lootplot:COMBINE_COLOR}{/wavy} target items: +1 points."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 1, selfEnt)
        end,
        filter = upgradeFilter
    }
})



defineHelmet("cobalt_helmet", {
    name = loc("Cobalt Helmet"),

    target = {
        type = "ITEM",
        description = loc("{lootplot.targets:COLOR}Buff all {wavy}{lootplot:COMBINE_COLOR}UPGRADED{/lootplot:COMBINE_COLOR}{/wavy} target items: +1 activations."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "maxActivations", 1, selfEnt)
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

    target = {
        type = "SLOT_OR_ITEM",
        description = loc("{lootplot.targets:COLOR}If target REROLLs, buff target +1 points."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "maxActivations", 1, selfEnt)
        end,
        filter = function(selfEnt, ppos, targetEnt)
            return hasRerollTrigger(targetEnt)
        end
    }
})


--[=[

defineHelmet("cobalt_helmet", {
    name = loc("Cobalt Helmet"),

    rarity = lp.rarities.EPIC,

    target = {
        type = "ITEM",
        description = loc("{lootplot.targets:COLOR}Buff all {wavy}{lootplot:COMBINE_COLOR}UPGRADED{/lootplot:COMBINE_COLOR}{/wavy} target items: +1 points."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 1, selfEnt)
        end,
        filter = upgradeFilter
    }
})

]=]