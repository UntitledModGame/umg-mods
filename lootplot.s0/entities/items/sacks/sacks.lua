

local loc = localization.localize
local interp = localization.newInterpolator

local itemGenHelper = require("shared.item_gen_helper")
local helper = require("shared.helper")
local newLazyGen = itemGenHelper.createLazyGenerator

local constants = require("shared.constants")


local r = lp.rarities


local dummy = function() end



---@param ppos lootplot.PPos?
---@param ent lootplot.ItemEntity
---@param gen generation.Generator
---@param transform function
local function trySpawnCloudWithItem(ppos, ent, gen, transform)
    if not ppos then
        return
    end
    local itemId = gen(ent)
    if not itemId then
        return
    end
    local itemEtype = server.entities[itemId]
    local success = lp.trySpawnSlot(ppos, server.entities.cloud_slot, ent.lootplotTeam)
    if success then
        local item = lp.forceSpawnItem(ppos, itemEtype, ent.lootplotTeam)
        if item then
            transform(item, ppos)
        end
    end
end



local HORIZONTAL_SACK_SHAPE = lp.targets.UnionShape(
    lp.targets.HorizontalShape(1),
    lp.targets.ON_SHAPE
)


local VERTICAL_SACK_SHAPE = lp.targets.UnionShape(
    lp.targets.VerticalShape(1),
    lp.targets.ON_SHAPE
)

local function canSpawnCloudSlot(selfEnt, ppos)
    local itemEnt = lp.posToItem(ppos)
    local slotEnt = lp.posToSlot(ppos)
    local slotOK = (not slotEnt)
    local itemOK = (not itemEnt) or (itemEnt == selfEnt)
    return slotOK and itemOK
end



local function defSack(id, name, etype)
    etype = etype or {}

    etype.basePrice = etype.basePrice or 12
    etype.rarity = etype.rarity or lp.rarities.RARE
    etype.canItemFloat = true
    etype.name = loc(name)

    etype.activateInstantly = true

    etype.shape = etype.shape or HORIZONTAL_SACK_SHAPE

    etype.lootplotTags = {constants.tags.TREASURE}

    etype.name = loc(name)

    etype.image = etype.image or id

    etype.onPostActivate = function(ent)
        lp.destroy(ent)
    end

    if etype.generateSackItem then
        local gen = etype.generateSackItem
        local transform = etype.transformTreasureItem or dummy
        ---@cast transform fun(e: Entity, pp: lootplot.PPos)

        etype.target = {
            type = "NO_SLOT",
            filter = function(selfEnt, ppos)
                local item = lp.posToItem(ppos)
                return (not item) or item == selfEnt
            end,
        }

        etype.canActivate = function(selfEnt)
            -- only activates when floating
            return (not lp.itemToSlot(selfEnt))
        end

        etype.onActivate = function(selfEnt)
            local targs = lp.targets.getTargets(selfEnt) or {}
            for _,ppos in ipairs(targs) do
                if canSpawnCloudSlot(selfEnt, ppos) then
                    trySpawnCloudWithItem(ppos, selfEnt, gen, transform)
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
    etype.generateSackItem = nil
    etype.transformTreasureItem = nil

    lp.defineItem("lootplot.s0:" .. id, etype)
end



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
local function locRarity(txt, t)
    local args = {
        COMMON = r.COMMON.displayString,
        UNCOMMON = r.UNCOMMON.displayString,
        RARE = r.RARE.displayString,
        EPIC = r.EPIC.displayString,
        LEGENDARY = r.LEGENDARY.displayString,
    }
    if t then
        for k,v in pairs(t) do
            args[k] = v
        end
    end
    return localization.localize(txt, args)
end




--[[
==========================================
Sack items:
==========================================
]]

local function isFood(etype)
    return etype.foodItem
end

defSack("sack_rare", "Rare Sack", {
    activateDescription = locRarity("Spawns %{RARE} items to choose from.\nMust be placed in the air!"),

    basePrice = 12,
    rarity = lp.rarities.COMMON,
    generateSackItem = newLazyGen(function (etype)
        return etype.rarity == r.RARE and (not isFood(etype))
    end, DEFAULT_WEIGHT),
})



defSack("sack_uncommon", "Uncommon Sack", {
    activateDescription = locRarity("Spawns %{UNCOMMON} items to choose from.\nMust be placed in the air!"),

    basePrice = 5,
    rarity = lp.rarities.COMMON,
    generateSackItem = newLazyGen(function (etype)
        return etype.rarity == r.UNCOMMON and (not isFood(etype))
    end, DEFAULT_WEIGHT),
})



defSack("sack_food", "Food Sack", {
    activateDescription = locRarity("Spawns food items to choose from.\nMust be placed in the air!"),

    shape = VERTICAL_SACK_SHAPE,

    foodItem = true,

    basePrice = 5,

    rarity = lp.rarities.COMMON,
    generateSackItem = newLazyGen(function(etype)
        return etype.rarity ~= r.COMMON and isFood(etype)
    end, DEFAULT_WEIGHT),
})



defSack("sack_epic", "Epic Sack", {
    activateDescription = locRarity("Spawns %{EPIC} items to choose from.\nMust be placed in the air!"),

    basePrice = 16,
    rarity = lp.rarities.UNCOMMON,
    generateSackItem = newLazyGen(function (etype)
        return etype.rarity == r.EPIC and (not isFood(etype))
    end, DEFAULT_WEIGHT),
})


local function isDarkItem(etype)
    return lp.hasTag(etype, constants.tags.ROCKS) or lp.hasTag(etype, constants.tags.DESTRUCTIVE)
end

defSack("sack_dark", "Dark Sack", {
    activateDescription = locRarity("Spawns destructive items to choose from.\nMust be placed in the air!"),

    basePrice = 10,

    unlockAfterWins = constants.UNLOCK_AFTER_WINS.DESTRUCTIVE,

    shape = VERTICAL_SACK_SHAPE,
    rarity = lp.rarities.UNCOMMON,

    generateSackItem = newLazyGen(function (etype)
        if isDarkItem(etype) then
            local r1 = etype.rarity
            return r1 == r.RARE or r1 == r.EPIC
        end
        return false
    end, DEFAULT_WEIGHT),
})




do
local GRUB_MONEY_CAP = assert(constants.DEFAULT_GRUB_MONEY_CAP)

defSack("sack_grubby", "Grubby Sack", {
    unlockAfterWins = constants.UNLOCK_AFTER_WINS.GRUBBY,

    activateDescription = locRarity("Spawns {lootplot:GRUB_COLOR_LIGHT}GRUB-%{n}{/lootplot:GRUB_COLOR_LIGHT} items to choose from.\nMust be placed in the air!", {
        n = GRUB_MONEY_CAP
    }),

    rarity = lp.rarities.UNCOMMON,

    basePrice = 2,

    grubMoneyCap = GRUB_MONEY_CAP,
    -- this ^^^^ shcomp serves as an indicator, 
    -- so the player can better intuit about what item is spawned.

    generateSackItem = newLazyGen(function (etype)
        return etype.rarity == r.RARE and (not isFood(etype))
    end, DEFAULT_WEIGHT),

    transformTreasureItem = function(item, ppos)
        item.grubMoneyCap = GRUB_MONEY_CAP
    end
})

end





--[[

Old sack items.

I've gotten rid of these because they were quite bloat-y.

]]


--[=====[

defSack("sack_food", "Food Sack", {
    activateDescription = loc("Spawns a {lootplot:DOOMED_LIGHT_COLOR}DOOMED-1{/lootplot:DOOMED_LIGHT_COLOR} food item."),
    doomCount = 1,

    basePrice = 2,

    rarity = lp.rarities.COMMON,
    generateSackItem = newLazyGen(isFood, DEFAULT_WEIGHT),
})

defSack("sack_ruby", "Ruby Sack", {
    activateDescription = locRarity("Spawns a %{RARE} item, and gives it {lootplot:INFO_COLOR}REPEATER."),

    rarity = lp.rarities.EPIC,
    generateSackItem = newLazyGen(function (etype)
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

    generateSackItem = newLazyGen(function (etype)
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

    generateSackItem = newLazyGen(function (etype)
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

    generateSackItem = function(ent)
        tatteredGen = tatteredGen or lp.newItemGenerator({})
        return tatteredGen:query(function(entry)
            local etype = server.entities[entry]
            if etype and etype.rarity == ent.rarity then
                return 1
            end
            return 0
        end)
    end
})

]=====]

