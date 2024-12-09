
local loc = localization.localize
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

    etype.name = loc(name)

    if etype.generateTreasureItem then
        local gen = etype.generateTreasureItem
        local transform = etype.transformTreasureItem or dummy
        ---@cast transform fun(e: Entity, pp: lootplot.PPos)

        etype.onActivate = function(ent)
            local itemId = gen()
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
    etype.triggers = {"UNLOCK"}
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
Sack-normal: Spawns a random item. Gives REPEATER to spawned item
Sack-normal: Spawns a random item. Gives REROLL trigger to spawned item
Sack-mana: Spawns a random item. The spawned item costs 1 mana to activate.
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



---@param filterFunc fun(etype: EntityType): boolean
---@return function
local function withFilter(filterFunc)
    assert(filterFunc,"?")
    local itemGen
    local function generate()
        itemGen = itemGen or lp.newItemGenerator({
            filter = function(item, weight)
                local etype = server.entities[item]
                return filterFunc(etype)
            end
        })
        return itemGen()
    end
    return generate
end


---@param possibleRarities lootplot.rarities.Rarity
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






defChest("chest_gold_small", "Small Golden Chest", {
    doomCount = 1,
    baseMoneyGenerated = 15,
    basePrice = 4,
    rarity = lp.rarities.UNCOMMON
})


defChest("chest_gold_big", "Big Golden Chest", {
    doomCount = 1,
    baseMoneyGenerated = 40,
    basePrice = 10,
    rarity = lp.rarities.EPIC
})



defChest("chest_iron_small", "Small Iron Chest", {
    rarity = lp.rarities.UNCOMMON,
    generateTreasureItem = withFilter(ofRarity({r.UNCOMMON, r.COMMON, r.RARE})),
})

defChest("chest_iron_big", "Big Iron Chest", {
    rarity = lp.rarities.UNCOMMON,
    generateTreasureItem = withFilter(ofRarity({r.UNCOMMON, r.RARE, r.EPIC, r.LEGENDARY})),
})




defChest("chest_iron_small", "Small Iron Chest", {
    rarity = lp.rarities.UNCOMMON,
    generateTreasureItem = withFilter(ofRarity({r.UNCOMMON, r.COMMON, r.RARE})),
})

defChest("chest_iron_big", "Big Iron Chest", {
    rarity = lp.rarities.UNCOMMON,
    generateTreasureItem = withFilter(ofRarity({r.UNCOMMON, r.RARE, r.EPIC, r.LEGENDARY})),
})





defChest("chest_iron_small", "Small Iron Chest", {
    rarity = lp.rarities.UNCOMMON,
    generateTreasureItem = withFilter(ofRarity({r.UNCOMMON, r.COMMON, r.RARE})),
})

defChest("chest_iron_big", "Big Iron Chest", {
    rarity = lp.rarities.UNCOMMON,
    generateTreasureItem = withFilter(ofRarity({r.UNCOMMON, r.RARE, r.EPIC, r.LEGENDARY})),
})






