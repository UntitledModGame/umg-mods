
local loc = localization.localize
local interp = localization.newInterpolator

local itemGenHelper = require("shared.item_gen_helper")
local newLazyGen = itemGenHelper.createLazyGenerator

local constants = require("shared.constants")


local r = lp.rarities

--[[

PLANNING:


Treasure chest:
Needs key to unlock (trigger = UNLOCK)
Spawns arbitrary item


Treasure sack:
Activates on PULSE
Spawns arbitrary item


Treasure briefcase:
Activates on PULSE
Spawns arbitrary item

]]



local dummy = function() end



local function defineTreasure(id, name, etype)
    etype = etype or {}

    etype.lootplotTags = {constants.tags.TREASURE}

    etype.name = loc(name)

    etype.image = etype.image or id

    if etype.generateTreasureItem then
        local gen = etype.generateTreasureItem
        local transform = etype.transformTreasureItem or dummy
        ---@cast transform fun(e: Entity, pp: lootplot.PPos)

        local prevOnActivate = etype.onActivate

        etype.onActivate = function(ent)
            if prevOnActivate then
                prevOnActivate(ent)
            end
            local itemId = gen(ent)
            if not itemId then return end
            local itemEtype = server.entities[itemId]
            local ppos = lp.getPos(ent)
            if ppos then
                local item = lp.forceSpawnItem(ppos, itemEtype, ent.lootplotTeam)
                if item then
                    transform(item, ppos)
                end
            end
        end
    end

    --[[
    these are "special components";
    local to these etypes specifically.
    
    Yes yes.... I know, its hacky AF. 
    (Because it looks like a shcomp, but it aint.)
    But the ergonomics are great.
    ]]
    etype.generateTreasureItem = nil
    etype.transformTreasureItem = nil

    lp.defineItem("lootplot.s0.content:" .. id, etype)
end


local function defSack(id, name, etype)
    etype.triggers = {"PULSE"}
    etype.basePrice = etype.basePrice or 12
    etype.rarity = lp.rarities.RARE
    defineTreasure(id, name, etype)
end


local function defChest(id, name, etype)
    etype.triggers = etype.triggers or {"UNLOCK"}
    etype.basePrice = etype.basePrice or 6
    etype.rarity = etype.rarity or lp.rarities.RARE
    defineTreasure(id, name, etype)
end


--[[

=============

TREASURE SACK:
Activates on PULSE: Spawns a random RARE item

FOOD SACK:
Activates on PULSE: Spawns a random FOOD item

========

TODO: think of other types of sacks!!!
We could have a lot more interesting mechanics.

INSPIRATION:
Sack-normal: Spawns a random item.
Sack-doomed: Spawns a random DOOMED item.
Sack-repeater: Spawns a random item. Gives REPEATER to spawned item
Sack-normal: Spawns a random item. Gives REROLL trigger to spawned item
Sack-golden: Spawns a random MONEY item.
Sack-of-mana: Spawns a random Mana item.
Sack-tattered: Spawns a random item. Gives the spawned item +10 max activations, and activates it 10 times.
Sack-charl: gives REROLL trigger to spawned item
Sack-delta: gives DOOMED-10 to spawned item

OR MAYBE; ALTERNATIVELY:
Sacks should randomly give spawned items properties?
EG:
10% chance to have REROLL trigger
10% chance to be repeater
10% chance to have +10 points

]]


local DEFAULT_WEIGHT = itemGenHelper.createRarityWeightAdjuster({
    COMMON = 3,
    UNCOMMON = 2,
    RARE = 1,
    EPIC = 0.333,
    LEGENDARY = 0.02,
})

---@param possibleRarities lootplot.rarities.Rarity[]
---@return fun(etype: EntityType): boolean
local function ofRarity(possibleRarities)
    ---@param etype EntityType
    return function(etype)
        for _, rar in ipairs(possibleRarities) do
            if rar == etype.rarity then
                return true
            end
        end
        return false
    end
end


-- useful helper for displaying rarities in strings
local function locRarity(txt)
    return localization.localize(txt, {
        COMMON = r.COMMON.displayString,
        UNCOMMON = r.UNCOMMON.displayString,
        RARE = r.RARE.displayString,
        EPIC = r.EPIC.displayString,
        LEGENDARY = r.LEGENDARY.displayString,
    })
end





defChest("chest_gold_small", "Small Golden Chest", {
    doomCount = 1,
    baseMoneyGenerated = 15,
    basePrice = 4,
    rarity = lp.rarities.RARE
})


defChest("chest_gold_big", "Big Golden Chest", {
    doomCount = 1,
    baseMoneyGenerated = 40,
    basePrice = 10,
    rarity = lp.rarities.EPIC
})



defChest("chest_dark", "Dark Chest", {
    rarity = lp.rarities.RARE,
    basePrice = 1,

    activateDescription = locRarity("Spawns a %{RARE} item, and {lootplot:DOOMED_LIGHT_COLOR}DESTROYS{/lootplot:DOOMED_LIGHT_COLOR} all target-items."),

    generateTreasureItem = newLazyGen(ofRarity({r.RARE}), DEFAULT_WEIGHT),

    shape = lp.targets.QueenShape(2),
    target = {
        type = "ITEM",
    }
})


defChest("chest_rare", "Rare Chest", {
    rarity = lp.rarities.UNCOMMON,
    basePrice = 2,

    activateDescription = locRarity("Spawns a %{RARE} item"),

    generateTreasureItem = newLazyGen(ofRarity({r.RARE}), DEFAULT_WEIGHT)
})

defChest("chest_epic", "Epic Chest", {
    rarity = lp.rarities.RARE,
    activateDescription = locRarity("Spawns an item that that is %{EPIC} or above"),

    generateTreasureItem = newLazyGen(ofRarity({r.EPIC, r.LEGENDARY}), DEFAULT_WEIGHT),
})


defChest("chest_food", "Food Chest", {
    rarity = lp.rarities.UNCOMMON,
    activateDescription = loc("Spawns a {lootplot:DOOMED_LIGHT_COLOR}DOOMED-1{/lootplot:DOOMED_LIGHT_COLOR} food item."),

    doomCount = 1,
    -- we only put this here to give a nice visual.
    -- (It doesn't actually do anything; but it serves as a nice indicator;
    -- to demonstrate that the spawned item will be DOOMED.)

    generateTreasureItem = newLazyGen(function(etype)
        return etype.doomCount == 1
    end, DEFAULT_WEIGHT)
})


local ABSTRACT_DESC = interp("Spawns an item of the same rarity as this chest!\n(Currently: %{rarity})")
--[[
NOTE:
make sure to test this!!!
It kinda looks a bit fragile...?
]]
---@type generation.Generator
local abstractGen
defChest("chest_abstract", "Abstract Chest", {
    rarity = lp.rarities.RARE,
    activateDescription = function(ent)
        local r1 = ent.rarity
        return ABSTRACT_DESC({
            rarity = r1.displayString
        })
    end,

    generateTreasureItem = function(ent)
        abstractGen = abstractGen or lp.newItemGenerator({})
        return abstractGen:query(function(entry)
            local etype = server.entities[entry]
            if etype and etype.rarity == ent.rarity then
                return 1
            end
            return 0
        end)
    end
})



defChest("chest_legendary", "Legendary Chest", {
    activateDescription = locRarity("Spawns a %{LEGENDARY} item."),
    rarity = lp.rarities.LEGENDARY,
    generateTreasureItem = newLazyGen(ofRarity({r.LEGENDARY}), DEFAULT_WEIGHT)
})

defChest("chest_mana", "Mana Chest", {
    triggers = {"PULSE"},
    activateDescription = locRarity("Spawns a %{RARE} item."),

    manaCost = 2,

    rarity = lp.rarities.RARE,
    generateTreasureItem = newLazyGen(ofRarity({r.RARE}), DEFAULT_WEIGHT),
})




--[[
==========================================
Sack items:
==========================================
]]

local function isFood(etype)
    return etype.doomCount == 1
end

defSack("sack_rare", "Rare Sack", {
    activateDescription = locRarity("Spawns a %{RARE} item."),

    rarity = lp.rarities.UNCOMMON,
    generateTreasureItem = newLazyGen(function (etype)
        return etype.rarity == r.RARE and (not isFood(etype))
    end, DEFAULT_WEIGHT),
})

defSack("sack_epic", "Epic Sack", {
    activateDescription = locRarity("Spawns an %{EPIC} item."),

    rarity = lp.rarities.EPIC,
    generateTreasureItem = newLazyGen(function (etype)
        return etype.rarity == r.EPIC and (not isFood(etype))
    end, DEFAULT_WEIGHT),
})

defSack("sack_food", "Food Sack", {
    activateDescription = loc("Spawns a {lootplot:DOOMED_LIGHT_COLOR}DOOMED-1{/lootplot:DOOMED_LIGHT_COLOR} food item."),
    doomCount = 1,

    basePrice = 2,

    rarity = lp.rarities.COMMON,
    generateTreasureItem = newLazyGen(isFood, DEFAULT_WEIGHT),
})

defSack("sack_ruby", "Ruby Sack", {
    activateDescription = locRarity("Spawns a %{RARE} item, and gives it {lootplot:INFO_COLOR}REPEATER."),

    rarity = lp.rarities.EPIC,
    generateTreasureItem = newLazyGen(function (etype)
        return etype.rarity == r.RARE and (not isFood(etype))
    end, DEFAULT_WEIGHT),

    repeatActivations = true,
    -- this ^^^^ shcomp doesnt actually do anything;
    -- it just serves as an indicator, so the player can visualize what item they obtain.

    baseMaxActivations = 1,

    transformTreasureItem = function(item, ppos)
        item.repeatActivations = true
        sync.syncComponent(item, "repeatActivations")
    end
})

defSack("sack_reroll", "Reroll Sack", {
    activateDescription = locRarity("Spawns a %{RARE} item, and adds {lootplot:TRIGGER_COLOR}Reroll{/lootplot:TRIGGER_COLOR} trigger to it."),

    rarity = lp.rarities.EPIC,

    generateTreasureItem = newLazyGen(function (etype)
        return etype.rarity == r.RARE and (not isFood(etype))
    end, DEFAULT_WEIGHT),

    transformTreasureItem = function(item, ppos)
        lp.addTrigger(item, "REROLL")
    end
})

defSack("sack_grubby", "Grubby Sack", {
    activateDescription = locRarity("Spawns a %{RARE} item, and gives it {lootplot:GRUB_COLOR_LIGHT}GRUB-10{/lootplot:GRUB_COLOR_LIGHT}."),

    rarity = lp.rarities.RARE,

    basePrice = 3,

    grubMoneyCap = 20,
    -- this ^^^^ shcomp serves as an indicator, 
    -- so the player can better intuit about what item is spawned.

    generateTreasureItem = newLazyGen(function (etype)
        return etype.rarity == r.RARE and (not isFood(etype))
    end, DEFAULT_WEIGHT),

    transformTreasureItem = function(item, ppos)
        item.grubMoneyCap = 10
    end
})


local ABSTRACT_SACK_DESC = interp("Spawns an item of the same rarity as this sack!\n(Currently: %{rarity})")

---@type generation.Generator
local tatteredGen
defSack("sack_tattered", "Tattered Sack", {
    rarity = lp.rarities.UNCOMMON,
    activateDescription = function(ent)
        local r1 = ent.rarity
        return ABSTRACT_SACK_DESC({
            rarity = r1.displayString
        })
    end,

    generateTreasureItem = function(ent)
        tatteredGen = tatteredGen or lp.newItemGenerator({})
        return abstractGen:query(function(entry)
            local etype = server.entities[entry]
            if etype and etype.rarity == ent.rarity then
                return 1
            end
            return 0
        end)
    end
})

