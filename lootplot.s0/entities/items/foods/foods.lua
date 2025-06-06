

local loc = localization.localize
local interp = localization.newInterpolator

local helper = require("shared.helper")

local itemGenHelper = require("shared.item_gen_helper")

local constants = require("shared.constants")


local numTc = typecheck.assert("number")


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
    etype.baseMaxActivations = 1
    etype.image = etype.image or id

    etype.lootplotTags = {constants.tags.FOOD}
    etype.foodItem = true

    lp.defineItem("lootplot.s0:" .. id, etype)
end



defineFood("butter", {
    name = loc("Butter"),

    basePrice = 8,
    rarity = lp.rarities.RARE,

    canItemFloat = true,

    activateDescription = loc("Doubles money.\n(Maximum of $25)."),

    onActivate = function (selfEnt)
        local money = math.min(lp.getMoney(selfEnt) or 0, 25)
        lp.addMoney(selfEnt, money)
    end
})


defineFood("cheese_slice", {
    name = loc("Cheese Slice"),

    basePrice = 0,
    rarity = lp.rarities.UNCOMMON,

    activateDescription = loc("50% chance to destroy slot.\n40% chance to earn {lootplot:MONEY_COLOR}$8{/lootplot:MONEY_COLOR}.\n10% chance to spawn a {lootplot:INFO_COLOR}key.{/lootplot:INFO_COLOR}"),

    onActivate = function (selfEnt)
        local r = lp.SEED:randomMisc()
        if r >= 0.5 then
            -- 50% chance to kill slot
            local slotEnt = lp.itemToSlot(selfEnt)
            if slotEnt then
                lp.destroy(slotEnt)
            end
        elseif r < 0.1 then
            -- spawn key
            local ppos = lp.getPos(selfEnt)
            if ppos then
                lp.forceSpawnItem(ppos, server.entities.key, selfEnt.lootplotTeam)
            end
        else
            lp.addMoney(selfEnt, 8)
        end
    end
})





local EVIL_CHEESE_SLICE_MONEY = 25
--[[
gives the player intuition about curses
]]
defineFood("evil_cheese_slice", {
    name = loc("Evil Cheese Slice"),

    basePrice = 0,
    rarity = lp.rarities.UNCOMMON,

    activateDescription = loc("50% chance to earn {lootplot:MONEY_COLOR}$%{money}{/lootplot:MONEY_COLOR}.\nSpawns a {wavy}{c r=0.8 g=0.3 b=0.1}CURSE{/c}{/wavy}!", {
        money = EVIL_CHEESE_SLICE_MONEY
    }),

    onActivate = function (selfEnt)
        if lp.SEED:randomMisc() >= 0.5 then
            lp.addMoney(selfEnt, EVIL_CHEESE_SLICE_MONEY)
        end
        local ppos = lp.getPos(selfEnt)
        if ppos then
            lp.curses.spawnRandomCurseAt(ppos, selfEnt.lootplotTeam)
        end
    end
})





defineFood("golden_horseshoe", {
    name = loc("Golden Horseshoe"),
    activateDescription = loc("50% chance to double your money.\nIf that fails, set money to 0."),

    rarity = lp.rarities.UNCOMMON,

    onActivate = function(ent)
        local SUCCESS_CHANCE = 0.55
        if lp.SEED:randomMisc() < SUCCESS_CHANCE then
            local money = lp.getMoney(ent) or 0
            lp.addMoney(ent, money)
        else
            lp.setMoney(ent, 0)
        end
        --[[
        shhhh, LMAO!! 
        Horseshoe actually has 55% success chance.
        
        To communicate, we use a secret code:

        > "In the horseshoe we trust"
        if someone says that to you, You reply with:
        > "The horseshoe trusts us"

        ^^^ this will be our secret message.
        Whatever you do, DO NOT spoil the gag in the discord.
        If you spoil, BAN BAN BAN BAN. BAAANNNN!

        (ALSO- dont worry, this is the only item in the game 
        that intentionally lies about it's description)
        ]]
    end,

    basePrice = 0,
    baseMaxActivations = 5,
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
                lp.forceCloneItem(targetEnt, selfPPos)
            end
        end
    }
})




defineFood("golden_turnip", {
    name = loc("Golden Turnip"),

    activateDescription = loc("Transforms into target item, and makes the new item cost {lootplot:MONEY_COLOR}$1{/lootplot:MONEY_COLOR} to activate"),

    rarity = lp.rarities.RARE,

    unlockAfterWins = 1,

    basePrice = 4,
    shape = lp.targets.UP_SHAPE,

    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            local selfPPos = lp.getPos(selfEnt)
            if not selfPPos then return end

            local copyEnt = lp.forceCloneItem(targetEnt, selfPPos)
            if copyEnt then
                lp.modifierBuff(copyEnt, "moneyGenerated", -1, selfEnt)
            end
        end
    }
})



local DOOMED_TURNIP_DOOMCOUNT = 5
defineFood("doomed_turnip", {
    name = loc("Doomed Turnip"),

    activateDescription = loc("Transforms into target item, and makes the new item {lootplot:DOOMED_COLOR}DOOMED-%{n}", {
        n = DOOMED_TURNIP_DOOMCOUNT
    }),
    rarity = lp.rarities.UNCOMMON,

    unlockAfterWins = 4,

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

    init = helper.rotateRandomly,

    activateDescription = loc("Clones target slot to its current position."),

    rarity = lp.rarities.EPIC,

    unlockAfterWins = 3,

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

    unlockAfterWins = 2,

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
    activateDescription = loc("Gives {lootplot:TRIGGER_COLOR}Reroll{/lootplot:TRIGGER_COLOR} Trigger to items."),

    unlockAfterWins = 2,

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


defineFood("green_squash", {
    --[[
    Gives Reroll-trigger to slots
    Sets money to $13
    ]]
    name = loc("Green Squash"),
    activateDescription = loc("Sets money to {lootplot:MONEY_COLOR}$13{/lootplot:MONEY_COLOR}\nGives {lootplot:TRIGGER_COLOR}Reroll{/lootplot:TRIGGER_COLOR} Trigger and {lootplot:POINTS_COLOR}+3 points{/lootplot:POINTS_COLOR} to slots"),

    unlockAfterWins = 2,

    rarity = lp.rarities.RARE,

    basePrice = 6,

    onActivate = function (ent)
        lp.setMoney(ent, 13)
    end,

    shape = lp.targets.KingShape(1),
    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            lp.addTrigger(targetEnt, "REROLL")
            lp.modifierBuff(targetEnt, "pointsGenerated", 3)
        end
    }
})


defineFood("red_olive", {
    name = loc("Red Olive"),
    activateDescription = loc("Gives {lootplot:TRIGGER_COLOR}Level-Up{/lootplot:TRIGGER_COLOR} Trigger to items."),

    unlockAfterWins = 3,

    rarity = lp.rarities.RARE,

    basePrice = 7,

    shape = lp.targets.KingShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.addTrigger(targetEnt, "LEVEL_UP")
        end
    }
})


defineFood("red_squash", {
    --[[
    Gives Level-Up trigger to slots
    Makes slots earn $1
    ]]
    name = loc("Red Squash"),
    activateDescription = loc("Gives {lootplot:TRIGGER_COLOR}Level-Up{/lootplot:TRIGGER_COLOR} to slots. Removes all other triggers.\nMakes slots earn {lootplot:MONEY_COLOR}$1{/lootplot:MONEY_COLOR}"),

    unlockAfterWins = 2,

    rarity = lp.rarities.RARE,

    basePrice = 12,

    shape = lp.targets.KingShape(1),
    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targEnt)
            lp.setTriggers(targEnt, {"LEVEL_UP"})
            lp.modifierBuff(targEnt, "moneyGenerated", 1)
        end
    }
})





defineFood("teal_olive", {
    name = loc("Teal Olive"),
    activateDescription = loc("Gives {lootplot:TRIGGER_COLOR}Pulse{/lootplot:TRIGGER_COLOR} Trigger to items."),

    rarity = lp.rarities.LEGENDARY,

    basePrice = 10,

    shape = lp.targets.UP_SHAPE,
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.addTrigger(targetEnt, "PULSE")
        end
    }
})



defineFood("black_olive", {
    name = loc("Black Olive"),
    activateDescription = loc("Gives {lootplot:TRIGGER_COLOR}Destroy{/lootplot:TRIGGER_COLOR} and {lootplot:TRIGGER_COLOR}Rotate{/lootplot:TRIGGER_COLOR} trigger to items."),

    unlockAfterWins = constants.UNLOCK_AFTER_WINS.DESTRUCTIVE,

    rarity = lp.rarities.RARE,

    basePrice = 10,

    shape = lp.targets.UP_SHAPE,
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.addTrigger(targetEnt, "DESTROY")
            lp.addTrigger(targetEnt, "ROTATE")
        end
    }
})







defineFood("eggplant", {
    name = loc("Eggplant"),
    activateDescription = loc("Give {wavy}{lootplot:DOOMED_COLOR}DOOMED-50{/lootplot:DOOMED_COLOR}{/wavy} to items"),

    rarity = lp.rarities.LEGENDARY,
    unlockAfterWins = 4,

    shape = lp.targets.KingShape(1),

    target = {
        type = "ITEM_OR_SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            if targetEnt.doomCount then
                targetEnt.doomCount = 50
            end
        end
    }
})


defineFood("raspberry", {
    name = loc("Raspberry"),
    activateDescription = loc("Gives {lootplot:REPEATER_COLOR}REPEATER{/lootplot:REPEATER_COLOR} to items/slots."),

    rarity = lp.rarities.EPIC,

    basePrice = 16,

    shape = lp.targets.UpShape(1),
    target = {
        type = "ITEM_OR_SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.repeatActivations = true
            sync.syncComponent(targetEnt, "repeatActivations")
        end
    }
})




do
local VALID_RARITIES = {}
do
local r = lp.rarities
VALID_RARITIES[r.COMMON] = true
VALID_RARITIES[r.UNCOMMON] = true
VALID_RARITIES[r.RARE] = true
VALID_RARITIES[r.EPIC] = true
VALID_RARITIES[r.LEGENDARY] = true
end

defineFood("fortune_cookie", {
    name=loc("Fortune Cookie"),

    activateDescription = loc("Randomizes items, preserving rarity."),
    --[[
    NOTE: doesnt work on UNIQUE items!
    that would be a recipe for DISASTER.

    So instead, we make an explicit whitelist of item rarities.
    ]]

    canItemFloat = true,

    rarity = lp.rarities.RARE,

    shape = lp.targets.KingShape(1),
    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            local r = targetEnt.rarity
            if r and VALID_RARITIES[r] then
                return true
            end
        end,
        activate = function(selfEnt, ppos, targetEnt)
            local r = targetEnt.rarity
            if not VALID_RARITIES[r] then return end
            local etype = lp.rarities.randomItemOfRarity(r)
            if etype then
                lp.forceSpawnItem(ppos, etype, targetEnt.lootplotTeam)
            end
        end
    }
})

end



defineFood("heartfruit_half", {
    name = loc("Half Heart Fruit"),
    activateDescription = loc("Gives +1 lives to target item (or slot)"),

    rarity = lp.rarities.RARE,

    unlockAfterWins = 3,

    shape = lp.targets.UP_SHAPE,

    basePrice = 3,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.lives = (targetEnt.lives or 0) + 1
        end
    },
})

defineFood("heartfruit_purple", {
    name = loc("Purple Heart Fruit"),
    activateDescription = loc("Gives {lootplot:DOOMED_COLOR}DOOMED-5{/lootplot:DOOMED_COLOR} to target item (or slot)"),

    rarity = lp.rarities.RARE,

    unlockAfterWins = 3,

    shape = lp.targets.UP_SHAPE,

    basePrice = 3,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.doomCount = 5
        end
    },
})






defineFood("coffee", {
    name = loc("Coffee"),
    rarity = lp.rarities.RARE,
    baseBonusGenerated = 40,
    baseMultGenerated = 1.5,
})

defineFood("raw_steak", {
    name = loc("Raw Steak"),
    rarity = lp.rarities.RARE,
    baseMultGenerated = 5,
    basePrice = 4,
})

defineFood("raw_potato", {
    name = loc("Raw Potato"),
    rarity = lp.rarities.RARE,
    basePointsGenerated = 250,
    basePrice = 4,
})


local SALMON_STEAK_TRIGGERS = {
    "BUY", "LEVEL_UP", "REROLL",
    -- ROTATE <-- done via lp.rotateItem
}
defineFood("salmon_steak", {
    name = loc("Salmon Steak"),
    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}Buy, Level-Up, Rotate, and Reroll{/lootplot:TRIGGER_COLOR} on targeted items."),
    rarity = lp.rarities.RARE,
    basePrice = 4,

    unlockAfterWins = 3,

    shape = lp.targets.KingShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            for _, t in ipairs(SALMON_STEAK_TRIGGERS) do
                lp.tryTriggerEntity(t, targetEnt)
            end
            lp.rotateItem(targetEnt, 1)
        end
    }
})


defineFood("salmon", {
    name = loc("Salmon"),
    activateDescription = loc("Triggers {lootplot:TRIGGER_COLOR}Pulse{/lootplot:TRIGGER_COLOR} on items, then rotates them."),

    rarity = lp.rarities.UNCOMMON,
    basePrice = 2,

    unlockAfterWins = constants.UNLOCK_AFTER_WINS.ROTATEY,

    shape = lp.targets.KingShape(1),
    target = {
        type = "ITEM",
        activate = function(selfEnt, ppos, targetEnt)
            lp.tryTriggerEntity("PULSE", targetEnt)
            lp.rotateItem(targetEnt, 1)
        end
    }
})



do

defineFood("cucumber_slices", {
    name = loc("Cucumber Slices"),
    activateDescription = loc("Replaces {lootplot:TRIGGER_COLOR}Pulse{/lootplot:TRIGGER_COLOR} with {lootplot:TRIGGER_COLOR}Reroll{/lootplot:TRIGGER_COLOR} for items"),

    rarity = lp.rarities.RARE,
    basePrice = 8,

    canItemFloat = true,

    unlockAfterWins = constants.UNLOCK_AFTER_WINS.REROLL,

    shape = lp.targets.KingShape(1),
    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targEnt)
            return lp.hasTrigger(targEnt, "PULSE")
        end,
        activate = function(selfEnt, ppos, targEnt)
            if lp.hasTrigger(targEnt, "PULSE") then
                lp.removeTrigger(targEnt, "PULSE")
                lp.addTrigger(targEnt, "REROLL")
            end
        end
    }
})

end





----------------------------------------------------------------------------


local function defineSlotSpawner(id_image, name, spawnSlot, spawnSlotName, shape, extraComponents, slotModifier)
    extraComponents = extraComponents or {}

    local etype = {
        image = id_image,
        name = loc(name),
        activateDescription = loc("Spawns " .. spawnSlotName),

        rarity = assert(extraComponents.rarity),

        basePrice = 5,

        target = {
            type = "NO_SLOT",
            filter = function (selfEnt, ppos)
                local itemEnt = lp.posToItem(ppos)
                if itemEnt and lp.curses.isCurse(itemEnt) then
                    -- not allowed to spawn slots underneath curses!
                    return false
                end
                return true
            end,
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


defineSlotSpawner("dirty_muffin", "Dirty Muffin", "dirt_slot", "Dirt Slots", lp.targets.CircleShape(2), {
    rarity = lp.rarities.RARE,
    basePrice = 10,
})

defineSlotSpawner("glass_bottle", "Glass Bottle", "glass_slot", "Glass Slots", lp.targets.QueenShape(5), {
    basePrice = 4,
    rarity = lp.rarities.RARE,
})

defineSlotSpawner("glass_tube", "Glass Tube", "glass_slot", "Glass Slots", lp.targets.RookShape(4), {
    basePrice = 2,
    rarity = lp.rarities.UNCOMMON,
})

defineSlotSpawner("sniper_berries", "Sniper Berries", "slot", "Basic Slots", lp.targets.ON_SHAPE, {
    -- useful for bridging large gaps in land
    basePrice = 6,
    canItemFloat = true,
    rarity = lp.rarities.EPIC,
})

defineSlotSpawner("ginger_roots", "Ginger Roots", "auto_stone_slot", "Stone Slots with random perks", lp.targets.HorizontalShape(3), {
    basePrice = 12,
    unlockAfterWins = 4,
    rarity = lp.rarities.RARE,
}, function(slotEnt)
    slotEnt.lives = 20
end)

local STONE_FRUIT_SHAPE = lp.targets.UnionShape(lp.targets.ON_SHAPE, lp.targets.HorizontalShape(1))
defineSlotSpawner("stone_fruit", "Stone fruit", "null_slot", "Null Slots", STONE_FRUIT_SHAPE, {
    basePrice = 6,
    basePointsGenerated = 25,
    canItemFloat = true,
    rarity = lp.rarities.UNCOMMON
})

defineSlotSpawner("chocolate_square", "Chocolate Square", "null_slot", "Null Slots with keys inside", lp.targets.UpShape(1), {
    basePrice = 6,
    canItemFloat = true,
    rarity = lp.rarities.UNCOMMON
}, function(slotEnt)
    local ppos = lp.getPos(slotEnt)
    if ppos then
        lp.trySpawnItem(ppos, server.entities.key, slotEnt.lootplotTeam)
    end
end)

local function isFoodItem(etype)
    return lp.hasTag(etype, constants.tags.FOOD)
end

local generateFoodItem = itemGenHelper.createLazyGenerator(
    isFoodItem,
    itemGenHelper.createRarityWeightAdjuster({
        COMMON = 6,
        UNCOMMON = 8,
        RARE = 1,
        EPIC = 0.3,
        LEGENDARY = 0.04
    })
)

defineSlotSpawner("sliced_stone_fruit", "Sliced Stone fruit", "null_slot", "a Null Slot with a food item", lp.targets.ON_SHAPE, {
    basePrice = 6,
    canItemFloat = true,
    basePointsGenerated = 30,
    rarity = lp.rarities.COMMON
}, function(slotEnt)
    local itemId = generateFoodItem()
    local etype = server.entities[itemId]
    local ppos = lp.getPos(slotEnt)
    if not ppos then return end
    lp.forceSpawnItem(ppos, etype, slotEnt.lootplotTeam)
end)





defineSlotSpawner("dragonfruit", "Dragonfruit", "slot", "Basic Slots", lp.targets.RookShape(1), {
    basePrice = 12,
    rarity = lp.rarities.RARE
})

defineSlotSpawner("dragonfruit_slice", "Dragonfruit Slice", "slot", "Basic Slots", lp.targets.BishopShape(1), {
    basePrice = 12,
    rarity = lp.rarities.RARE
})

defineSlotSpawner("sausage", "Sausage", "slot", "Basic Slots", lp.targets.HorizontalShape(1), {
    init = function(ent)
        if lp.SEED:randomMisc() < 0.5 then
            lp.rotateItem(ent, 1)
        end
    end,
    basePrice = 6,
    rarity = lp.rarities.COMMON
})


local function setDoomCountTo(x)
    return function(slotEnt)
        slotEnt.doomCount = x
    end
end

defineSlotSpawner("soy_sauce", "Soy Sauce", "slot", "{lootplot:DOOMED_COLOR}DOOMED-8{/lootplot:DOOMED_COLOR} Slots", lp.targets.QueenShape(3), {
    basePrice = 5,
    rarity = lp.rarities.UNCOMMON,
}, setDoomCountTo(8))

defineSlotSpawner("ruby_candy", "Ruby Candy", "ruby_slot", "{c r=1 b=0.2 g=0.3}Ruby{/c} {lootplot:DOOMED_LIGHT_COLOR}DOOMED-20{/lootplot:DOOMED_LIGHT_COLOR} Slots", lp.targets.RookShape(1), {
    rarity = lp.rarities.RARE,
    basePrice = 12
},
setDoomCountTo(20))

defineSlotSpawner("diamond_candy", "Diamond Candy", "diamond_slot", "{c r=0.6 b=0.95 g=1}Diamond{/c} {lootplot:DOOMED_LIGHT_COLOR}DOOMED-20{/lootplot:DOOMED_LIGHT_COLOR} Slots", lp.targets.RookShape(1), {
    rarity = lp.rarities.RARE,
    basePrice = 12
},
setDoomCountTo(20))

--[[
TODO: could do 
gold-candy,
amethyst candy,
steel-candy in future?
]]



defineSlotSpawner("steelberry", "Steel-Berry", "steel_slot", "Steel Slots", lp.targets.HorizontalShape(2), {
    basePrice = 15,
    rarity = lp.rarities.EPIC
})


defineSlotSpawner("avacado", "Avacado", "emerald_slot", "Emerald Slots", lp.targets.RookShape(1), {
    -- i just LOVE this item sooo much btw
    basePrice = 15,
    unlockAfterWins = 1,
    rarity = lp.rarities.RARE
})


local function buffBonus(buff)
    return function(slotEnt)
        lp.modifierBuff(slotEnt, "bonusGenerated", buff)
    end
end

defineSlotSpawner("fried_egg", "Fried Egg", "slot", "Basic Slots with -4 Bonus", lp.targets.KING_SHAPE, {
    basePrice = 7,
    rarity = lp.rarities.RARE,
}, buffBonus(-4))


defineSlotSpawner("burned_loaf", "Burned Loaf", "sell_slot", "a Sell Slot", lp.targets.ON_SHAPE, {
    canItemFloat = true,
    basePrice = 3,
    rarity = lp.rarities.UNCOMMON
})
defineSlotSpawner("golden_loaf", "Golden Loaf", "shop_slot", "a Shop Slot", lp.targets.ON_SHAPE, {
    canItemFloat = true,
    basePrice = 8,
    rarity = lp.rarities.RARE
})
defineSlotSpawner("food_loaf", "Food Loaf", "food_shop_slot", "a Food Shop Slot", lp.targets.ON_SHAPE, {
    canItemFloat = true,
    basePrice = 8,
    rarity = lp.rarities.RARE
})


defineSlotSpawner("coconut", "Coconut", "dirt_slot", "Dirt Slots", lp.targets.KingShape(1), {
    basePrice = 8,
    rarity = lp.rarities.UNCOMMON,
})


defineSlotSpawner("lime", "Lime", "reroll_slot", "DOOMED-5 Reroll Slots", lp.targets.KingShape(2), {
    rarity = lp.rarities.RARE,
    unlockAfterWins = 2,
    basePrice = 8
}, setDoomCountTo(5))


defineSlotSpawner("lemon", "Lemon", "shop_slot", "DOOMED-4 Shop Slots", lp.targets.KingShape(1), {
    rarity = lp.rarities.RARE,
    unlockAfterWins = 2,
    basePrice = 8,
    canItemFloat = true,
}, setDoomCountTo(4))

----------------------------------------------------------------------------








----------------------------------------------------------------------------

local function defineSlotConverter(id, name, spawnSlot, spawnSlotName, shape, extraComponents, slotModifier)
    extraComponents = extraComponents or {}

    local etype = {
        image = id,
        name = loc(name),
        activateDescription = loc("Force-spawns a " .. spawnSlotName),

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
defineSlotConverter("tangerine", "Tangerine", "rotate_slot", "{lootplot.targets:COLOR}Rotate{/lootplot.targets:COLOR} Slot", lp.targets.ON_SHAPE, {
    unlockAfterWins = constants.UNLOCK_AFTER_WINS.ROTATEY,
    rarity = lp.rarities.RARE,
    basePrice = APPLE_PRICE
})

defineFood("sliced_apple", {
    name = loc("Sliced Apple"),
    activateDescription = loc("Randomizes slot!"),

    unlockAfterWins = 1,

    shape = lp.targets.ON_SHAPE,
    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targEnt)
            helper.forceSpawnRandomSlot(ppos, selfEnt.lootplotTeam)
        end
    },

    rarity = lp.rarities.UNCOMMON,
    basePrice = 4
})

defineSlotConverter("bananas", "Bananas", "swashbuckler_slot", "slot where items can activate for free", lp.targets.ON_SHAPE, {
    unlockAfterWins = 3,
    rarity = lp.rarities.EPIC,
    basePrice = APPLE_PRICE
})

defineSlotConverter("blueberry", "Blueberry", "sapphire_slot", "slot that works well with {lootplot:BONUS_COLOR}negative-bonus{/lootplot:BONUS_COLOR}", lp.targets.ON_SHAPE, {
    unlockAfterWins = 3,
    rarity = lp.rarities.UNCOMMON,
    basePrice = APPLE_PRICE
})

defineSlotConverter("golden_apple", "Golden Apple", "golden_slot", "slot that multiplies item's points, but costs {lootplot:MONEY_COLOR}$1{/lootplot:MONEY_COLOR} to activate", lp.targets.ON_SHAPE, {
    unlockAfterWins = 2,
    rarity = lp.rarities.RARE,
    basePrice = APPLE_PRICE
})

defineSlotConverter("ruby_apple", "Ruby Apple", "ruby_slot", "slot that {lootplot:TRIGGER_COLOR}Pulses{/lootplot:TRIGGER_COLOR} items multiple times", lp.targets.ON_SHAPE, {
    unlockAfterWins = 1,
    rarity = lp.rarities.RARE,
    basePrice = APPLE_PRICE
})

defineSlotConverter("diamond_apple", "Diamond Apple", "diamond_slot", "slot that quadruples an item's {lootplot:BONUS_COLOR}Bonus{/lootplot:BONUS_COLOR}", lp.targets.ON_SHAPE, {
    unlockAfterWins = 2,
    rarity = lp.rarities.RARE,
    basePrice = APPLE_PRICE
})


defineSlotConverter("green_apple", "Green Apple", "emerald_slot", "slot that {lootplot:TRIGGER_COLOR}Pulses{/lootplot:TRIGGER_COLOR} items when {lootplot:TRIGGER_COLOR}Rerolled{/lootplot:TRIGGER_COLOR}", lp.targets.ON_SHAPE, {
    unlockAfterWins = 1,
    rarity = lp.rarities.RARE,
    basePrice = 6 -- should be cheaper than other apples, coz emerald slots are a bit weaker
})


defineSlotConverter("lychee", "Lychee", "pink_slot", "slot that gives {lootplot:LIFE_COLOR}lives{/lootplot:LIFE_COLOR} to items", lp.targets.ON_SHAPE, {
    unlockAfterWins = 4,
    rarity = lp.rarities.RARE
})

defineSlotConverter("purple_brain", "Purple Brain", "rulebender_slot", "Rulebender Slot", lp.targets.ON_SHAPE, {
    unlockAfterWins = 4,
    rarity = lp.rarities.EPIC,
    basePrice = APPLE_PRICE
})


----------------------------------------------------------------------------


defineFood("cloneberries", {
    name = loc("Clone-Berries"),
    activateDescription = loc("Clones the slot the item is placed in."),

    rarity = lp.rarities.RARE,
    basePrice = 13,

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
    activateDescription = loc("Clones the slot the item is placed in, and gives the new slots {lootplot:DOOMED_COLOR}{wavy}DOOMED-4"),

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
                clone.doomCount = 4
            end
        end
    }
})




defineFood("golden_syrup", {
    name = loc("Golden Syrup"),
    activateDescription = loc("Gives target item/slots {lootplot:MONEY_COLOR}+$2 money-earned{/lootplot:MONEY_COLOR}"),

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
    activateDescription = loc("Gives target item/slot {lootplot:POINTS_COLOR}+5{/lootplot:POINTS_COLOR} points"),

    rarity = lp.rarities.UNCOMMON,

    shape = lp.targets.RookShape(1),

    basePrice = 5,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function(selfEnt, ppos, ent)
            lp.modifierBuff(ent, "pointsGenerated", 5)
        end
    }
})


defineFood("red_cheesecake", {
    name = loc("Red Cheesecake"),
    activateDescription = loc("Gives items/slots {lootplot:POINTS_MULT_COLOR}+0.2 mult"),

    unlockAfterWins = 2,

    rarity = lp.rarities.RARE,

    shape = lp.targets.RookShape(1),

    basePrice = 5,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function(selfEnt, ppos, ent)
            lp.modifierBuff(ent, "multGenerated", 0.2)
        end
    }
})

defineFood("blue_cheesecake", {
    name = loc("Blue Cheesecake"),
    activateDescription = loc("Gives items/slots {lootplot:BONUS_COLOR}+1 bonus"),

    unlockAfterWins = 1,

    rarity = lp.rarities.RARE,

    shape = lp.targets.RookShape(1),

    basePrice = 5,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function(selfEnt, ppos, ent)
            lp.modifierBuff(ent, "bonusGenerated", 1)
        end
    }
})



----------------------------------------------------------------------------





do
local PIE_UNLOCK = 0

local function definePie(id, name, desc, addShape, rarity)
    defineFood(id, {
        image = id,
        name = loc(name),
        activateDescription = loc(desc),

        unlockAfterWins = PIE_UNLOCK,

        basePrice = 7,

        rarity = rarity,

        shape = lp.targets.UP_SHAPE,

        target = {
            type = "ITEM",
            filter = function(selfEnt, ppos, targetItemEnt)
                return targetItemEnt.shape
            end,
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


-- rare pies:
definePie("kings_pie", "King's Pie", "Adds {lootplot.targets:COLOR}KING-1{/lootplot.targets:COLOR} targets to item", lp.targets.KingShape(1), lp.rarities.RARE)
definePie("bishops_pie", "Bishop's Pie", "Adds {lootplot.targets:COLOR}BISHOP-2{/lootplot.targets:COLOR} targets to item", lp.targets.BishopShape(2), lp.rarities.RARE)
definePie("pi_pie", "Pi Pie", "Makes item target itself", lp.targets.ON_SHAPE, lp.rarities.RARE)

-- epic pies:
definePie("knights_pie", "Knight's Pie", "Adds {lootplot.targets:COLOR}KNIGHT{/lootplot.targets:COLOR} targets to item", lp.targets.KNIGHT_SHAPE, lp.rarities.EPIC)
definePie("rooks_pie", "Rook's Pie", "Adds {lootplot.targets:COLOR}ROOK-4{/lootplot.targets:COLOR} targets to item", lp.targets.RookShape(4), lp.rarities.EPIC)


local RANDOM_SHAPES = {
    lp.targets.HorizontalShape(3),
    lp.targets.VerticalShape(3),
    lp.targets.KingShape(1),
    lp.targets.KingShape(2),
    lp.targets.UpShape(2),
    lp.targets.DownShape(2),
    lp.targets.BishopShape(1),
    lp.targets.BishopShape(2),
    lp.targets.KNIGHT_SHAPE,
    lp.targets.QueenShape(2),
    lp.targets.RookShape(1),
    lp.targets.RookShape(2),
}

defineFood("randomizer_pie", {
    name = loc("Randomizer Pie"),

    activateDescription = loc("Randomizes item's shape"),

    unlockAfterWins = PIE_UNLOCK,

    basePrice = 7,

    rarity = lp.rarities.RARE,

    shape = lp.targets.UP_SHAPE,

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targEnt)
            return targEnt.shape
        end,
        activate = function(selfEnt, ppos, targEnt)
            if targEnt.shape then
                local shape = table.random(RANDOM_SHAPES)
                lp.targets.setShape(targEnt, shape)
            end
        end
    }
})

end



--[[
Potion-items should EXCLUSIVELY be used to buff items/slots.

This gives the player great intuition about what they do.
]]

local function definePotion(name, etype)
    if not etype.shape then
        etype.shape = lp.targets.NorthEastShape(1)
        etype.init = etype.init or helper.rotateRandomly
    end
    etype.basePrice = etype.basePrice or 3
    etype.canItemFloat = true

    defineFood(name, etype)
end


definePotion("potion_gold", {
    name = loc("Golden Potion"),
    activateDescription = loc("Buff item's points by the current balance."),

    unlockAfterWins = 1,

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

    unlockAfterWins = 2,

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
    activateDescription = loc("Permanently buffs item/slots points by {lootplot:POINTS_COLOR}+20"),

    rarity = lp.rarities.RARE,

    target = {
        type = "ITEM_OR_SLOT",
        activate = function (selfEnt, ppos, targetEnt)
            lp.modifierBuff(targetEnt, "pointsGenerated", 20, selfEnt)
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




--[[
==========================================
-- MUSHROOMS:
==========================================
]]
do

---@param id string
---@param etype table
local function defineMush(id, etype)
    etype.rarity = etype.rarity or lp.rarities.RARE
    etype.basePrice = etype.basePrice or 6
    etype.canItemFloat = true
    etype.unlockAfterWins = 3
    etype.shape = etype.shape or lp.targets.KING_SHAPE
    defineFood(id, etype)
end


local MULT_BUFF = 1.2
defineMush("mushroom_red", {
    name = loc("Red Mushroom"),
    activateDescription = loc("Gives a random slot {lootplot:POINTS_MULT_COLOR}+%{buff} mult{/lootplot:POINTS_MULT_COLOR}", {
        buff = MULT_BUFF
    }),

    onActivate = function(ent)
        local slots = lp.targets.getConvertedTargets(ent)
        if #slots > 0 then
            local slotEnt = table.random(slots)
            lp.modifierBuff(slotEnt, "multGenerated", MULT_BUFF, ent)
        end
    end,

    target = {
        type = "SLOT",
    }
})


local POINTS_BUFF = 50
defineMush("mushroom_green", {
    name = loc("Green Mushroom"),
    activateDescription = loc("Gives a random slot {lootplot:POINTS_COLOR}+%{buff} points{/lootplot:POINTS_COLOR}", {
        buff = POINTS_BUFF
    }),

    onActivate = function(ent)
        local slots = lp.targets.getConvertedTargets(ent)
        if #slots > 0 then
            local slotEnt = table.random(slots)
            lp.modifierBuff(slotEnt, "pointsGenerated", POINTS_BUFF, ent)
        end
    end,

    target = {
        type = "SLOT",
    }
})


local BONUS_BUFF = 10
defineMush("mushroom_blue", {
    name = loc("Blue Mushroom"),
    activateDescription = loc("Gives a random slot {lootplot:BONUS_COLOR}+%{buff} bonus{/lootplot:BONUS_COLOR}", {
        buff = BONUS_BUFF
    }),

    onActivate = function(ent)
        local slots = lp.targets.getConvertedTargets(ent)
        if #slots > 0 then
            local slotEnt = table.random(slots)
            lp.modifierBuff(slotEnt, "bonusGenerated", BONUS_BUFF, ent)
        end
    end,

    target = {
        type = "SLOT",
    }
})


local NUM_LIVES = 3
defineMush("mushroom_pink", {
    name = loc("Pink Mushroom"),
    activateDescription = loc("Gives {lootplot:LIFE_COLOR}+%{lives} lives{/lootplot:LIFE_COLOR} to slots.\nActivates slots.", {
        lives = NUM_LIVES
    }),

    target = {
        type = "SLOT",
        filter = function(selfEnt, ppos, targEnt)
            return (not targEnt.buttonSlot)
        end,
        activate = function(selfEnt, ppos, targetEnt)
            targetEnt.lives = (targetEnt.lives or 0) + NUM_LIVES
            lp.tryActivateEntity(targetEnt)
        end
    }
})


defineMush("mushroom_purple", {
    name = loc("Purple Mushroom"),
    activateDescription = loc("Randomizes slots!"),

    shape = lp.targets.KING_SHAPE,

    rarity = lp.rarities.EPIC,

    target = {
        type = "SLOT",
        activate = function(selfEnt, ppos, targetEnt)
            helper.forceSpawnRandomSlot(ppos, selfEnt.lootplotTeam)
        end
    }
})





defineMush("mushroom_floaty", {
    name = loc("Floaty Mushroom"),
    activateDescription = loc("Makes item float"),

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

end




----------------------------
---@param id string
---@param name string
---@param buffAmount number
---@param targetDesc string
local function defineDonut(id, name, targetDesc, buffAmount, rarity)
    local etype = {
        image = id,
        name = loc(name),
        activateDescription = loc(targetDesc),

        unlockAfterWins = 1,

        basePrice = 6,
        canItemFloat = true,

        rarity = rarity,
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


defineDonut("pink_donut", "Pink Donut", "Decreases target item price by $4", -4, lp.rarities.UNCOMMON)
defineDonut("frosted_donut", "Frosted Donut",  "Increases target item price by $8", 8, lp.rarities.RARE)





defineFoodNoDoomed("bread", "Bread", {
    activateDescription = loc("If target item is {lootplot:CONSUMABLE_COLOR_LIGHT}FOOD{/lootplot:CONSUMABLE_COLOR_LIGHT}, transforms into target item."),

    basePrice = 9,
    baseMaxActivations = 1,

    unlockAfterWins = 5,

    shape = lp.targets.RookShape(1),

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            return targetEnt.foodItem
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

