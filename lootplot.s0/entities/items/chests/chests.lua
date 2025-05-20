
local itemGenHelper = require("shared.item_gen_helper")
local constants = require("shared.constants")


local loc = localization.localize
local interp = localization.newInterpolator


local function defChest(id, name, etype)
    etype.triggers = etype.triggers or {"UNLOCK"}
    etype.basePrice = etype.basePrice or 6
    etype.rarity = etype.rarity or lp.rarities.RARE

    etype.baseMaxActivations = 1

    etype.image = id
    etype.name = loc(name)

    lp.defineItem("lootplot.s0:" .. id, etype)
end




defChest("chest_gold_small", "Small Golden Chest", {
    baseMoneyGenerated = 10,
    basePrice = 4,
    rarity = lp.rarities.RARE
})


defChest("chest_gold_big", "Big Golden Chest", {
    baseMoneyGenerated = 25,
    basePrice = 10,
    rarity = lp.rarities.EPIC
})



defChest("chest_diamond", "Diamond Chest", {
    activateDescription = loc("Spawns diamond slots."),

    shape = lp.targets.KingShape(1),
    target = {
        type = "NO_SLOT",
        activate = function(selfEnt, ppos)
            lp.trySpawnSlot(ppos, server.entities.diamond_slot, selfEnt.lootplotTeam)
        end
    },

    doomCount = 2,
    rarity = lp.rarities.RARE,
})



-- local POINTS_BUFF = 20

-- defChest("chest_points", "Points Chest", {
--     activateDescription = loc("Gives {lootplot:POINTS_COLOR}+%{buff} points{/lootplot:POINTS_COLOR} to items permanently", {
--         buff = POINTS_BUFF
--     }),

--     shape = lp.targets.KingShape(1),
--     target = {
--         type = "ITEM",
--         activate = function(selfEnt, ppos, itemEnt)
--             lp.modifierBuff(itemEnt, "pointsGenerated", POINTS_BUFF, selfEnt)
--         end
--     },

--     rarity = lp.rarities.RARE,
-- })


-- I'm not entirely happy with this idea ^^^^
-- I think we can do better, honestly.





---@param etype EntityType
---@return boolean
local function noFood(etype)
    ---@cast etype table
    if lp.hasTag(etype, constants.tags.FOOD) then
        return false
    end
    return true
end





do
local generateItem = itemGenHelper.createLazyGenerator(
    noFood,
    itemGenHelper.createRarityWeightAdjuster({LEGENDARY = 1})
)

defChest("chest_legendary", "Legendary Chest", {
    rarity = lp.rarities.LEGENDARY,

    activateDescription = loc("Spawns a random %{LEGENDARY} item", {
        LEGENDARY = lp.rarities.LEGENDARY.displayString
    }),

    basePrice = 25,

    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        local etype = server.entities[generateItem()]
        if ppos and etype then
            lp.forceSpawnItem(ppos, etype, ent.lootplotTeam)
        end
    end
})

end





do
local generateItem = itemGenHelper.createLazyGenerator(
    noFood,
    itemGenHelper.createRarityWeightAdjuster({
        EPIC = 1,
        LEGENDARY = 0.03
    })
)

defChest("chest_epic", "Epic Chest", {
    rarity = lp.rarities.EPIC,

    activateDescription = loc("Spawns an random item that is %{EPIC} or above", {
        EPIC = lp.rarities.EPIC.displayString
    }),
    baseMoneyGenerated = 10,

    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        local etype = server.entities[generateItem()]
        if ppos and etype then
            lp.forceSpawnItem(ppos, etype, ent.lootplotTeam)
        end
    end
})

end




do
local generateItem = itemGenHelper.createLazyGenerator(
    noFood,
    itemGenHelper.createRarityWeightAdjuster({
        RARE = 1
    })
)

defChest("chest_rare", "Rare Chest", {
    rarity = lp.rarities.UNCOMMON,

    activateDescription = loc("Spawns a random %{RARE} item", {
        RARE = lp.rarities.RARE.displayString
    }),

    basePrice = 1,

    onActivate = function(ent)
        local ppos = lp.getPos(ent)
        local etype = server.entities[generateItem()]
        if ppos and etype then
            lp.forceSpawnItem(ppos, etype, ent.lootplotTeam)
        end
    end
})

end



-- defChest("chest_dark", "Dark Chest", {
--     rarity = lp.rarities.RARE,
--     basePrice = 1,

--     activateDescription = locRarity("Spawns a %{RARE} item, and {lootplot:DOOMED_LIGHT_COLOR}DESTROYS{/lootplot:DOOMED_LIGHT_COLOR} all target-items."),

--     generateTreasureItem = newLazyGen(ofRarity({r.RARE}), DEFAULT_WEIGHT),

--     shape = lp.targets.QueenShape(2),
--     target = {
--         type = "ITEM",
--     }
-- })


-- defChest("chest_rare", "Rare Chest", {
--     rarity = lp.rarities.UNCOMMON,
--     basePrice = 2,

--     activateDescription = locRarity("Spawns a %{RARE} item"),

--     generateTreasureItem = newLazyGen(ofRarity({r.RARE}), DEFAULT_WEIGHT)
-- })

-- defChest("chest_epic", "Epic Chest", {
--     rarity = lp.rarities.RARE,
--     activateDescription = locRarity("Spawns an item that that is %{EPIC} or above"),

--     generateTreasureItem = newLazyGen(ofRarity({r.EPIC, r.LEGENDARY}), DEFAULT_WEIGHT),
-- })


-- defChest("chest_food", "Food Chest", {
--     rarity = lp.rarities.UNCOMMON,
--     activateDescription = loc("Spawns a {lootplot:DOOMED_LIGHT_COLOR}DOOMED-1{/lootplot:DOOMED_LIGHT_COLOR} food item."),

--     doomCount = 1,
--     -- we only put this here to give a nice visual.
--     -- (It doesn't actually do anything; but it serves as a nice indicator;
--     -- to demonstrate that the spawned item will be DOOMED.)

--     generateTreasureItem = newLazyGen(function(etype)
--         return etype.doomCount == 1
--     end, DEFAULT_WEIGHT)
-- })


-- local ABSTRACT_DESC = interp("Spawns an item of the same rarity as this chest!\n(Currently: %{rarity})")
-- --[[
-- NOTE:
-- make sure to test this!!!
-- It kinda looks a bit fragile...?
-- ]]
-- ---@type generation.Generator
-- local abstractGen
-- defChest("chest_abstract", "Abstract Chest", {
--     rarity = lp.rarities.RARE,
--     activateDescription = function(ent)
--         local r1 = ent.rarity
--         return ABSTRACT_DESC({
--             rarity = r1.displayString
--         })
--     end,

--     generateTreasureItem = function(ent)
--         abstractGen = abstractGen or lp.newItemGenerator({})
--         return abstractGen:query(function(entry)
--             local etype = server.entities[entry]
--             if etype and etype.rarity == ent.rarity then
--                 return 1
--             end
--             return 0
--         end)
--     end
-- })



-- defChest("chest_legendary", "Legendary Chest", {
--     activateDescription = locRarity("Spawns a %{LEGENDARY} item."),
--     rarity = lp.rarities.LEGENDARY,
--     generateTreasureItem = newLazyGen(ofRarity({r.LEGENDARY}), DEFAULT_WEIGHT)
-- })

