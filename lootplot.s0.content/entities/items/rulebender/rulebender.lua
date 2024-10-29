
local helper = require("shared.helper")

local loc = localization.localize


---@param entry string
local function rareItemFilter(entry)
    local etype = server.entities[entry]
    if etype and etype.rarity then
        local rare = lp.rarities.getWeight(lp.rarities.RARE)
        local etypeRarity = lp.rarities.getWeight(etype.rarity)
        return etypeRarity >= rare
    end
    return false
end


---@type generation.Generator
local rareItemGen

local function generateRareItem(ent)
    rareItemGen = rareItemGen or lp.newItemGenerator({
        filter = rareItemFilter
    })

    local itemName = rareItemGen
        :query(function(entityType)
            return lp.getDynamicSpawnChance(entityType, ent)
        end)
    return itemName or lp.FALLBACK_NULL_ITEM
end


lp.defineItem("lootplot.s0.content:gift_box", {
    image = "gift_box",
    name = loc("Gift Box"),

    rarity = lp.rarities.UNCOMMON,

    doomCount = 1,

    shape = lp.targets.RookShape(1),

    target = {
        description = loc("Spawn RARE items."),
        activate = function(selfEnt, ppos, targetEnt)
            local etype = server.entities[generateRareItem(selfEnt)]
            if etype then
                lp.forceSpawnItem(ppos, etype, selfEnt.lootplotTeam)
            end
        end
    }
})



lp.defineItem("lootplot.s0.content:pandoras_box", {
    image = "pandoras_box",
    name = loc("Pandora's Box"),

    rarity = lp.rarities.EPIC,

    shape = lp.targets.ABOVE_SHAPE,

    target = {
        type = "SLOT",
        description = loc("{lootplot.targets:COLOR}Spawn a RARE item in an ABOVE shape that has only 1 use."),
        activate = function(selfEnt, ppos, targetEnt)
            local etype = server.entities[generateRareItem(selfEnt)]

            if etype then
                local e = lp.trySpawnItem(ppos, etype, selfEnt.lootplotTeam)
                if e then
                    e.doomCount = 1
                end
            end
        end
    }
})



local function defineCat(name, etype)
    lp.defineItem(name, etype)
end

defineCat("lootplot.s0.content:copycat", {
    image = "copycat",
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


defineCat("lootplot.s0.content:chubby_cat", {
    image = "chubby_cat",
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


defineCat("lootplot.s0.content:crappy_cat", {
    image = "crappy_cat",
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



lp.defineItem("lootplot.s0.content:boomerang", {
    name = loc("Boomerang"),
    description = loc("Uses all activations at once"),

    image = "boomerang",

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


lp.defineItem("lootplot.s0.content:old_brick", {
    name = loc("Old Brick"),
    description = loc("Loses 2 Points-Generated when activated"),

    image = "old_brick",
    rarity = lp.rarities.RARE,

    basePointsGenerated = 60,
    baseMaxActivations = 10,

    tierUpgrade = helper.pointsMultUpgrade(3),

    onActivate = function(selfEnt)
        lp.modifierBuff(selfEnt, "pointsGenerated", -2)
    end
})




lp.defineItem("lootplot.s0.content:spear_of_war", {
    name = loc("Spear of War"),
    description = loc("Generates points equal to the current combo"),

    image = "spear_of_war",
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




lp.defineItem("lootplot.s0.content:pink_balloon", {
    image = "pink_balloon",
    name = loc("Pink Balloon"),

    rarity = lp.rarities.EPIC,

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "ITEM_OR_SLOT",
        description = loc("If target isn't doomed, give target +1 lives"),
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.lives = targetEnt.lives + 1
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





lp.defineItem("lootplot.s0.content:blank_page", {
    image = "blank_page",
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

