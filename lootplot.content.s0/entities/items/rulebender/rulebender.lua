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
    description = loc("After 3 activations, transform into a RARE item."),

    rarity = lp.rarities.COMMON,
    minimumLevelToSpawn = 2,

    baseBuyPrice = 1,

    onActivate = function(selfEnt)
        if selfEnt.totalActivationCount >= 3 then
            local ppos = lp.getPos(selfEnt)
            if ppos then
                local etype = server.entities[generateRareItem(selfEnt)]

                if etype then
                    lp.forceSpawnItem(ppos, etype, selfEnt.lootplotTeam)
                end
            end
        end
    end
})

lp.defineItem("lootplot.content.s0:money_box", {
    image = "money_box",
    name = loc("Dollar Box"),
    description = loc("Transform into a RARE item that costs $1 to use"),

    rarity = lp.rarities.COMMON,
    minimumLevelToSpawn = 2,

    baseBuyPrice = 1,

    onActivate = function(selfEnt)
        local ppos = lp.getPos(selfEnt)
        if ppos then
            local etype = server.entities[generateRareItem(selfEnt)]

            if etype then
                local e = lp.forceSpawnItem(ppos, etype, selfEnt.lootplotTeam)
                if e then
                    e.baseMoneyGenerated = -1
                end
            end
        end
    end
})



lp.defineItem("lootplot.content.s0:copycat", {
    image = "copycat",
    name = loc("Copycat"),

    rarity = lp.rarities.RARE,
    minimumLevelToSpawn = 4,

    targetType = "NO_ITEM",
    targetShape = lp.targets.PlusShape(1),
    targetActivationDescription = loc("{lp_targetColor}Copies self into target slots"),
    targetActivate = function(selfEnt, ppos, targetEnt)
        local copyEnt = lp.clone(selfEnt)
        lp.moveIntoTakenSlot()
        local oldItem = lp.posToItem(ppos)
        if oldItem then
            lp.destroy(oldItem)
        end
        ppos:set(copyEnt)
    end
})




lp.defineItem("lootplot.content.s0:pandoras_box", {
    image = "pandoras_box",
    name = loc("Pandora's Box"),

    rarity = lp.rarities.EPIC,
    minimumLevelToSpawn = 4,

    targetType = "SLOT",
    targetShape = lp.targets.ABOVE_SHAPE,
    targetActivationDescription = loc("{lp_targetColor}Spawn a RARE item in an ABOVE shape that has only 1 use."),
    targetActivate = function(selfEnt, ppos, targetEnt)
        local etype = server.entities[generateRareItem(selfEnt)]

        if etype then
            local e = lp.trySpawnItem(ppos, etype, selfEnt.lootplotTeam)
            if e then
                e.doomCount = 1
            end
        end
    end
})


lp.defineItem("lootplot.content.s0:boomerang", {
    name = loc("Boomerang"),
    description = loc("The boomerang never stops!"),

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


lp.defineItem("lootplot.content.s0:red_shield", {
    image = "red_shield",
    name = loc("Red Shield"),

    rarity = lp.rarities.RARE,

    targetType = "ITEM",
    targetShape = lp.targets.KING_SHAPE,
    targetActivationDescription = loc("{lp_targetColor}Triggers PULSE for all target items."),
    targetActivate = function(selfEnt, ppos, targetEnt)
        lp.tryTriggerEntity("PULSE", targetEnt)
    end
})
