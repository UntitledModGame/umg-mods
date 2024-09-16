

local loc = localization.localize


local function defineFood(entName, etype)
    etype.doomCount = etype.doomCount or 1

    lp.defineItem(entName, etype)
end


defineFood("lootplot.content.s0:blueberry", {
    image = "blueberry",

    name = loc("Blueberry"),

    rarity = lp.rarities.EPIC,

    shape = lp.targets.ABOVE_SHAPE,

    target = {
        type = "ITEM_OR_SLOT",
        description = loc("{lp_targetColor}Destroys item or slot. Doubles the current point count."),

        activate = function (selfEnt, ppos, targetEnt)
            lp.destroy(targetEnt)
            local points = lp.getPoints(selfEnt)
            if points then
                lp.addPoints(selfEnt, points)
            end
        end
    }
})



--[[

CURRENTLY UNUSED:

Pear

If you come up with an idea,
These fruit(s?) are always free to be used!
]]



defineFood("lootplot.content.s0:magic_turnip", {
    image = "magic_turnip",
    name = loc("Magic Turnip"),

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




defineFood("lootplot.content.s0:heart_fruit", {
    image = "heart_fruit",
    name = loc("Heart Fruit"),

    rarity = lp.rarities.UNCOMMON,

    shape = lp.targets.ABOVE_SHAPE,

    target = {
        type = "ITEM_OR_SLOT",
        description = loc("Gives +2 lives to target."),
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.lives = (targetEnt.lives or 0) + 2
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

defineSlotSpawner("stone_fruit", "Stone fruit", "null_slot", "Null Slot", lp.targets.RookShape(1))

defineSlotSpawner("dragonfruit", "Dragonfruit", "slot", "Normal Slot", lp.targets.RookShape(1))

defineSlotSpawner("dragonfruit_slice", "Dragonfruit Slice", "slot", "Normal Slot", lp.targets.BishopShape(1))

defineSlotSpawner("soy_sauce", "Soy Sauce", "slot", "Doomed-4 Slot", lp.targets.RookShape(3), {}, function(slotEnt)
    slotEnt.doomCount = 4
end)

defineSlotSpawner("burned_loaf", "Burned Loaf", "sell_slot", "Sell Slot", 
lp.targets.OffsetShape(lp.targets.ON_SHAPE, 0, 2, "DOWN-2"), {
    doomCount = 2
})

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

defineSlotConverter("lychee", "Lychee", "pink_slot", "Pink Slot", lp.targets.ON_SHAPE, {
    rarity = lp.rarities.RARE
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

definePie("knights_pie", "Knight's Pie", "Adds KNIGHT Shape to item", lp.targets.KNIGHT_SHAPE, lp.rarities.UNCOMMON)
definePie("kings_pie", "King's Pie", "Adds KING-1 Shape to item", lp.targets.KingShape(1), lp.rarities.RARE)
definePie("rooks_pie", "Rook's Pie", "Adds ROOK-10 Shape to item", lp.targets.RookShape(10), lp.rarities.EPIC)


----------------------------------------------------------------------------






--[[
Potion-items should EXCLUSIVELY be used to buff items.

This gives the player great intuition about what they do.
]]

local function definePotion(name, etype)
    etype.shape = lp.targets.ABOVE_SHAPE
    defineFood(name, etype)
end

definePotion("lootplot.content.s0:potion_green", {
    image = "potion_green",

    name = loc("Green Potion"),

    rarity = lp.rarities.EPIC,

    target = {
        type = "ITEM_OR_SLOT",
        description = loc("{lp_targetColor}Gives +5 max-activations to target."),
        activate = function (selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "maxActivations", 5, selfEnt)
        end
    }
})



definePotion("lootplot.content.s0:potion_blue", {
    image = "potion_blue",
    name = loc("Blue Potion"),

    rarity = lp.rarities.COMMON,

    target = {
        type = "ITEM_OR_SLOT",
        description = loc("{lp_targetColor}Permanently buffs item/slots points by 5"),
        activate = function (selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 5, selfEnt)
        end
    }
})


definePotion("lootplot.content.s0:potion_red", {
    image = "potion_red",
    name = loc("Red Potion"),

    rarity = lp.rarities.EPIC,

    target = {
        type = "ITEM_OR_SLOT",
        description = loc("{lp_targetColor}Multiplies item/slots points by 1.5"),
        activate = function (selfEnt, ppos, targetEnt)
            lp.multiplierBuff(targetEnt, "pointsGenerated", 1.5, selfEnt)
        end
    }
})


--------------------------------------------------------------------------




--[[

TODO: Change mushrooms!!!

]]
---@alias lootplot.content.s0.MushArgs { property: string, buffAmount: number, description: string, buffType: "MULTIPLY" | "MODIFY"}

---@param image string
---@param name string
---@param args lootplot.content.s0.MushArgs
local function defineMush(image, name, args)
    return lp.defineItem("lootplot.content.s0:"..image, {
        image = image,
        name = loc(name),
        triggers = {"PULSE"},
        doomCount = 1,

        rarity = lp.rarities.UNCOMMON,
        minimumLevelToSpawn = 3,

        shape = lp.targets.ON_SHAPE,

        target = {
            type = "SLOT",
            description = loc(args.description),
            activate = function(selfEnt, ppos, targetEnt)
                local slotEnt = lp.itemToSlot(selfEnt)
                if slotEnt then
                    if args.buffType == "MULTIPLY" then
                        return lp.multiplierBuff(slotEnt, args.property, args.buffAmount, selfEnt)
                    else
                        return lp.modifierBuff(slotEnt, args.property, args.buffAmount, selfEnt)
                    end
                end
            end
        }
    })
end

defineMush("mushroom_red", "Red Mushroom", {
    property = "pointsGenerated",
    buffAmount = 5,
    buffType = "MODIFY",
    description = "Gives +5 points-generated to slot",
})

defineMush("mushroom_purple", "Purple Mushroom", {
    property = "pointsGenerated",
    buffAmount = 2,
    buffType = "MULTIPLY",
    description = "Multiplies slot points-generated by 2",
})

defineMush("mushroom_green", "Green Mushroom", {
    property = "moneyGenerated",
    buffAmount = 1,
    buffType = "MODIFY",
    description = "Gives +1 money-generated to slot",
})

