

local loc = localization.localize
local constants = require("shared.constants")


local function defineFood(id, etype)
    etype.doomCount = etype.doomCount or 1
    etype.image = etype.image or id
    etype.baseMaxActivations = 1

    etype.lootplotTags = {constants.tags.FOOD}
    if not etype.listen then
        etype.triggers = etype.triggers or {"PULSE"}
    end

    lp.defineItem("lootplot.s0.content:" .. id, etype)
end


defineFood("blueberry", {
    name = loc("Blueberry"),

    basePrice = 8,
    rarity = lp.rarities.EPIC,

    activateDescription = loc("Doubles the current point count."),

    onActivate = function (selfEnt)
        local points = lp.getPoints(selfEnt)
        if points then
            lp.addPoints(selfEnt, points)
        end
    end
})


defineFood("butter", {
    name = loc("Butter"),

    basePrice = 8,
    rarity = lp.rarities.RARE,

    activateDescription = loc("Doubles money.\n(Maximum of $25)."),

    onActivate = function (selfEnt)
        local money = math.min(lp.getMoney(selfEnt) or 0, 25)
        lp.addMoney(selfEnt, money)
    end
})





--[[

CURRENTLY UNUSED:

Pear
Honey-bottle

If you come up with an idea,
These food(s?) are always free to be used!
]]



defineFood("magic_turnip", {
    name = loc("Magic Turnip"),

    activateDescription = loc("Transforms into target item."),

    rarity = lp.rarities.EPIC,

    basePrice = 10,
    shape = lp.targets.UP_SHAPE,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            local selfPPos = lp.getPos(selfEnt)
            if selfPPos then
                lp.destroy(selfEnt)
                local copyEnt = lp.clone(targetEnt)
                local success = lp.trySetItem(selfPPos, copyEnt)
                if not success then
                    copyEnt:delete()
                end
            end
        end
    }
})


local DOOMED_TURNIP_DOOMCOUNT = 5
defineFood("doomed_turnip", {
    name = loc("Doomed Turnip"),

    activateDescription = loc("Transforms into target item, and makes the transform item {lootplot:DOOMED_COLOR}DOOMED"),
    rarity = lp.rarities.UNCOMMON,

    basePrice = 4,
    shape = lp.targets.UP_SHAPE,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            local selfPPos = lp.getPos(selfEnt)
            if selfPPos then
                lp.destroy(selfEnt)
                local copyEnt = lp.clone(targetEnt)
                local success = lp.trySetItem(selfPPos, copyEnt)
                if not copyEnt.doomCount then
                    -- dont apply to items that are already DOOMED.
                    copyEnt.doomCount = DOOMED_TURNIP_DOOMCOUNT
                end
                if not success then
                    copyEnt:delete()
                end
            end
        end
    }
})

defineFood("slot_turnip", {
    name = loc("Slot Turnip"),

    activateDescription = loc("Clones target slot to its current position."),

    rarity = lp.rarities.EPIC,

    basePrice = 10,
    canItemFloat = true,

    shape = lp.targets.UP_SHAPE,

    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            local selfPPos = lp.getPos(selfEnt)
            if selfPPos then
                lp.destroy(selfEnt)
                local copyEnt = lp.clone(targetEnt)
                lp.setSlot(selfPPos, copyEnt)
            end
        end
    }
})

defineFood("gray_turnip", {
    name = loc("Gray Turnip"),

    activateDescription = loc("Transforms into a random target item."),

    rarity = lp.rarities.UNCOMMON,
    basePrice = 4,

    onActivate = function(ent)
        umg.melt([[
            todo: implement this! (turn into a random item)
        ]])
    end,

    shape = lp.targets.QueenShape(3),

    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            local selfPPos = lp.getPos(selfEnt)
            if selfPPos then
                lp.destroy(selfEnt)
                local copyEnt = lp.clone(targetEnt)
                local success = lp.trySetItem(selfPPos, copyEnt)
                if not success then
                    copyEnt:delete()
                end
            end
        end
    }
})






defineFood("green_olive", {
    name = loc("Green Olive"),

    rarity = lp.rarities.EPIC,

    shape = lp.targets.UP_SHAPE,

    basePrice = 2,

    target = {
        type = "ITEM",
        description = loc("Gives REROLL Trigger to target item."),
        activate = function(selfEnt, ppos, targetEnt)
            lp.addTrigger(targetEnt, "REROLL")
        end
    }
})




defineFood("eggplant", {
    name = loc("Eggplant"),

    rarity = lp.rarities.LEGENDARY,

    shape = lp.targets.UP_SHAPE,

    target = {
        type = "ITEM_OR_SLOT",
        description = loc("Give {wavy}{lootplot:DOOMED_COLOR}DOOMED-10{/lootplot:DOOMED_COLOR}{/wavy} to target"),
        activate = function(selfEnt, ppos, targetEnt)
            if targetEnt.doomCount then
                targetEnt.doomCount = 10
            end
        end
    }
})



defineFood("heartfruit", {
    name = loc("Heart Fruit"),
    activateDescription = loc("Gives +1 lives to target item (or slot)"),

    rarity = lp.rarities.RARE,

    shape = lp.targets.UpShape(2),

    basePrice = 6,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.lives = (targetEnt.lives or 0) + 1
        end
    },
})


defineFood("heartfruit_half", {
    name = loc("Half Heart Fruit"),
    activateDescription = loc("Gives +1 lives to target item (or slot)"),

    rarity = lp.rarities.UNCOMMON,

    shape = lp.targets.UP_SHAPE,

    basePrice = 4,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.lives = (targetEnt.lives or 0) + 1
        end
    },
})

defineFood("heartfruit_purple", {
    name = loc("Purple Heart Fruit"),
    activateDescription = loc("Gives {lootplot:DOOMED_COLOR}DOOMED-2{/lootplot:DOOMED_COLOR} to target item (or slot)"),

    rarity = lp.rarities.UNCOMMON,

    shape = lp.targets.UP_SHAPE,

    basePrice = 3,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.doomCount = 2
        end
    },
})






defineFood("coffee", {
    name = loc("Coffee"),
    activateDescription = loc("Multiplies current multiplier by {lootplot:POINTS_MULT_COLOR}1.5x"),
    triggers = {"PULSE"},
    rarity = lp.rarities.RARE,
    onActivate = function(self)
        local gmul = lp.getPointsMult(self)
        return lp.setPointsMult(self, gmul * 1.5)
    end
})

defineFood("tricolor_dango", { -- Loved by an introverted Shogun in another dimension
    name = loc("Tricolor Dango"),
    triggers = {"PULSE"},
    rarity = lp.rarities.RARE,
    doomCount = 3,
    baseMaxActivations = 3,
    baseMultGenerated = 1
})





----------------------------------------------------------------------------


local function defineSlotSpawner(id_image, name, spawnSlot, spawnSlotName, shape, extraComponents, slotModifier)
    extraComponents = extraComponents or {}

    local etype = {
        image = id_image,
        name = loc(name),

        rarity = extraComponents.rarity or lp.rarities.UNCOMMON,

        basePrice = 5,

        target = {
            type = "NO_SLOT",
            description = loc("Spawns a " .. spawnSlotName),
            activate = function (selfEnt, ppos)
                local etype = server.entities["lootplot.s0.content:" .. spawnSlot]
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

    defineFood(id_image, etype)
end


defineSlotSpawner("dirty_muffin", "Dirty Muffin", "dirt_slot", "Dirt Slot", lp.targets.CircleShape(2), {
    rarity = lp.rarities.RARE,
})

defineSlotSpawner("glass_bottle", "Glass Bottle", "glass_slot", "Glass Slot", lp.targets.QueenShape(5), {
    rarity = lp.rarities.RARE,
})

defineSlotSpawner("glass_tube", "Glass Bottle", "glass_slot", "Glass Slot", lp.targets.RookShape(4), {
    basePrice = 3,
    rarity = lp.rarities.UNCOMMON,
})

defineSlotSpawner("sniper_fruit", "Sniper Fruit", "slot", "Normal Slot", lp.targets.ON_SHAPE, {
    -- useful for bridging large gaps in land
    basePrice = 4,
    canItemFloat = true,
    rarity = lp.rarities.EPIC,
})

defineSlotSpawner("stone_fruit", "Stone fruit", "null_slot", "Null Slot", lp.targets.ON_SHAPE, {
    basePrice = 2,
    canItemFloat = true,
    rarity = lp.rarities.UNCOMMON
})

defineSlotSpawner("dragonfruit", "Dragonfruit", "slot", "Normal Slot", lp.targets.RookShape(1), {
    basePrice = 5,
    rarity = lp.rarities.COMMON
})

defineSlotSpawner("dragonfruit_slice", "Dragonfruit Slice", "slot", "Normal Slot", lp.targets.BishopShape(1), {
    basePrice = 6,
    rarity = lp.rarities.RARE
})


local function setDoomCountTo(x)
    return function(slotEnt)
        slotEnt.doomCount = x
    end
end
defineSlotSpawner("soy_sauce", "Soy Sauce", "slot", "{lootplot:DOOMED_COLOR}DOOMED-8{/lootplot:DOOMED_COLOR} Slot", 
    lp.targets.QueenShape(3), {},
    setDoomCountTo(8)
)

defineSlotSpawner("ruby_candy", "Ruby Candy", "ruby_slot", "{c r=1 b=0.2 g=0.3}Ruby{/c} {lootplot:DOOMED_COLOR}DOOMED-25{/lootplot:DOOMED_COLOR} Slot", lp.targets.RookShape(1), {
    rarity = lp.rarities.RARE
},
setDoomCountTo(25))

defineSlotSpawner("diamond_candy", "Diamond Candy", "diamond_slot", "{c r=0.6 b=0.95 g=1}Diamond{/c} {lootplot:DOOMED_COLOR}DOOMED-25{/lootplot:DOOMED_COLOR} Slot", lp.targets.RookShape(1), {
    rarity = lp.rarities.RARE
},
setDoomCountTo(25))

--[[
TODO: could do 
gold-candy,
amethyst candy,
steel-candy in future?
]]



defineSlotSpawner("steelberry", "Steel-Berry", "steel_slot", "Steel Slot", lp.targets.RookShape(1), {
    basePrice = 9,
    rarity = lp.rarities.RARE
})


defineSlotSpawner("avacado", "Avacado", "emerald_slot", "Emerald Slot", lp.targets.RookShape(2), {
    basePrice = 8,
    rarity = lp.rarities.RARE
})


defineSlotSpawner("fried_egg", "Fried Egg", "slot", "Slot with -10 points", lp.targets.KING_SHAPE, {}, function(slotEnt)
    lp.modifierBuff(slotEnt, "pointsGenerated", -10)
end)


local loafEtype = {
    init = function(ent)
        if math.random() < 0.01 then
            -- silly easter egg:
            -- XBOX Color!!! 
            -- (coz the sprite looks like xbox logo, lol)
            ent.color = objects.Color.GREEN
        end
    end,
    canItemFloat = true,
    rarity = lp.rarities.RARE
}
defineSlotSpawner("burned_loaf", "Burned Loaf", "sell_slot", "Sell Slot",
    lp.targets.ON_SHAPE, loafEtype
)
defineSlotSpawner("golden_loaf", "Golden Loaf", "weak_shop_slot", "Shop Slot",
    lp.targets.ON_SHAPE, loafEtype
)

defineSlotSpawner("coconut", "Coconut", "dirt_slot", "Dirt Slot", lp.targets.KingShape(1), {
    rarity = lp.rarities.UNCOMMON,
})


defineSlotSpawner("lime", "Lime", "reroll_slot", "DOOMED-5 Reroll Slot", lp.targets.KingShape(2), {
    rarity = lp.rarities.RARE,
    basePrice = 8
}, setDoomCountTo(5))


defineSlotSpawner("lemon", "Lemon", "strong_shop_slot", "DOOMED-4 Shop Slot", lp.targets.KingShape(1), {
    rarity = lp.rarities.RARE,
    basePrice = 8
}, setDoomCountTo(2))

----------------------------------------------------------------------------





----------------------------------------------------------------------------

local function defineSlotConverter(id, name, spawnSlot, spawnSlotName, shape, extraComponents, slotModifier)
    extraComponents = extraComponents or {}

    local etype = {
        image = id,
        name = loc(name),

        shape = shape,

        target = {
            type = "SLOT",
            description = loc("Converts target slot into " .. spawnSlotName),
            activate = function (selfEnt, ppos)
                local etype = server.entities["lootplot.s0.content:" .. spawnSlot]
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
    defineFood(id, etype)
end


local APPLE_PRICE = 10
defineSlotConverter("tangerine", "Tangerine", "rotate_slot", "Rotate Slot", lp.targets.ON_SHAPE, {
    rarity = lp.rarities.RARE,
    basePrice = APPLE_PRICE
})

defineSlotConverter("sliced_apple", "Sliced Apple", "item_pulse_button_slot", "Item {lootplot:TRIGGER_COLOR}Pulse{/lootplot:TRIGGER_COLOR} Button", lp.targets.ON_SHAPE, {
    rarity = lp.rarities.RARE,
    basePrice = APPLE_PRICE
})

defineSlotConverter("golden_apple", "Golden Apple", "golden_slot", "Golden Slot", lp.targets.ON_SHAPE, {
    rarity = lp.rarities.UNCOMMON,
    basePrice = APPLE_PRICE
})

defineSlotConverter("ruby_apple", "Ruby Apple", "ruby_slot", "Ruby Slot", lp.targets.ON_SHAPE, {
    rarity = lp.rarities.RARE,
    basePrice = APPLE_PRICE
})

defineSlotConverter("diamond_apple", "Diamond Apple", "diamond_slot", "Diamond Slot", lp.targets.ON_SHAPE, {
    rarity = lp.rarities.RARE,
    basePrice = APPLE_PRICE
})


defineSlotConverter("cucumber_slices", "Cucumber Slices", "reroll_slot", "{lootplot:DOOMED_COLOR}DOOMED-20{/lootplot:DOOMED_COLOR} Reroll Slot", lp.targets.ON_SHAPE, {
    rarity = lp.rarities.RARE,
    basePrice = 6
}, setDoomCountTo(20))


defineSlotConverter("lychee", "Lychee", "pink_slot", "DOOMED-6 Pink Slot", lp.targets.ON_SHAPE, {
    rarity = lp.rarities.RARE
}, function(slotEnt)
    slotEnt.doomCount = 6
end)

----------------------------------------------------------------------------


defineFood("cloneberries", {
    name = loc("Clone-Berries"),

    rarity = lp.rarities.RARE,
    basePrice = 7,

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

defineFood("doomed_cloneberries", {
    name = loc("Doomed Clone-Berries"),

    rarity = lp.rarities.UNCOMMON,
    basePrice = 7,

    shape = lp.targets.QueenShape(2),

    target = {
        type = "NO_SLOT",
        description = loc("Clones the current slot the item is in, and gives the slot {lootplot:DOOMED_COLOR}{wavy}DOOMED-10"),
        activate = function(selfEnt, ppos, ent)
            local slotEnt = lp.itemToSlot(selfEnt)
            if slotEnt then
                local clone = lp.clone(slotEnt)
                local oldSlot = lp.posToSlot(ppos)
                if oldSlot then
                    lp.destroy(oldSlot)
                end
                lp.setSlot(ppos, clone)
                clone.doomCount = 10
            end
        end
    }
})




defineFood("golden_syrup", {
    --[[
    is this item too OP?
    probably, honestly. Oh well
    ]]
    name = loc("Golden Syrup"),

    rarity = lp.rarities.EPIC,

    shape = lp.targets.UP_SHAPE,

    basePrice = 12,

    target = {
        type = "ITEM_OR_SLOT",
        description = loc("Gives target item/slot +1 money-earned"),
        activate = function(selfEnt, ppos, ent)
            lp.modifierBuff(ent, "moneyGenerated", 1)
        end
    }
})


defineFood("slice_of_cake", {
    name = loc("Slice of Cake"),

    rarity = lp.rarities.UNCOMMON,

    shape = lp.targets.KING_SHAPE,

    basePrice = 5,

    target = {
        type = "ITEM_OR_SLOT",
        description = loc("Gives target item/slot {lootplot:POINTS_COLOR}+3{/lootplot:POINTS_COLOR} points"),
        activate = function(selfEnt, ppos, ent)
            lp.modifierBuff(ent, "pointsGenerated", 3)
        end
    }
})



----------------------------------------------------------------------------






local function definePie(id, name, desc, addShape, rarity)
    defineFood(id, {
        image = id,
        name = loc(name),

        basePrice = 6,

        rarity = rarity,

        shape = lp.targets.UP_SHAPE,

        target = {
            type = "ITEM",
            description = loc(desc),
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

-- uncommon pies:
definePie("small_rooks_pie", "Small Rook's Pie", "Adds ROOK-2 Shape to item", lp.targets.RookShape(2), lp.rarities.UNCOMMON)
definePie("kings_pie", "King's Pie", "Adds KING-1 Shape to item", lp.targets.KingShape(1), lp.rarities.UNCOMMON)
definePie("bishops_pie", "Bishop's Pie", "Adds BISHOP-2 Shape to item", lp.targets.BishopShape(2), lp.rarities.UNCOMMON)

-- rare/epic pies:
definePie("knights_pie", "Knight's Pie", "Adds KNIGHT Shape to item", lp.targets.KNIGHT_SHAPE, lp.rarities.RARE)
definePie("rooks_pie", "Rook's Pie", "Adds ROOK-5 Shape to item", lp.targets.RookShape(4), lp.rarities.EPIC)


----------------------------------------------------------------------------






--[[
Potion-items should EXCLUSIVELY be used to buff items.

This gives the player great intuition about what they do.
]]

local function definePotion(name, etype)
    etype.shape = lp.targets.UP_SHAPE
    etype.basePrice = etype.basePrice or 3
    defineFood(name, etype)
end

definePotion("potion_green", {
    name = loc("Green Potion"),

    rarity = lp.rarities.RARE,

    target = {
        type = "ITEM_OR_SLOT",
        description = loc("Gives +5 max-activations to target."),
        activate = function (selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "maxActivations", 5, selfEnt)
        end
    }
})



definePotion("potion_sticky", {
    name = loc("Sticky Potion"),

    rarity = lp.rarities.RARE,
    activateDescription = loc("Converts STUCK to STICKY,\n(allows you to move STUCK items.)"),

    target = {
        type = "ITEM",
        filter = function (selfEnt, ppos, targetEnt)
            return targetEnt.stuck
        end,
        activate = function (selfEnt, ppos, targetEnt)
            targetEnt.stuck = false
            targetEnt.sticky = true
        end
    }
})



definePotion("potion_blue", {
    name = loc("Blue Potion"),

    rarity = lp.rarities.RARE,

    target = {
        type = "ITEM_OR_SLOT",
        description = loc("Permanently buffs item/slots points by 10"),
        activate = function (selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 10, selfEnt)
        end
    }
})


definePotion("potion_red", {
    name = loc("Red Potion"),

    rarity = lp.rarities.EPIC,

    target = {
        type = "ITEM_OR_SLOT",
        description = loc("If item/slot generates less than 10 points, Buff target's points by 100"),
        activate = function (selfEnt, ppos, targetEnt)
            local x = targetEnt.pointsGenerated or 0
            if x < 10 then
                lp.modifierBuff(targetEnt, "pointsGenerated", 100, selfEnt)
            end
        end
    }
})



--------------------------------------------------------------------------





---@param id string
---@param etype table
local function defineMush(id, etype)
    etype.rarity = etype.rarity or lp.rarities.RARE
    etype.basePrice = etype.basePrice or 2
    defineFood(id, etype)
end

defineMush("mushroom_red", {
    name = loc("Red Mushroom"),
    shape = lp.targets.KING_SHAPE,

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
    shape = lp.targets.KING_SHAPE,

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
    shape = lp.targets.KING_SHAPE,

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



defineMush("mushroom_floaty", {
    name = loc("Floaty Mushroom"),
    shape = lp.targets.UP_SHAPE,
    basePrice = 6,

    target = {
        description = loc("Allows item to float"),
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.canItemFloat = true
            sync.syncComponent(targetEnt, "canItemFloat")
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

        basePrice = 4,
        canItemFloat = true,

        rarity = lp.rarities.RARE,
        shape = lp.targets.KING_SHAPE,

        target = {
            type = "ITEM",
            description = loc(targetDesc),
            activate = function(selfEnt, ppos, targetEnt)
                lp.modifierBuff(targetEnt, "price", buffAmount, selfEnt)
            end
        }
    }
    defineFood(id, etype)
end


defineDonut("frosted_donut", "Frosted Donut", "Decreases item price by $10", -10)
defineDonut("pink_donut", "Pink Donut",  "Increases item price by $10", 10)

