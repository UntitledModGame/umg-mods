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


lp.defineItem("lootplot.content.s0:gift_box", {
    image = "gift_box",
    name = loc("Gift Box"),

    rarity = lp.rarities.UNCOMMON,
    minimumLevelToSpawn = 2,

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
    minimumLevelToSpawn = 4,

    shape = lp.targets.ABOVE_SHAPE,

    target = {
        type = "SLOT",
        description = loc("{lp_targetColor}Spawn a RARE item in an ABOVE shape that has only 1 use."),
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



lp.defineItem("lootplot.content.s0:copycat", {
    image = "copycat",
    name = loc("Copycat"),

    rarity = lp.rarities.RARE,
    minimumLevelToSpawn = 4,

    basePrice = 0,

    shape = lp.targets.RookShape(1),

    target = {
        type = "NO_ITEM",
        description = loc("{lp_targetColor}Copies self into target slots"),
        activate = function(selfEnt, ppos, targetEnt)
            local copyEnt = lp.clone(selfEnt)
            local oldItem = lp.posToItem(ppos)
            if oldItem then
                lp.destroy(oldItem)
            end
            local success = lp.trySetItem(ppos, copyEnt)
            if not success then
                copyEnt:delete()
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
            return lp.queue(ppos, function ()
                if umg.exists(selfEnt) then
                    lp.tryActivateEntity(selfEnt)
                    lp.wait(ppos, 0.3)
                end
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
        description = loc("{lp_targetColor}Triggers item."),
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
        description = loc("{lp_targetColor}Triggers slot."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("PULSE", targetEnt)
        end
    }
})

--[[
    TODO:
    Define dark_octopus here.

    dark-octo should relate to destruction somehow;
    yet should still be similar to the other octos.

    some ideas:
    - trigger DESTROY for entity; without killing the entity.
        - ^^^ I LOVE THIS IDEA!
    - trigger ACTIVATE for entity; IFF the entity is DOOMED.
]]
