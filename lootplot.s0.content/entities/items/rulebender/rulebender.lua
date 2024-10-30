
local helper = require("shared.helper")

local loc = localization.localize


local function defItem(id, etype)
    etype.image = etype.image or id
    return lp.defineItem("lootplot.s0.content:"..id, etype)
end



local giftBoxDesc = localization.newInterpolator("After %{count} activations, spawn a random %{rarity} item")
local GIFT_ACTIVATIONS = 0

defItem("gift_box", {
    name = loc("Gift Box"),

    description = function(ent)
        return giftBoxDesc({
            count = GIFT_ACTIVATIONS - (ent.totalActivationCount or 0),
            rarity = lp.rarities.LEGENDARY.displayString
        })
    end,

    basePrice = 6,
    rarity = lp.rarities.RARE,

    onActivate = function(selfEnt)
        if selfEnt.totalActivationCount >= GIFT_ACTIVATIONS then
            local ppos = lp.getPos(selfEnt)
            lp.destroy(selfEnt)
            if ppos then
                local etype = lp.rarities.randomItemOfRarity(lp.rarities.LEGENDARY)
                    or server.entities[lp.FALLBACK_NULL_ITEM]
                lp.trySpawnItem(ppos, etype, selfEnt.lootplotTeam)
            end
        end
    end
})



defItem("pandoras_box", {
    name = loc("Pandora's Box"),

    rarity = lp.rarities.EPIC,

    shape = lp.targets.RookShape(1),

    target = {
        type = "NO_ITEM",
        description = loc("Spawn RARE items."),
        activate = function(selfEnt, ppos, targetEnt)
            local etype = lp.rarities.randomItemOfRarity(lp.rarities.LEGENDARY)
            if etype then
                lp.trySpawnItem(ppos, etype, selfEnt.lootplotTeam)
            end
        end
    }
})



local function defineCat(name, etype)
    defItem(name, etype)
end

defineCat("copycat", {
    name = loc("Copycat"),

    rarity = lp.rarities.EPIC,

    basePrice = 0,

    shape = lp.targets.RookShape(1),

    target = {
        type = "NO_ITEM",
        description = loc("{lootplot.targets:COLOR}Copies self into target slots"),
        activate = function(selfEnt, ppos, targetEnt)
            local copyEnt = lp.clone(selfEnt)
            local success = lp.trySetItem(ppos, copyEnt)
            if not success then
                copyEnt:delete()
            end
        end
    }
})


defineCat("chubby_cat", {
    name = loc("Chubby Cat"),
    description = loc("Starts with 9 lives"),

    onDraw = function(ent)
        if ent.lives and ent.lives < 1 then
            ent.image = "chubby_cat_sad"
        else
            ent.image = "chubby_cat"
        end
    end,

    rarity = lp.rarities.RARE,

    lives = 9
})


defineCat("crappy_cat", {
    name = loc("Crappy Cat"),

    rarity = lp.rarities.RARE,

    shape = lp.targets.RookShape(1),

    target = {
        type = "ITEM",
        description = loc("{lootplot.targets:COLOR}Converts target items into a clone of itself"),
        activate = function(selfEnt, ppos, targetEnt)
            local copyEnt = lp.clone(selfEnt)
            local success = lp.forceSetItem(ppos, copyEnt)
            if not success then
                copyEnt:delete()
            end
        end
    }
})



defItem("boomerang", {
    name = loc("Boomerang"),
    description = loc("Uses all activations at once"),

    basePointsGenerated = 1,
    baseMaxActivations = 10,

    rarity = lp.rarities.RARE,

    onActivate = function(selfEnt)
        local ppos = lp.getPos(selfEnt)

        if ppos then
            return lp.queueWithEntity(selfEnt, function ()
                lp.tryActivateEntity(selfEnt)
                lp.wait(ppos, 0.2)
            end)
        end
    end
})


defItem("old_brick", {
    name = loc("Old Brick"),
    description = loc("Loses 2 Points-Generated when activated"),

    rarity = lp.rarities.RARE,

    basePointsGenerated = 60,
    baseMaxActivations = 10,

    tierUpgrade = helper.pointsMultUpgrade(3),

    onActivate = function(selfEnt)
        lp.modifierBuff(selfEnt, "pointsGenerated", -2)
    end
})




defItem("spear_of_war", {
    name = loc("Spear of War"),
    description = loc("Generates points equal to the current combo"),

    rarity = lp.rarities.EPIC,

    baseMaxActivations = 100,

    tierUpgrade = helper.pointsMultUpgrade(3),

    onActivate = function(ent)
        local combo = lp.getCombo(ent)
        if combo then
            lp.addPoints(ent, combo)
        end
    end
})




defItem("pink_balloon", {
    name = loc("Pink Balloon"),

    rarity = lp.rarities.EPIC,

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "ITEM_OR_SLOT",
        description = loc("If target isn't doomed, give target +1 lives"),
        activate = function(selfEnt, ppos, targetEnt)
            if not targetEnt.doomCount then
                targetEnt.lives = (targetEnt.lives or 0) + 1
            end
        end,
        filter = function(selfEnt, ppos, targetEnt)
            return (not targetEnt.doomCount)
        end
    }
})

------------------------------------------------------------





------------------------------------------------------------

local function defineOcto(name, etype)
    local id = "lootplot.s0.content:" .. name

    etype.image = etype.image or id
    etype.shape = etype.shape or lp.targets.KING_SHAPE
    etype.rarity = etype.rarity or lp.rarities.RARE

    etype.baseMaxActivations = 5
    etype.tierUpgrade = helper.propertyUpgrade("maxActivations", 5, 2)

    lp.defineItem(id, etype)
end

defineOcto("pink_octopus", {
    name = loc("Pink Octopus"),

    target = {
        type = "ITEM_OR_SLOT",
        description = loc("Triggers item or slot."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("PULSE", targetEnt)
        end
    }
})

defineOcto("dark_octopus", {
    name = loc("Dark Octopus"),

    rarity = lp.rarities.EPIC,

    target = {
        type = "ITEM",
        description = loc("Triggers destroy on item, without destroying it."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("DESTROY", targetEnt)
        end
    }
})

defineOcto("reroll_octopus", {
    name = loc("Reroll Octopus"),

    target = {
        type = "SLOT_OR_ITEM",
        description = loc("{lootplot.targets:COLOR}Rerolls target slot or item."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("REROLL", targetEnt)
        end
    }
})

------------------------------------------------------------





defItem("blank_page", {
    name = loc("Blank Page"),

    rarity = lp.rarities.EPIC,

    shape = lp.targets.ABOVE_SHAPE,

    target = {
        type = "ITEM",
        description = loc("Copies Points-Generated of target item"),
        activate = function(selfEnt, ppos, targetEnt)
            if targetEnt.pointsGenerated then
                selfEnt.basePointsGenerated = targetEnt.pointsGenerated
                -- no need to sync; properties are synced automatically.
            end
        end
    }
})




defItem("anchor", {
    name = loc("Anchor"),
    description = loc("Sets points to 0."),

    rarity = lp.rarities.EPIC,

    baseMoneyGenerated = 5,

    onActivate = function(ent)
        lp.setPoints(ent, 0)
    end
})

