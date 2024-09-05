

local loc = localization.localize


local function defineFood(entName, etype)
    etype.doomCount = etype.doomCount or 1

    lp.defineItem(entName, etype)
end


defineFood("lootplot.content.s0:blueberry", {
    image = "blueberry",

    name = loc("Blueberry"),

    rarity = lp.rarities.EPIC,
    minimumLevelToSpawn = 6,

    baseTraits = {},

    targetType = "ITEM",
    targetShape = lp.targets.ABOVE_SHAPE,
    targetActivationDescription = loc("{lp_targetColor}Adds 2 Doom-count to item"),

    targetActivate = function (selfEnt, ppos, targetEnt)
        if targetEnt.doomCount then
            targetEnt.doomCount = targetEnt.doomCount + 2
        end
    end
})


defineFood("lootplot.content.s0:lychee", {
    image = "lychee",

    name = loc("Lychee"),

    baseTraits = {},

    rarity = lp.rarities.RARE,
    minimumLevelToSpawn = 6,

    targetType = "ITEM",
    targetShape = lp.targets.ABOVE_SHAPE,
    targetActivationDescription = loc("{lp_targetColor}Gives +5 max-activations to target item"),

    targetActivate = function (selfEnt, ppos, targetEnt)
        lp.modifierBuff(targetEnt, "maxActivations", 5, selfEnt)
    end
})




defineFood("lootplot.content.s0:magic_radish", {
    image = "magic_radish",
    name = loc("Magic Radish"),

    minimumLevelToSpawn = 6,
    rarity = lp.rarities.EPIC,

    targetType = "ITEM",
    targetShape = lp.targets.ABOVE_SHAPE,
    targetActivationDescription = loc("Transforms into random target item."),
    targetActivate = function(selfEnt, ppos, targetEnt)
        local selfPPos = lp.getPos(selfEnt)

        if selfPPos then
            lp.forceSpawnItem(selfPPos, server.entities[targetEnt:type()], selfEnt.lootplotTeam)
        end
    end
})






----------------------------------------------------------------------------


local function defineSlotSpawner(id_image, name, spawnSlot, spawnSlotName, targetShape, extraComponents, slotModifier)
    local entId = "lootplot.content.s0:" .. id_image
    extraComponents = extraComponents or {}

    local etype = {
        image = id_image,
        name = loc(name),

        rarity = extraComponents.rarity or lp.rarities.UNCOMMON,

        baseBuyPrice = 4,

        targetType = "NO_SLOT",
        targetActivationDescription = loc("{lp_targetColor}Spawns a " .. spawnSlotName),
        targetShape = targetShape,

        targetActivate = function (selfEnt, ppos)
            local etype = server.entities["lootplot.content.s0:" .. spawnSlot]
            assert(etype, "?")
            local slotEnt = lp.trySpawnSlot(ppos, etype, selfEnt.lootplotTeam)
            if slotModifier and slotEnt then
                slotModifier(slotEnt, ppos, selfEnt)
            end
        end
    }

    for k,v in pairs(extraComponents) do
        etype[k] = v
    end

    defineFood(entId, etype)
end



defineSlotSpawner("glass_bottle", "Glass Bottle", "glass_slot", "Glass Slot", lp.targets.PlusShape(5), {
    rarity = lp.rarities.RARE,
    minimumLevelToSpawn = 2,
})

defineSlotSpawner("glass_tube", "Glass Bottle", "glass_slot", "Glass Slot", lp.targets.CrossShape(4), {
    rarity = lp.rarities.COMMON,
    minimumLevelToSpawn = 2,
})

defineSlotSpawner("pomegranate", "Pomegranate", "slot", "Normal Slot", lp.targets.PlusShape(1), {
    minimumLevelToSpawn = 2,
})

defineSlotSpawner("stone_fruit", "Stone fruit", "null_slot", "Null Slot", lp.targets.PlusShape(1))


defineSlotSpawner("dragonfruit", "Dragonfruit", "slot", "Normal Slot", lp.targets.CrossShape(1))

defineSlotSpawner("soy_sauce", "Soy Sauce", "slot", "Doomed-4 Slot", lp.targets.PlusShape(3), {}, function(slotEnt)
    slotEnt.doomCount = 4
end)


defineSlotSpawner("coconut", "Coconut", "dirt_slot", "Dirt Slot", lp.targets.PlusShape(1), {
    rarity = lp.rarities.COMMON,
    minimumLevelToSpawn = 2,
})

----------------------------------------------------------------------------





----------------------------------------------------------------------------

local function defineSlotConverter(id_image, name, spawnSlot, spawnSlotName, targetShape, extraComponents)
    local entId = "lootplot.content.s0:" .. id_image
    extraComponents = extraComponents or {}

    local etype = {
        image = id_image,
        name = loc(name),

        targetType = "SLOT",
        targetActivationDescription = loc("{lp_targetColor}Converts target slot into " .. spawnSlotName),
        targetShape = targetShape,

        targetActivate = function (selfEnt, ppos)
            local etype = server.entities["lootplot.content.s0:" .. spawnSlot]
            assert(etype, "?")
            lp.forceSpawnSlot(ppos, etype, selfEnt.lootplotTeam)
        end
    }
    for k,v in pairs(extraComponents) do
        etype[k] = v
    end
    defineFood(entId, etype)
end


defineSlotConverter("dirty_muffin", "Dirty Muffin", "dirt_slot", "Dirt Slot", lp.targets.LARGE_KING_SHAPE, {
    rarity = lp.rarities.RARE,
    minimumLevelToSpawn = 4,
    baseBuyPrice = 2,
})

defineSlotConverter("golden_apple", "Golden Apple", "golden_slot", "Golden Slot", lp.targets.ON_SHAPE, {
    rarity = lp.rarities.UNCOMMON,
    minimumLevelToSpawn = 3,
})

defineSlotConverter("diamond_apple", "Diamond Apple", "diamond_slot", "Diamond Slot", lp.targets.ON_SHAPE, {
    rarity = lp.rarities.UNCOMMON,
    minimumLevelToSpawn = 3,
})


----------------------------------------------------------------------------


defineFood("lootplot.content.s0:super_apple", {
    image = "apple",
    name = loc("Super Apple"),

    rarity = lp.rarities.EPIC,
    minimumLevelToSpawn = 6,

    targetType = "NO_SLOT",
    targetShape = lp.targets.KING_SHAPE,
    targetActivationDescription = loc("Clones the current slot the item is in."),
    targetActivate = function(selfEnt, ppos, ent)
        local slotEnt = lp.itemToSlot(selfEnt)
        if slotEnt then
            local clone = lp.clone(selfEnt)
            local oldSlot = lp.posToSlot(ppos)
            if oldSlot then
                lp.destroy(oldSlot)
            end
            lp.setSlot(ppos, clone)
        end
    end
})

----------------------------------------------------------------------------






local function definePie(id, name, desc, giveShape)
    defineFood("lootplot.content.s0:" .. id, {
        image = id,
        name = loc(name),

        targetType = "ITEM",
        targetActivationDescription = loc("{lp_targetColor}" .. desc),
        targetShape = lp.targets.ABOVE_SHAPE,
        targetActivate = function(selfEnt, ppos, targetItemEnt)
            if targetItemEnt.targetShape then
                -- dont wanna give shape to non-shape items.
                -- HMM: Maybe this should change in future??
                lp.targets.setTargetShape(targetItemEnt, giveShape)
            end
        end
    })
end

definePie("scotch_pie", "Scotch Pie", "Gives ROOK Shape to item", lp.targets.PlusShape(10))
definePie("berry_pie", "Berry Pie", "Gives KNIGHT Shape to item", lp.targets.KNIGHT_SHAPE)

