

local loc = localization.newLocalizer()


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
        description = loc("{lootplot.targets:COLOR}Destroys item or slot. Doubles the current point count."),

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
            description = loc("{lootplot.targets:COLOR}Spawns a " .. spawnSlotName),
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
})

defineSlotSpawner("glass_tube", "Glass Bottle", "glass_slot", "Glass Slot", lp.targets.BishopShape(4), {
    rarity = lp.rarities.COMMON,
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
})

----------------------------------------------------------------------------





----------------------------------------------------------------------------

local function defineSlotConverter(id_image, name, spawnSlot, spawnSlotName, shape, extraComponents, slotModifier)
    local entId = "lootplot.content.s0:" .. id_image
    extraComponents = extraComponents or {}

    local etype = {
        image = id_image,
        name = loc(name),

        shape = shape,

        target = {
            type = "SLOT",
            description = loc("{lootplot.targets:COLOR}Converts target slot into " .. spawnSlotName),
            activate = function (selfEnt, ppos)
                local etype = server.entities["lootplot.content.s0:" .. spawnSlot]
                assert(etype, "?")
                local slotEnt = lp.forceSpawnSlot(ppos, etype, selfEnt.lootplotTeam)
                if slotModifier and slotEnt then
                    slotModifier(slotEnt)
                end
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
    basePrice = 2,
})

defineSlotConverter("golden_apple", "Golden Apple", "golden_slot", "Golden Slot", lp.targets.ON_SHAPE, {
    rarity = lp.rarities.UNCOMMON,
})

defineSlotConverter("diamond_apple", "Diamond Apple", "diamond_slot", "Diamond Slot", lp.targets.ON_SHAPE, {
    rarity = lp.rarities.EPIC,
})

defineSlotConverter("lychee", "Lychee", "pink_slot", "DOOMED-5 Pink Slot", lp.targets.ON_SHAPE, {
    rarity = lp.rarities.RARE
}, function(slotEnt)
    slotEnt.doomCount = 5
end)

----------------------------------------------------------------------------


defineFood("lootplot.content.s0:super_apple", {
    image = "apple",
    name = loc("Super Apple"),

    rarity = lp.rarities.EPIC,

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

        shape = lp.targets.ABOVE_SHAPE,

        target = {
            type = "ITEM",
            description = loc("{lootplot.targets:COLOR}" .. desc),
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
definePie("rooks_pie", "Rook's Pie", "Adds ROOK-4 Shape to item", lp.targets.RookShape(4), lp.rarities.EPIC)


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
        description = loc("{lootplot.targets:COLOR}Gives +5 max-activations to target."),
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
        description = loc("{lootplot.targets:COLOR}Permanently buffs item/slots points by 5"),
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
        description = loc("{lootplot.targets:COLOR}Multiplies item/slots points by 1.5"),
        activate = function (selfEnt, ppos, targetEnt)
            lp.multiplierBuff(targetEnt, "pointsGenerated", 1.5, selfEnt)
        end
    }
})


--------------------------------------------------------------------------





---@param id string
---@param etype table
local function defineMush(id, etype)
    etype.image = id
    etype.rarity = lp.rarities.RARE
    defineFood("lootplot.content.s0:" .. id, etype)
end

defineMush("mushroom_red", {
    name = loc("Red Mushroom"),

    shape = lp.targets.ABOVE_SHAPE,

    target = {
        type = "ITEM",
        description = loc("Shifts item rarity down by 1"),
        filter = function (selfEnt, ppos, targetEnt)
            return targetEnt.rarity
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.rarities.setEntityRarity(
                targetEnt,
                lp.rarities.shiftRarity(targetEnt.rarity, -1)
            )
        end
    }
})

defineMush("mushroom_green", {
    name = loc("Green Mushroom"),
    shape = lp.targets.ABOVE_SHAPE,

    target = {
        type = "ITEM",
        description = loc("Shifts item rarity up by 1"),
        filter = function (selfEnt, ppos, targetEnt)
            return targetEnt.rarity
        end,
        activate = function(selfEnt, ppos, targetEnt)
            lp.rarities.setEntityRarity(
                targetEnt,
                lp.rarities.shiftRarity(targetEnt.rarity, 1)
            )
        end
    }
})

defineMush("mushroom_purple", {
    name = loc("Purple Mushroom"),
    shape = lp.targets.ABOVE_SHAPE,

    target = {
        type = "ITEM",
        description = loc("Randomizes item rarity"),
        filter = function (selfEnt, ppos, targetEnt)
            return targetEnt.rarity
        end,
        activate = function(selfEnt, ppos, targetEnt)
            local randomRarity = table.random(lp.rarities.RARITY_LIST)
            lp.rarities.setEntityRarity(targetEnt, randomRarity)
        end
    }
})






----------------------------
---@param id string
---@param name string
---@param buffAmount number
---@param targetDesc string
local function defineDonut(id, name, targetDesc, buffAmount)
    local etype = {
        image = id,
        name = loc(name),

        rarity = lp.rarities.RARE,
        shape = lp.targets.KING_SHAPE,

        target = {
            description = loc(targetDesc),
            activate = function(selfEnt, ppos, targetEnt)
                lp.modifierBuff(targetEnt, "price", buffAmount, selfEnt)
            end
        }
    }
    defineFood("lootplot.content.s0:" .. id, etype)
end


defineDonut("frosted_donut", "Frosted Donut", "Decreases item price by $5", -5)
defineDonut("pink_donut", "Pink Donut",  "Increases item price by $5", 5)

