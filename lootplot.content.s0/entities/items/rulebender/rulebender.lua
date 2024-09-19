local loc = localization.newLocalizer()

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


lp.defineItem("lootplot.content.s0:gift_box", {
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



lp.defineItem("lootplot.content.s0:pandoras_box", {
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

defineCat("lootplot.content.s0:copycat", {
    image = "copycat",
    name = loc("Copycat"),

    rarity = lp.rarities.RARE,

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


defineCat("lootplot.content.s0:chubby_cat", {
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

    rarity = lp.rarities.UNCOMMON,

    lives = 9
})


defineCat("lootplot.content.s0:crappy_cat", {
    image = "crappy_cat",
    name = loc("Crappy Cat"),

    rarity = lp.rarities.RARE,

    shape = lp.targets.RookShape(1),

    target = {
        type = "ITEM",
        description = loc("{lootplot.targets:COLOR}Converts target items into a clone of itself"),
        activate = function(selfEnt, ppos, targetEnt)
            local copyEnt = lp.clone(selfEnt)
            local success = lp.trySetItem(ppos, copyEnt)
            if not success then
                copyEnt:delete()
            else
                --[[
                TODO: this relies on kinda janky trySetItem semantics.
                We need to do more proper thinking about how item setting
                should actually work, especially when we overwrite items.
                Deleting them manually (like we do here with targetEnt)
                should NOT be the norm.
                ]]
                targetEnt:delete()
            end
        end
    }
})






lp.defineItem("lootplot.content.s0:boomerang", {
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


lp.defineItem("lootplot.content.s0:pink_octopus", {
    image = "pink_octopus",
    name = loc("Pink Octopus"),

    rarity = lp.rarities.RARE,

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "ITEM",
        description = loc("{lootplot.targets:COLOR}Triggers item."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("PULSE", targetEnt)
        end
    }
})

lp.defineItem("lootplot.content.s0:orange_octopus", {
    image = "orange_octopus",
    name = loc("Orange Octopus"),

    rarity = lp.rarities.EPIC,

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "SLOT",
        description = loc("{lootplot.targets:COLOR}Triggers slot."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("PULSE", targetEnt)
        end
    }
})

lp.defineItem("lootplot.content.s0:dark_octopus", {
    image = "dark_octopus",
    name = loc("Dark Octopus"),

    rarity = lp.rarities.EPIC,

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "ITEM",
        description = loc("{lootplot.targets:COLOR}Triggers destroy on item, without destroying it."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("DESTROY", targetEnt)
        end
    }
})

