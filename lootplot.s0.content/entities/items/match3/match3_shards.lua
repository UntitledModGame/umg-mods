
local loc = localization.localize

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

    etype.baseMaxActivations = 1

    etype.triggers = {"PULSE"}
    etype.basePointsGenerated = 5

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




local function give2ManaToSlot(itemEnt)
    local slotEnt = lp.itemToSlot(itemEnt)
    if slotEnt then
        lp.mana.addMana(slotEnt, 2)
    end
end
defShards("mana_shards", "Mana Shards",
    give2ManaToSlot, "Give {lootplot.mana:LIGHT_MANA_COLOR}+1 mana{/lootplot.mana:LIGHT_MANA_COLOR} to slot",
{
    rarity = lp.rarities.COMMON,
    basePrice = 2,
})



local function earn8Money(itemEnt)
    lp.addMoney(itemEnt, 8)
end
defShards("golden_shards", "Golden Shards",
    earn8Money, "Earn {lootplot:MONEY_COLOR}$4{/lootplot:MONEY_COLOR}.",
{
    rarity = lp.rarities.COMMON,
    basePrice = 4,
})



local function spawnFoodSack(itemEnt)
    umg.log.error("TODO: spawn food sack!")
end
defShards("food_shards", "Food Shards",
    spawnFoodSack, "Spawns a {lootplot:INFO_COLOR}Food Sack",
{
    rarity = lp.rarities.COMMON,
    basePrice = 3,
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

