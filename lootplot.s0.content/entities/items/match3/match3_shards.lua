
local loc = localization.localize

local constants = require("shared.constants")

local itemGenHelper = require("shared.item_gen_helper")



local match3 = require("shared.match3")

local PREFIX = "lootplot.s0.content:"


local IS_SHARD_ITEM = {--[[
    [ent-id] -> true
]]}

local function defItem(id, name, etype)
    etype.name = loc(name)
    etype.image = etype.image or id
    lp.defineItem(PREFIX .. id, etype)
end



local function defShards(id, name, onMatchActivate, onMatchDesc, etype)
    etype = etype or {}
    etype.image = etype.image or id

    local full_id = PREFIX .. id
    IS_SHARD_ITEM[full_id] = true

    etype.baseMaxActivations = 7

    etype.triggers = {"PULSE"}

    local function isMatch(ppos)
        local item = lp.posToItem(ppos)
        if item and item:type() == full_id then
            return true
        end
    end

    etype.onActivate = function(ent)
        local ppos = lp.getPos(ent)
        if not ppos then return end

        local matchedPoses = match3.test(ppos, isMatch)
        for i = #matchedPoses,1,-1 do
            local p = matchedPoses[i]
            local item = lp.posToItem(p)
            if item then
                lp.wait(ppos, 0.1)
                lp.queueWithEntity(item, function(e)
                    local ppos2 = lp.getPos(e)
                    if not ppos2 then return end
                    onMatchActivate(e, ppos2)
                    if umg.exists(e) then
                        lp.destroy(e)
                    end
                end)
            end
        end
    end

    etype.activateDescription = loc(
        "When 3 are in a line:\n" .. onMatchDesc
    )
    etype.name = loc(name)

    lp.defineItem(full_id, etype)
end




local function giveManaToSlot(itemEnt)
    local slotEnt = lp.itemToSlot(itemEnt)
    if slotEnt then
        lp.mana.addMana(slotEnt, 1)
    end
end
defShards("mana_shards", "Mana Shards",
    giveManaToSlot, "Give {lootplot.mana:LIGHT_MANA_COLOR}+1 mana{/lootplot.mana:LIGHT_MANA_COLOR} to slot",
{
    rarity = lp.rarities.COMMON,
    basePointsGenerated = 5,
    basePrice = 3,
})



local function earn8Money(itemEnt)
    lp.addMoney(itemEnt, 8)
end
--[[
IDEA: 
Instead of earning money,
Golden-shards should spawn DOOMED-1 shop-slots with items inside.
That'll make them more "interesting"
(That way, we can make them COMMON too!)
]]
defShards("golden_shards", "Golden Shards",
    earn8Money, "Earn {lootplot:MONEY_COLOR}$8{/lootplot:MONEY_COLOR}.",
{
    rarity = lp.rarities.UNCOMMON,
    basePrice = 4,
})




local generateFoodItem = itemGenHelper.createLazyGenerator(
    function(etype)
        return etype.doomCount == 1
    end,
    itemGenHelper.createRarityWeightAdjuster({
        COMMON = 2,
        UNCOMMON = 5,
        RARE = 5,
        EPIC = 2
    })
)

local function spawnCloudWithFoodItem(itemEnt)
    local ppos = lp.getPos(itemEnt)
    if ppos then
        lp.forceSpawnSlot(ppos, server.entities.cloud_slot, itemEnt.lootplotTeam)
        local itemTypeId = generateFoodItem()
        assert(itemTypeId, "uhhh, what???")
        lp.forceSpawnItem(ppos, server.entities[itemTypeId], itemEnt.lootplotTeam)
    end
end

defShards("food_shards", "Food Shards",
    spawnCloudWithFoodItem, "Spawns a {lootplot:INFO_COLOR}Cloud Food Item",
{
    rarity = lp.rarities.COMMON,
    --[[
    QUESTION: Isn't ($2x3) = $6 too expensive for a food item?

    ANSWER: Kinda... but remember that the user can easily activate 
    the food-item WHILST it is inside the cloud-slot.
    So that needs to be baked into the price somehow.
    (If anything; perhaps it should be more expensive!)
    ]]
    basePrice = 2,
    basePointsGenerated = 5,
    canItemFloat = true
})



local function spawnKey(itemEnt)
    local ppos = lp.getPos(itemEnt)
    if ppos then
        lp.forceSpawnItem(ppos, server.entities.key, itemEnt.lootplotTeam)
    end
end
defShards("key_shards", "Key Shards",
    spawnKey, "Spawns a {lootplot:INFO_COLOR}Key",
{
    rarity = lp.rarities.UNCOMMON,
    basePointsGenerated = 10,
    basePrice = 6,
})




local generateItem = itemGenHelper.createLazyGenerator(
    function(etype) return true end,
    itemGenHelper.createRarityWeightAdjuster({
        UNCOMMON = 2,
        RARE = 5,
        EPIC = 2
    })
)


local function spawnCloudWithItem(itemEnt)
    local ppos = lp.getPos(itemEnt)
    if ppos then
        lp.forceSpawnSlot(ppos, server.entities.cloud_slot, itemEnt.lootplotTeam)
        local itemTypeId = generateItem()
        assert(itemTypeId, "uhhh, what???")
        lp.forceSpawnItem(ppos, server.entities[itemTypeId], itemEnt.lootplotTeam)
    end
end
defShards("iron_shards", "Iron Shards",
    spawnCloudWithItem, "Spawns a {lootplot:INFO_COLOR}Cloud Slot Item!", {
    rarity = lp.rarities.COMMON,
    basePointsGenerated = 6,
    canItemFloat = true,
    basePrice = 4,
})



--[[
same as iron; except, cannot float.
This means that the player will be forced to delete slots.
]]
defShards("coal_shards", "Coal Shards",
    spawnCloudWithItem, "Spawns a {lootplot:INFO_COLOR}Cloud Slot Item!", {
    rarity = lp.rarities.COMMON,
    baseMultGenerated = 0.2,
    basePrice = 2,
})




defItem("wildcard_shards", "Wildcard Shards", {
    triggers = {"PULSE"},
    activateDescription = loc("If target-item is a shard, transforms into it."),

    rarity = lp.rarities.COMMON,
    basePrice = 5,
    basePointsGenerated = 6,

    shape = lp.targets.RookShape(1),

    target = {
        type = "ITEM",
        filter = function(selfEnt, ppos, targetEnt)
            local id = targetEnt:type()
            return IS_SHARD_ITEM[id]
        end,
        activate = function(selfEnt, ppos, targetEnt)
            local selfPos = lp.getPos(selfEnt)
            if selfPos then
                lp.forceCloneItem(targetEnt, selfPos)
            end
        end
    }
})


--[[


TODO:
Do other match3 shard items here:




Iron shards:
- Spawn a TREASURE-BAG that spawns non-doomed items
THESE SHOULD COST MORE, Or else it's OP.
Maybe $7 per shard...?


Opal shards:
- Spawn a TREASURE-BAG that spawns doomed items
(aka food-items)


Wildcard shards:
shape=ROOK-1
transforms into random neighbour shard-items


Coal shards:
(COST = 1$, OR EVEN FREE??)
Earns 10 points
Transform into a random shard (except coal)


Diamond:
shape=UP-1
Activates target shard-items,
Even if they aren't in a row.


Philosopher's stone:
shape=KING-1
Randomizes all shard items


]]

