

local loc = localization.localize
local interp = localization.newInterpolator


local function defChest(id, name, etype)
    etype.triggers = etype.triggers or {"UNLOCK"}
    etype.basePrice = etype.basePrice or 6
    etype.rarity = etype.rarity or lp.rarities.RARE

    etype.name = loc(name)
    lp.defineItem("lootplot.s0.content:" .. id, etype)
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

-- defChest("chest_mana", "Mana Chest", {
--     triggers = {"PULSE"},
--     activateDescription = locRarity("Spawns a %{RARE} item."),

--     manaCost = 2,

--     rarity = lp.rarities.RARE,
--     generateTreasureItem = newLazyGen(ofRarity({r.RARE}), DEFAULT_WEIGHT),
-- })



