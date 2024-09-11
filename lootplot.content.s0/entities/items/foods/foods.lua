

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

    shape = lp.targets.ABOVE_SHAPE,

    target = {
        type = "ITEM",
        description = loc("{lp_targetColor}Adds 2 Doom-count to item"),
        activate = function (selfEnt, ppos, targetEnt)
            if targetEnt.doomCount then
                targetEnt.doomCount = targetEnt.doomCount + 2
            end
        end
    }
})


defineFood("lootplot.content.s0:lychee", {
    image = "lychee",

    name = loc("Lychee"),

    baseTraits = {},

    rarity = lp.rarities.RARE,
    minimumLevelToSpawn = 6,

    shape = lp.targets.ABOVE_SHAPE,

    target = {
        type = "ITEM",
        description = loc("{lp_targetColor}Gives +5 max-activations to target item"),

        activate = function (selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "maxActivations", 5, selfEnt)
        end
    }
})




defineFood("lootplot.content.s0:magic_radish", {
    image = "magic_radish",
    name = loc("Magic Radish"),

    minimumLevelToSpawn = 6,
    rarity = lp.rarities.EPIC,

    shape = lp.targets.ABOVE_SHAPE,

    target = {
        type = "ITEM",
        description = loc("Transforms into random target item."),
        activate = function(selfEnt, ppos, targetEnt)
            local selfPPos = lp.getPos(selfEnt)

            if selfPPos then
                lp.forceSpawnItem(selfPPos, server.entities[targetEnt:type()], selfEnt.lootplotTeam)
            end
        end
    }
})






----------------------------------------------------------------------------


local function defineSlotSpawner(id_image, name, spawnSlot, spawnSlotName, shape, extraComponents, slotModifier)
    local entId = "lootplot.content.s0:" .. id_image
    extraComponents = extraComponents or {}

    local etype = {
        image = id_image,
        name = loc(name),

        rarity = extraComponents.rarity or lp.rarities.UNCOMMON,

        basePrice = 4,

        target = {
            type = "NO_SLOT",
            description = loc("{lp_targetColor}Spawns a " .. spawnSlotName),
            activate = function (selfEnt, ppos)
                local etype = server.entities["lootplot.content.s0:" .. spawnSlot]
                assert(etype, "?")
                local slotEnt = lp.trySpawnSlot(ppos, etype, selfEnt.lootplotTeam)
                if slotModifier and slotEnt then
                    slotModifier(slotEnt, ppos, selfEnt)
                end
            end
        },
        shape = shape,
    }

    for k,v in pairs(extraComponents) do
        etype[k] = v
    end

    defineFood(entId, etype)
end



defineSlotSpawner("glass_bottle", "Glass Bottle", "glass_slot", "Glass Slot", lp.targets.RookShape(5), {
    rarity = lp.rarities.RARE,
    minimumLevelToSpawn = 2,
})

defineSlotSpawner("glass_tube", "Glass Bottle", "glass_slot", "Glass Slot", lp.targets.BishopShape(4), {
    rarity = lp.rarities.COMMON,
    minimumLevelToSpawn = 2,
})

defineSlotSpawner("pomegranate", "Pomegranate", "slot", "Normal Slot", lp.targets.RookShape(1), {
    minimumLevelToSpawn = 2,
})

defineSlotSpawner("stone_fruit", "Stone fruit", "null_slot", "Null Slot", lp.targets.RookShape(1))


defineSlotSpawner("dragonfruit", "Dragonfruit", "slot", "Normal Slot", lp.targets.BishopShape(1))

defineSlotSpawner("soy_sauce", "Soy Sauce", "slot", "Doomed-4 Slot", lp.targets.RookShape(3), {}, function(slotEnt)
    slotEnt.doomCount = 4
end)


defineSlotSpawner("coconut", "Coconut", "dirt_slot", "Dirt Slot", lp.targets.RookShape(1), {
    rarity = lp.rarities.COMMON,
    minimumLevelToSpawn = 2,
})

----------------------------------------------------------------------------





----------------------------------------------------------------------------

local function defineSlotConverter(id_image, name, spawnSlot, spawnSlotName, shape, extraComponents)
    local entId = "lootplot.content.s0:" .. id_image
    extraComponents = extraComponents or {}

    local etype = {
        image = id_image,
        name = loc(name),

        shape = shape,

        target = {
            type = "SLOT",
            description = loc("{lp_targetColor}Converts target slot into " .. spawnSlotName),
            activate = function (selfEnt, ppos)
                local etype = server.entities["lootplot.content.s0:" .. spawnSlot]
                assert(etype, "?")
                lp.forceSpawnSlot(ppos, etype, selfEnt.lootplotTeam)
            end
        }
    }
    for k,v in pairs(extraComponents) do
        etype[k] = v
    end
    defineFood(entId, etype)
end


defineSlotConverter("dirty_muffin", "Dirty Muffin", "dirt_slot", "Dirt Slot", lp.targets.LARGE_KING_SHAPE, {
    rarity = lp.rarities.RARE,
    minimumLevelToSpawn = 4,
    basePrice = 2,
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

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "NO_SLOT",
        description = loc("Clones the current slot the item is in."),
        activate = function(selfEnt, ppos, ent)
            local slotEnt = lp.itemToSlot(selfEnt)
            if slotEnt then
                local clone = lp.clone(slotEnt)
                local oldSlot = lp.posToSlot(ppos)
                if oldSlot then
                    lp.destroy(oldSlot)
                end
                lp.setSlot(ppos, clone)
            end
        end
    }
})

----------------------------------------------------------------------------






local function definePie(id, name, desc, addShape, rarity)
    defineFood("lootplot.content.s0:" .. id, {
        image = id,
        name = loc(name),

        rarity = rarity,
        minimumLevelToSpawn = 2,

        shape = lp.targets.ABOVE_SHAPE,

        target = {
            type = "ITEM",
            description = loc("{lp_targetColor}" .. desc),
            activate = function(selfEnt, ppos, targetItemEnt)
                local oldShape = targetItemEnt.shape
                if oldShape then
                    local newShape = lp.targets.UnionShape(
                        targetItemEnt.shape,
                        addShape
                    )
                    if #newShape.relativeCoords > #oldShape.relativeCoords then
                        -- only overwrite if it changed
                        lp.targets.setShape(targetItemEnt, newShape)
                    end
                end
            end
        }
    })
end

definePie("scotch_pie", "Scotch Pie", "Adds ROOK-10 Shape to item", lp.targets.RookShape(10), lp.rarities.EPIC)
definePie("berry_pie", "Berry Pie", "Adds KNIGHT Shape to item", lp.targets.KNIGHT_SHAPE, lp.rarities.UNCOMMON)

