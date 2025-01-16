
local loc = localization.localize


local function defineCat(id, etype)
    if not etype.listen then
        etype.triggers = etype.triggers or {"PULSE"}
    end
    etype.image = etype.image or id
    return lp.defineItem("lootplot.s0.content:"..id, etype)
end





defineCat("copycat", {
    name = loc("Copycat"),

    init = function(ent)
        if lp.SEED:randomMisc()<0.01 then
            ent.image = "copycat_but_cool"
        end
    end,

    rarity = lp.rarities.EPIC,

    basePrice = 0,
    baseMaxActivations = 10,

    shape = lp.targets.RookShape(1),

    activateDescription = loc("Copies self into target slots"),

    target = {
        type = "NO_ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryCloneItem(selfEnt, ppos)
        end
    }
})


defineCat("chubby_cat", {
    name = loc("Chubby Cat"),

    rarity = lp.rarities.EPIC,

    basePrice = 0,
    baseMaxActivations = 10,
    baseMultGenerated = 1,
    sticky = true,

    shape = lp.targets.RookShape(1),

    activateDescription = loc("Copies self into target slots"),

    target = {
        type = "NO_ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryCloneItem(selfEnt, ppos)
        end
    }
})




defineCat("copykitten", {
    name = loc("Copykitten"),

    rarity = lp.rarities.RARE,

    basePrice = 0,
    baseMaxActivations = 3,
    basePointsGenerated = 5,
    doomCount = 4,

    canItemFloat = true,

    shape = lp.targets.RookShape(1),

    activateDescription = loc("Copies self into target slots"),

    target = {
        type = "NO_ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            if selfEnt.doomCount <= 0 then
                return
            end
            lp.tryCloneItem(selfEnt, ppos)
        end
    }
})

defineCat("copykato", {
    name = loc("Copykato"),

    rarity = lp.rarities.RARE,

    basePrice = 0,
    baseMoneyGenerated = -2,
    baseMaxActivations = 3,
    basePointsGenerated = 25,

    shape = lp.targets.RookShape(1),

    activateDescription = loc("Copies self into target slots, and gives {lootplot:POINTS_MOD_COLOR}25 points{/lootplot:POINTS_MOD_COLOR} to the copy!"),

    target = {
        type = "NO_ITEM",
        activate = function(selfEnt, ppos)
            local e = lp.tryCloneItem(selfEnt, ppos)
            if e then
                lp.modifierBuff(e, "pointsGenerated", 25, selfEnt)
            end
        end
    }
})






defineCat("pink_cat", {
    name = loc("Pink Cat"),
    description = loc("Starts with 9 lives"),
    triggers = {},

    basePrice = 6,
    baseMaxActivations = 20,

    onDraw = function(ent)
        if ent.lives and ent.lives < 1 then
            ent.image = "pink_cat_sad"
        else
            ent.image = "pink_cat"
        end
    end,

    rarity = lp.rarities.RARE,

    lives = 9
})





defineCat("crappy_cat", {
    name = loc("Crappy Cat"),
    activateDescription = loc("Converts target items into a clone of itself"),

    rarity = lp.rarities.RARE,

    basePrice = 3,
    baseMaxActivations = 100,

    shape = lp.targets.RookShape(1),

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.forceCloneItem(selfEnt, ppos)
        end
    }
})


