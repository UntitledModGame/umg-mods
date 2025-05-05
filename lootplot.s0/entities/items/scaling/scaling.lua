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


local function defineHelmet(id, name, etype)
    etype.rarity = etype.rarity or lp.rarities.RARE
    etype.name = loc(name)

    etype.init = etype.init or helper.rotateRandomly

    etype.shape = etype.shape or lp.targets.DownShape(2)

    etype.basePrice = etype.basePrice or 10
    etype.baseMaxActivations = etype.baseMaxActivations or 6

    defItem(id,etype)
end





defineHelmet("iron_helmet", "Iron Helmet", {
    activateDescription = loc("Give items {lootplot:POINTS_COLOR}+1 points."),

    triggers = {"PULSE"},

    basePrice = 10,
    baseMaxActivations = 6,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 1, selfEnt)
        end,
    }
})




defItem("vampire_fang", {
    name = loc("Vampire Fang"),
    triggers = {"PULSE"},

    activateDescription = loc("Steal 5 points from the slot.\nGain +5 points permanently."),

    baseMaxActivations = 8,
    basePrice = 10,

    onActivate = function(ent)
        local slotEnt = lp.itemToSlot(ent)
        if slotEnt then
            lp.modifierBuff(slotEnt, "pointsGenerated", -5, ent)
            lp.modifierBuff(ent, "pointsGenerated", 5, ent)
        end
    end,

    rarity = lp.rarities.RARE,
})




do
local KNIFE_TRIGGERS = {"PULSE", "REROLL", "ROTATE"}
local KNIFE_ACTIVATIONS = 6
local KNIFE_PRICE = 9

defItem("moon_knife", {
    name = loc("Moon Knife"),
    activateDescription = loc("Gain 2 points permanently"),

    triggers = KNIFE_TRIGGERS,

    basePointsGenerated = -10,
    rarity = lp.rarities.UNCOMMON,

    basePrice = KNIFE_PRICE,

    baseMaxActivations = KNIFE_ACTIVATIONS,

    onActivate = function(ent)
        lp.modifierBuff(ent, "pointsGenerated", 2)
    end
})

defItem("demon_knife", {
    name = loc("Demon Knife"),
    activateDescription = loc("Gain {lootplot:POINTS_MULT_COLOR}+0.1 multiplier{/lootplot:POINTS_MULT_COLOR} permanently"),

    triggers = KNIFE_TRIGGERS,

    baseMultGenerated = -0.5,
    rarity = lp.rarities.RARE,

    basePrice = KNIFE_PRICE,

    baseMaxActivations = KNIFE_ACTIVATIONS,

    onActivate = function(ent)
        lp.modifierBuff(ent, "multGenerated", 0.1)
    end
})


local BONUS_BUFF = 0.5
defItem("ghost_knife", {
    name = loc("Ghost Knife"),
    activateDescription = loc("Gain {lootplot:BONUS_COLOR}+%{buff} bonus{/lootplot:BONUS_COLOR} permanently", {
        buff = BONUS_BUFF
    }),

    triggers = KNIFE_TRIGGERS,

    baseBonusGenerated = -2,
    rarity = lp.rarities.RARE,

    basePrice = KNIFE_PRICE,

    baseMaxActivations = KNIFE_ACTIVATIONS,

    onActivate = function(ent)
        lp.modifierBuff(ent, "bonusGenerated", BONUS_BUFF)
    end
})
end



defineHelmet("ruby_helmet", "Ruby Helmet", {
    activateDescription = loc("Give +2 activations to items"),

    triggers = {"PULSE"},

    rarity = lp.rarities.LEGENDARY,

    basePrice = 12,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "maxActivations", 2, selfEnt)
        end,
        filter = function(selfEnt, ppos, targetEnt)
            return (targetEnt.maxActivations or 0) < lp.MAX_ACTIVATIONS_LIMIT
        end
    },
})



defineHelmet("emerald_helmet", "Emerald Helmet", {
    activateDescription = loc("Give items {lootplot:POINTS_MOD_COLOR}+1 points."),

    triggers = {"REROLL", "PULSE"},

    basePrice = 10,
    baseMaxActivations = 10,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 1, selfEnt)
        end,
    }
})




defineHelmet("cast_helmet", "Cast Helmet", {
    activateDescription = loc("Give items without {lootplot:TRIGGER_COLOR}Pulse{/lootplot:TRIGGER_COLOR} trigger {lootplot:POINTS_COLOR}+8 points."),

    triggers = {"REROLL"},

    basePrice = 10,
    baseMaxActivations = 4,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 8, selfEnt)
        end,
        filter = function(selfEnt, ppos, targEnt)
            return not lp.hasTrigger(targEnt, "PULSE")
        end
    }
})




do
local PERCENTAGE_CHANCE = 10

defineHelmet("deathly_helmet", "Deathly Helmet", {
    triggers = {"PULSE"},

    activateDescription = loc("Give items {lootplot:POINTS_COLOR}+10 points.{/lootplot:POINTS_COLOR}\n%{chance}% Chance to destroy items.", {
        chance = PERCENTAGE_CHANCE
    }),

    basePrice = 10,
    baseMaxActivations = 10,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 10, selfEnt)
            if lp.SEED:randomMisc() < (PERCENTAGE_CHANCE/100) then
                lp.destroy(targetEnt)
            end
        end,
    }
})

end

