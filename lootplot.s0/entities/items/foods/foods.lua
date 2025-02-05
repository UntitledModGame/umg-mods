

local loc = localization.localize
local interp = localization.newInterpolator

local constants = require("shared.constants")

local function defineFoodNoDoomed(id, name, etype)
    etype.name = loc(name)
    etype.image = etype.image or id
    etype.baseMaxActivations = 1

    etype.lootplotTags = {constants.tags.FOOD}
    if not etype.listen then
        etype.triggers = etype.triggers or {"PULSE"}
    end

    lp.defineItem("lootplot.s0:" .. id, etype)
end



local function defineFood(id, etype)
    etype.doomCount = etype.doomCount or 1
    etype.baseMaxActivations = 1
    etype.image = etype.image or id

    etype.lootplotTags = {constants.tags.FOOD}
    if not etype.listen then
        etype.triggers = etype.triggers or {"PULSE"}
    end

    lp.defineItem("lootplot.s0:" .. id, etype)
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

    rarity = lp.rarities.RARE,

    basePrice = 10,
    shape = lp.targets.UP_SHAPE,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            local selfPPos = lp.getPos(selfEnt)
            if selfPPos then
                lp.forceCloneItem(targetEnt, selfPPos)
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
            if not selfPPos then return end

            local copyEnt = lp.forceCloneItem(targetEnt, selfPPos)
            if copyEnt and not copyEnt.doomCount then
                -- dont apply to items that are already DOOMED.
                copyEnt.doomCount = DOOMED_TURNIP_DOOMCOUNT
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

    rarity = lp.rarities.RARE,
    basePrice = 5,

    onActivate = function(selfEnt)
        local items = lp.targets.getConvertedTargets(selfEnt)
        if #items <= 0 then
            return
        end
        local itemEnt = table.random(items)
        local selfPPos = lp.getPos(selfEnt)
        if selfPPos then
            lp.forceCloneItem(itemEnt, selfPPos)
        end
    end,

    shape = lp.targets.QueenShape(3),

    target = {
        type = "ITEM"
    }
})





defineFood("green_olive", {
    name = loc("Green Olive"),
    activateDescription = loc("Gives {lootplot:TRIGGER_COLOR}REROLL{/lootplot:TRIGGER_COLOR} Trigger to target item."),

    rarity = lp.rarities.EPIC,

    basePrice = 10,

    shape = lp.targets.UP_SHAPE,
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.addTrigger(targetEnt, "REROLL")
        end
    }
})


defineFood("teal_olive", {
    name = loc("Teal Olive"),
    activateDescription = loc("Gives {lootplot:TRIGGER_COLOR}PULSE{/lootplot:TRIGGER_COLOR} Trigger to target item."),

    rarity = lp.rarities.EPIC,

    basePrice = 10,

    shape = lp.targets.UP_SHAPE,
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.addTrigger(targetEnt, "PULSE")
        end
    }
})






defineFood("eggplant", {
    name = loc("Eggplant"),
    activateDescription = loc("Give {wavy}{lootplot:DOOMED_COLOR}DOOMED-10{/lootplot:DOOMED_COLOR}{/wavy} to all target items"),

    rarity = lp.rarities.LEGENDARY,

    shape = lp.targets.UP_SHAPE,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            if targetEnt.doomCount then
                targetEnt.doomCount = 10
            end
        end
    }
})


defineFood("raspberry", {
    name = loc("Raspberry"),
    activateDescription = loc("Gives {lootplot:REPEATER_COLOR}REPEATER{/lootplot:REPEATER_COLOR} to items."),

    triggers = {"PULSE"},

    rarity = lp.rarities.RARE,

    basePrice = 8,

    shape = lp.targets.UpShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.repeatActivations = true
            sync.syncComponent(targetEnt, "repeatActivations")
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

defineFood("raw_steak", {
    name = loc("Raw Steak"),
    triggers = {"PULSE"},
    rarity = lp.rarities.RARE,
    doomCount = 1,
    baseMultGenerated = 5
})

defineFood("raw_potato", {
    name = loc("Raw Potato"),
    triggers = {"PULSE"},
    rarity = lp.rarities.RARE,
    basePointsGenerated = 60
})





----------------------------------------------------------------------------


local function defineSlotSpawner(id_image, name, spawnSlot, spawnSlotName, shape, extraComponents, slotModifier)
    extraComponents = extraComponents or {}

    local etype = {
        image = id_image,
        name = loc(name),
        activateDescription = loc("Spawns a " .. spawnSlotName),

        rarity = extraComponents.rarity or lp.rarities.UNCOMMON,

        basePrice = 5,

        target = {
            type = "NO_SLOT",
            activate = function (selfEnt, ppos)
                local etype = server.entities["lootplot.s0:" .. spawnSlot]
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
    basePrice = 10,
})

defineSlotSpawner("glass_bottle", "Glass Bottle", "glass_slot", "Glass Slot", lp.targets.QueenShape(5), {
    basePrice = 4,
    rarity = lp.rarities.RARE,
})

defineSlotSpawner("glass_tube", "Glass Bottle", "glass_slot", "Glass Slot", lp.targets.RookShape(4), {
    basePrice = 2,
    rarity = lp.rarities.UNCOMMON,
})

defineSlotSpawner("sniper_berries", "Sniper Berries", "slot", "Normal Slot", lp.targets.ON_SHAPE, {
    -- useful for bridging large gaps in land
    basePrice = 6,
    canItemFloat = true,
    rarity = lp.rarities.EPIC,
})

local STONE_FRUIT_SHAPE = lp.targets.UnionShape(lp.targets.ON_SHAPE, lp.targets.HorizontalShape(1))
defineSlotSpawner("stone_fruit", "Stone fruit", "null_slot", "Null Slot", STONE_FRUIT_SHAPE, {
    basePrice = 3,
    canItemFloat = true,
    rarity = lp.rarities.COMMON
})


defineSlotSpawner("dragonfruit", "Dragonfruit", "slot", "Normal Slot", lp.targets.RookShape(1), {
    basePrice = 12,
    rarity = lp.rarities.RARE
})

defineSlotSpawner("dragonfruit_slice", "Dragonfruit Slice", "slot", "Normal Slot", lp.targets.BishopShape(1), {
    basePrice = 15,
    rarity = lp.rarities.RARE
})

defineSlotSpawner("sausage", "Sausage", "slot", "Normal Slot", lp.targets.HorizontalShape(1), {
    init = function(ent)
        if lp.SEED:randomMisc() < 0.5 then
            lp.rotateItem(ent, 1)
        end
    end,
    basePrice = 6,
    rarity = lp.rarities.UNCOMMON
})


local function setDoomCountTo(x)
    return function(slotEnt)
        slotEnt.doomCount = x
    end
end

local function makeSticky(slotEnt)
    slotEnt.stickySlot = true
end

defineSlotSpawner("soy_sauce", "Soy Sauce", "slot", "{lootplot:DOOMED_COLOR}DOOMED-8{/lootplot:DOOMED_COLOR} Slot", lp.targets.QueenShape(3), {
    basePrice = 5
}, setDoomCountTo(8))

defineSlotSpawner("ruby_candy", "Ruby Candy", "ruby_slot", "{c r=1 b=0.2 g=0.3}Ruby{/c} {lootplot:STUCK_COLOR}STUCKY{/lootplot:STUCK_COLOR} Slot", lp.targets.RookShape(1), {
    rarity = lp.rarities.RARE,
    basePrice = 8
},
makeSticky)

defineSlotSpawner("diamond_candy", "Diamond Candy", "diamond_slot", "{c r=0.6 b=0.95 g=1}Diamond{/c} {lootplot:STUCK_COLOR}STICKY{/lootplot:STUCK_COLOR} Slot", lp.targets.RookShape(1), {
    rarity = lp.rarities.RARE,
    basePrice = 8
},
makeSticky)

--[[
TODO: could do 
gold-candy,
amethyst candy,
steel-candy in future?
]]



defineSlotSpawner("steelberry", "Steel-Berry", "steel_slot", "Steel Slot", lp.targets.HorizontalShape(1), {
    basePrice = 16,
    rarity = lp.rarities.EPIC
})


defineSlotSpawner("avacado", "Avacado", "emerald_slot", "Emerald Slot", lp.targets.RookShape(1), {
    -- maybe this should be more expensive... but i just LOVE this item sooo much
    basePrice = 12,
    rarity = lp.rarities.RARE
})


defineSlotSpawner("fried_egg", "Fried Egg", "sticky_slot", "Sticky Slot", lp.targets.KING_SHAPE, {
    basePrice = 5
})


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
    basePrice = 8,
    rarity = lp.rarities.RARE
}
defineSlotSpawner("burned_loaf", "Burned Loaf", "sell_slot", "Sell Slot",
    lp.targets.ON_SHAPE, loafEtype
)
defineSlotSpawner("golden_loaf", "Golden Loaf", "shop_slot", "Weak Shop Slot",
    lp.targets.ON_SHAPE, loafEtype
)

defineSlotSpawner("coconut", "Coconut", "dirt_slot", "Dirt Slot", lp.targets.KingShape(1), {
    basePrice = 8,
    rarity = lp.rarities.UNCOMMON,
})


defineSlotSpawner("lime", "Lime", "reroll_slot", "DOOMED-5 Reroll Slot", lp.targets.KingShape(2), {
    rarity = lp.rarities.RARE,
    basePrice = 8
}, setDoomCountTo(5))


defineSlotSpawner("lemon", "Lemon", "shop_slot", "DOOMED-4 Shop Slot", lp.targets.KingShape(1), {
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
        activateDescription = loc("Converts target slot into " .. spawnSlotName),

        shape = shape,

        target = {
            type = "SLOT",
            activate = function (selfEnt, ppos)
                local etype = server.entities["lootplot.s0:" .. spawnSlot]
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

defineSlotConverter("bananas", "Bananas", "swashbuckler_slot", "Swashbuckler Slot", lp.targets.ON_SHAPE, {
    rarity = lp.rarities.EPIC,
    basePrice = APPLE_PRICE
})

defineSlotConverter("golden_apple", "Golden Apple", "golden_slot", "Golden Slot", lp.targets.ON_SHAPE, {
    rarity = lp.rarities.RARE,
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


defineSlotConverter("cucumber_slices", "Cucumber Slices", "emerald_slot", "Emerald Slot", lp.targets.ON_SHAPE, {
    rarity = lp.rarities.RARE,
    basePrice = 6
})


defineSlotConverter("lychee", "Lychee", "pink_slot", "DOOMED-6 Pink Slot", lp.targets.ON_SHAPE, {
    rarity = lp.rarities.RARE
}, function(slotEnt)
    slotEnt.doomCount = 6
end)

----------------------------------------------------------------------------


defineFood("cloneberries", {
    name = loc("Clone-Berries"),
    activateDescription = loc("Clones the current slot the item is in."),

    rarity = lp.rarities.RARE,
    basePrice = 7,

    shape = lp.targets.BishopShape(1),

    target = {
        type = "NO_SLOT",
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
    activateDescription = loc("Clones the current slot the item is in, and gives the slot {lootplot:DOOMED_COLOR}{wavy}DOOMED-6"),

    rarity = lp.rarities.UNCOMMON,
    basePrice = 7,

    shape = lp.targets.QueenShape(2),

    target = {
        type = "NO_SLOT",
        activate = function(selfEnt, ppos, ent)
            local slotEnt = lp.itemToSlot(selfEnt)
            if slotEnt then
                local clone = lp.clone(slotEnt)
                local oldSlot = lp.posToSlot(ppos)
                if oldSlot then
                    lp.destroy(oldSlot)
                end
                lp.setSlot(ppos, clone)
                clone.doomCount = 6
            end
        end
    }
})




defineFood("golden_syrup", {
    name = loc("Golden Syrup"),
    activateDescription = loc("Gives target item/slots +2 money-earned"),

    rarity = lp.rarities.LEGENDARY,

    shape = lp.targets.UP_SHAPE,

    basePrice = 12,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function(selfEnt, ppos, ent)
            lp.modifierBuff(ent, "moneyGenerated", 2)
        end
    }
})


defineFood("slice_of_cake", {
    name = loc("Slice of Cake"),
    activateDescription = loc("Gives target item/slot {lootplot:POINTS_COLOR}+3{/lootplot:POINTS_COLOR} points"),

    rarity = lp.rarities.UNCOMMON,

    shape = lp.targets.KING_SHAPE,

    basePrice = 5,

    target = {
        type = "ITEM_OR_SLOT",
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
        activateDescription = loc(desc),

        basePrice = 6,

        rarity = rarity,

        shape = lp.targets.UP_SHAPE,

        target = {
            type = "ITEM",
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
definePie("small_rooks_pie", "Small Rook's Pie", "Adds ROOK-2 Shape to target item", lp.targets.RookShape(2), lp.rarities.UNCOMMON)
definePie("kings_pie", "King's Pie", "Adds KING-1 Shape to target item", lp.targets.KingShape(1), lp.rarities.UNCOMMON)
definePie("bishops_pie", "Bishop's Pie", "Adds BISHOP-2 Shape to target item", lp.targets.BishopShape(2), lp.rarities.UNCOMMON)

-- rare/epic pies:
definePie("knights_pie", "Knight's Pie", "Adds KNIGHT Shape to target item", lp.targets.KNIGHT_SHAPE, lp.rarities.RARE)
definePie("rooks_pie", "Rook's Pie", "Adds ROOK-5 Shape to target item", lp.targets.RookShape(4), lp.rarities.EPIC)


----------------------------------------------------------------------------

local BURGER_DESC = interp("Copies it's own shape to all target items.\n{lootplot.targets:COLOR}(Currently: %{shapeName})")

defineFood("burger", {
    name = loc("Burger"),

    basePrice = 12,

    activateDescription = function(ent)
        return BURGER_DESC({
            shapeName = ent.shape.name
        })
    end,

    shape = lp.targets.RookShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            assert(selfEnt.shape, "??")
            lp.targets.setShape(targetEnt, selfEnt.shape)
        end
    },

    rarity = lp.rarities.EPIC,
})





--[[
Potion-items should EXCLUSIVELY be used to buff items.

This gives the player great intuition about what they do.
]]

local function definePotion(name, etype)
    etype.shape = etype.shape or lp.targets.UP_SHAPE
    etype.basePrice = etype.basePrice or 3
    defineFood(name, etype)
end

definePotion("potion_green", {
    name = loc("Green Potion"),
    activateDescription = loc("Gives +5 max-activations to target item."),

    rarity = lp.rarities.RARE,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function (selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "maxActivations", 5, selfEnt)
        end
    }
})


definePotion("potion_gold", {
    name = loc("Golden Potion"),
    activateDescription = loc("Buff target item's points by the current balance."),

    rarity = lp.rarities.RARE,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function (selfEnt, ppos, targetEnt)
            local x = lp.getMoney(selfEnt) or 0
            if x > 0 then
                lp.modifierBuff(targetEnt, "pointsGenerated", x, selfEnt)
            end
        end
    }
})


definePotion("potion_sticky", {
    name = loc("Sticky Potion"),

    rarity = lp.rarities.RARE,
    activateDescription = loc("Converts STUCK to STICKY,\n(allows you to move STUCK items.)"),

    shape = lp.targets.QueenShape(2),

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
    activateDescription = loc("Permanently buffs item/slots points by {lootplot:POINTS_COLOR}+10"),

    rarity = lp.rarities.RARE,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function (selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 10, selfEnt)
        end
    }
})


definePotion("potion_red", {
    name = loc("Red Potion"),
    activateDescription = loc("Permanently buffs item/slots multiplier by {lootplot:POINTS_MULT_COLOR}+1"),

    rarity = lp.rarities.EPIC,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function (selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "multGenerated", 1, selfEnt)
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
    activateDescription = loc("Shifts target item rarity down"),

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "ITEM",
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
    activateDescription = loc("Shifts target item rarity up"),

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "ITEM",
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
    --[[
    TODO:
    This item doesnt really feel very emergent...
    maybe remove it?
    Or repurpose it.
    ]]
    name = loc("Purple Mushroom"),
    activateDescription = loc("Randomizes item rarity"),

    shape = lp.targets.KING_SHAPE,

    target = {
        type = "ITEM",
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
    activateDescription = loc("Makes target items float"),

    shape = lp.targets.UP_SHAPE,
    basePrice = 6,

    target = {
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
        activateDescription = loc(targetDesc),

        basePrice = 6,
        canItemFloat = true,

        rarity = lp.rarities.RARE,
        shape = lp.targets.KING_SHAPE,

        target = {
            type = "ITEM",
            activate = function(selfEnt, ppos, targetEnt)
                lp.modifierBuff(targetEnt, "price", buffAmount, selfEnt)
            end
        }
    }
    defineFood(id, etype)
end


defineDonut("frosted_donut", "Frosted Donut", "Decreases target item price by $5", -5)
defineDonut("pink_donut", "Pink Donut",  "Increases target item price by $8", 8)





--[[
this is a food-item; but it doesnt have DOOMED!
]]
defineFoodNoDoomed("bread", "Bread", {
    activateDescription = loc("If target item is {lootplot:DOOMED_LIGHT_COLOR}DOOMED{/lootplot:DOOMED_LIGHT_COLOR}, transforms into target item."),

    basePrice = 9,
    baseMaxActivations = 1,

    shape = lp.targets.RookShape(1),

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            return targetEnt.doomCount
        end,
        activate = function(selfEnt, ppos, targetEnt)
            local selfPPos = lp.getPos(selfEnt)
            if selfPPos then
                lp.forceCloneItem(targetEnt, selfPPos)
            end
        end
    },

    rarity = lp.rarities.RARE,
})

