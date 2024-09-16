local loc = localization.localize

lp.defineItem("lootplot.content.s0:dark_skull", {
    image = "dark_skull",
    name = loc("Dark Skull"),
    basePointsGenerated = 5,

    rarity = lp.rarities.UNCOMMON,

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "ITEM",
        description = function(selfEnt)
            return loc("{lp_targetColor}Destroys target item, generate {c r=0.4 g=0.4}%{pointsGenerated}{/c} point(s).", selfEnt)
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.destroy(targetEnt)
            lp.addPoints(selfEnt, selfEnt.pointsGenerated)
        end
    }
})


lp.defineItem("lootplot.content.s0:profit_purger", {
    image = "profit_purger",
    name = loc("Profit Purger"),
    baseMoneyGenerated = 1,

    rarity = lp.rarities.EPIC,

    shape = lp.targets.BishopShape(2),

    target = {
        type = "SLOT",
        description = function(selfEnt)
            return loc("{lp_targetColor}Destroys target slot, earn(s) {c r=0.5 b=0.4}%{moneyGenerated}{/c}", selfEnt)
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.destroy(targetEnt)
            lp.addMoney(selfEnt, selfEnt.moneyGenerated)
        end
    }
})


lp.defineItem("lootplot.content.s0:dark_flint", {
    image = "dark_flint",
    name = loc("Dark Flint"),
    rarity = lp.rarities.COMMON,
    triggers = {"DESTROY"},
    basePointsGenerated = 10
})


lp.defineItem("lootplot.content.s0:reaper", {
    image = "reaper",
    name = loc("Reaper"),
    basePointsGenerated = 4,

    rarity = lp.rarities.RARE,

    shape = lp.targets.RookShape(1),

    target = {
        type = "ITEM",
        description = loc("{lp_targetColor}Destroy target items, permanently gain +3 points-generated"),
        activate = function(selfEnt, ppos, targetEnt)
            lp.destroy(targetEnt)
            lp.modifierBuff(selfEnt, "pointsGenerated", 3)
        end
    },
})


lp.defineItem("lootplot.content.s0:empty_cauldron", {
    image = "empty_cauldron",
    name = loc("Empty Cauldron"),
    basePointsGenerated = 5,

    rarity = lp.rarities.UNCOMMON,

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "SLOT",
        description = function(selfEnt)
            return loc("{lp_targetColor}Destroys target slot, gain {c r=0.4 g=0.4}%{pointsGenerated}{/c} point(s).", selfEnt)
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.destroy(targetEnt)
            lp.addPoints(selfEnt, selfEnt.pointsGenerated)
        end
    }
})



lp.defineItem("lootplot.content.s0:tooth_necklace", {
    image = "tooth_necklace",
    name = loc("Tooth Necklace"),
    description = loc("Gives slot doomed-4.\nOnly activates if the slot isn't doomed!"),

    baseMaxActivations = 10,
    baseMoneyGenerated = 4,

    rarity = lp.rarities.UNCOMMON,

    canActivate = function(ent)
        local slotEnt = lp.itemToSlot(ent)
        if slotEnt and (not slotEnt.doomCount) then
            return true
        end
    end,

    onActivate = function(ent)
        local slotEnt = lp.itemToSlot(ent)
        if slotEnt then
            slotEnt.doomCount = 4
        end
    end
})
