
local helper = require("shared.helper")

local loc = localization.localize


local function defItem(id, etype)
    etype.image = etype.image or id
    return lp.defineItem("lootplot.s0.content:"..id, etype)
end



local giftBoxDesc = localization.newInterpolator("After %{count} activations, spawn a random %{rarity} item")
local GIFT_ACTIVATIONS = 25

defItem("gift_box", {
    name = loc("Gift Box"),

    description = function(ent)
        return giftBoxDesc({
            count = GIFT_ACTIVATIONS - (ent.totalActivationCount or 0),
            rarity = lp.rarities.LEGENDARY.displayString
        })
    end,

    basePrice = 6,
    baseMaxActivations = 2,
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
    doomCount = 1,

    basePrice = 8,
    baseMaxActivations = 1,

    target = {
        type = "SLOT_NO_ITEM",
        description = loc("Spawn RARE items."),
        activate = function(selfEnt, ppos, targetEnt)
            local etype = lp.rarities.randomItemOfRarity(lp.rarities.RARE)
            if etype then
                lp.trySpawnItem(ppos, etype, selfEnt.lootplotTeam)
            end
        end
    }
})



local function defineCat(name, etype)
    defItem(name, etype)
end

---@param selfEnt Entity
---@param ppos lootplot.PPos
---@return Entity?
local function copySelf(selfEnt, ppos)
    local copyEnt = lp.clone(selfEnt)
    local success = lp.trySetItem(ppos, copyEnt)
    if not success then
        copyEnt:delete()
        return nil
    end
    return copyEnt
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

    target = {
        type = "NO_ITEM",
        description = loc("{lootplot.targets:COLOR}Copies self into target slots"),
        activate = function(selfEnt, ppos, targetEnt)
            copySelf(selfEnt, ppos)
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

    target = {
        type = "NO_ITEM",
        description = loc("Copies self into target slots"),
        activate = function(selfEnt, ppos, targetEnt)
            if selfEnt.doomCount <= 0 then
                return
            end
            copySelf(selfEnt, ppos)
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

    target = {
        type = "NO_ITEM",
        description = loc("Copies self into target slots, and gives {lootplot:POINTS_MOD_COLOR}25 points{/lootplot:POINTS_MOD_COLOR} to the copy!"),
        activate = function(selfEnt, ppos)
            local e = copySelf(selfEnt, ppos)
            if e then
                lp.modifierBuff(e, "pointsGenerated", 25, selfEnt)
            end
        end
    }
})





defineCat("chubby_cat", {
    name = loc("Chubby Cat"),
    description = loc("Starts with 9 lives"),
    triggers = {},

    basePrice = 6,
    baseMaxActivations = 20,

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

    basePrice = 3,
    baseMaxActivations = 100,

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



defItem("old_brick", {
    name = loc("Old Brick"),
    activateDescription = loc("Loses 2 Points-Generated permanently"),

    rarity = lp.rarities.RARE,

    basePrice = 6,
    basePointsGenerated = 60,
    baseMaxActivations = 10,

    tierUpgrade = helper.pointsMultUpgrade(3),

    onActivate = function(selfEnt)
        lp.modifierBuff(selfEnt, "pointsGenerated", -2)
    end
})




defItem("spear_of_war", {
    name = loc("Spear of War"),
    activateDescription = loc("Generates points equal to the current combo"),

    rarity = lp.rarities.EPIC,

    baseMaxActivations = 25,
    basePointsGenerated = 1,
    basePrice = 9,

    tierUpgrade = helper.pointsMultUpgrade(3),

    onActivate = function(ent)
        local combo = lp.getCombo(ent)
        if combo then
            local p, mod, mult = properties.computeProperty(ent, "pointsGenerated")
            lp.addPoints(ent, combo * mult)
        end
    end
})




defItem("pink_balloon", {
    name = loc("Pink Balloon"),

    rarity = lp.rarities.EPIC,

    shape = lp.targets.KING_SHAPE,

    baseMaxActivations = 3,
    basePrice = 12,

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

    etype.basePrice = 8
    etype.baseMaxActivations = 5

    etype.tierUpgrade = helper.propertyUpgrade("maxActivations", 5, 2)

    lp.defineItem(id, etype)
end

defineOcto("pink_octopus", {
    name = loc("Pink Octopus"),

    target = {
        type = "ITEM",
        description = loc("{lootplot:TRIGGER_COLOR}{wavy}PULSES{/wavy}{/lootplot:TRIGGER_COLOR} item."),
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
        description = loc("Triggers {lootplot:TRIGGER_COLOR}{wavy}DESTROY{/wavy}{/lootplot:TRIGGER_COLOR} on item, without destroying it."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("DESTROY", targetEnt)
        end
    }
})

defineOcto("green_octopus", {
    name = loc("Green Octopus"),

    triggers = {"REROLL", "PULSE"},

    target = {
        type = "ITEM",
        description = loc("Triggers {lootplot:TRIGGER_COLOR}{wavy}REROLL{/wavy}{/lootplot:TRIGGER_COLOR} on item."),
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

    basePrice = 9,
    baseMaxActivations = 10,

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



defItem("ukulele", {
    name = loc("Ukulele"),

    rarity = lp.rarities.UNCOMMON,

    basePrice = 6,
    baseMaxActivations = 2,

    tierUpgrade = helper.propertyUpgrade("maxActivations", 2, 3),

    shape = lp.targets.RookShape(1),

    target = {
        type = "ITEM",
        description = loc("Triggers {lootplot:TRIGGER_COLOR}{wavy}PULSE{/wavy}{/lootplot:TRIGGER_COLOR} for item."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("PULSE", targetEnt)
        end
    }
})



defItem("map", {
    name = loc("Map"),

    rarity = lp.rarities.UNCOMMON,

    shape = lp.targets.CircleShape(5),

    activateDescription = loc("TODO: NOT YET IMPLEMENTED!"),

    doomCount = 1,
    basePrice = 5,

    target = {
        type = "NO_SLOT",
        description = loc("Reveals fog."),
        filter = function(selfEnt, ppos)
            ---@type lootplot.Plot
            local plot = ppos:getPlot()
            return not plot:isFogRevealed(ppos, selfEnt.lootplotTeam)
        end,
        activate = function(selfEnt, ppos)
            ---@type lootplot.Plot
            local plot = ppos:getPlot()
            return plot:setFogRevealed(ppos, selfEnt.lootplotTeam, true)
        end
    }
})




defItem("anchor", {
    name = loc("Anchor"),
    activateDescription = loc("Sets points to 0."),

    rarity = lp.rarities.EPIC,

    basePrice = 7,
    baseMaxActivations = 3,
    baseMoneyGenerated = 5,

    onActivate = function(ent)
        lp.setPoints(ent, 0)
    end
})

