
local loc = localization.localize

local constants = require("shared.constants")

local itemGenHelper = require("shared.item_gen_helper")
local helper = require("shared.helper")



local match3 = require("shared.match3")

local PREFIX = "lootplot.s0:"


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

    etype.unlockAfterWins = constants.UNLOCK_AFTER_WINS.SHARDS

    local full_id = PREFIX .. id
    IS_SHARD_ITEM[full_id] = true

    local function isMatch(ppos)
        local item = lp.posToItem(ppos)
        if item and item:type() == full_id then
            return true
        end
    end

    etype.onUpdateServer = function(ent)
        local ppos = lp.getPos(ent)
        if not ppos then return end

        local slotEnt = lp.itemToSlot(ent)
        if slotEnt and not lp.canSlotPropagateTriggerToItem(slotEnt) then
            -- KINDA HACKY:
            -- this means that the item is in a null-slot, or a shop-slot, or somthn.
            return
        end

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




do

local function goldShardActivate(itemEnt)
    local slotEnt = lp.itemToSlot(itemEnt)
    if slotEnt then
        lp.modifierBuff(slotEnt, "moneyGenerated", 1, itemEnt)
        lp.modifierBuff(slotEnt, "pointsGenerated", -50, itemEnt)
    end
end

defShards("golden_shards", "Golden Shards",
    goldShardActivate,
    "Make slots earn {lootplot:MONEY_COLOR}$1{/lootplot:MONEY_COLOR} and steal 50 points.\nThen, destroy self.", {
    rarity = lp.rarities.RARE,
    basePrice = 12,
})

end



--[[

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

]]



do

local function activateKeyShard(itemEnt)
    local ppos = lp.getPos(itemEnt)
    local slotEnt = lp.itemToSlot(itemEnt)
    if ppos then
        lp.forceSpawnItem(ppos, server.entities.key, assert(itemEnt.lootplotTeam))
    end
    if slotEnt then
        lp.modifierBuff(slotEnt, "bonusGenerated", 6)
    end
end

defShards("key_shards", "Key Shards",
    activateKeyShard, "Adds {lootplot:BONUS_COLOR}+6 Bonus{/lootplot:BONUS_COLOR} to slots, and spawns {lootplot:INFO_COLOR}Keys{/lootplot:INFO_COLOR}.\nThen, destroy self.", {
    rarity = lp.rarities.COMMON,
    basePrice = 8,
})

end





do

local function coalShardActivate(itemEnt)
    local slotEnt = lp.itemToSlot(itemEnt)
    if slotEnt then
        lp.modifierBuff(slotEnt, "multGenerated", 0.5)
    end
end

defShards("coal_shards", "Coal Shards",
    coalShardActivate, "Adds {lootplot:POINTS_MULT_COLOR}+0.5 mult{/lootplot:POINTS_MULT_COLOR} to slots.\nThen, destroy self.", {
    rarity = lp.rarities.COMMON,
    basePrice = 6,
})

end






do
local function emeraldShardActivate(itemEnt)
    local slotEnt = lp.itemToSlot(itemEnt)
    if slotEnt then
        lp.addTrigger(slotEnt, "REROLL")
        lp.modifierBuff(slotEnt, "pointsGenerated", 10)
    end
end

defShards("emerald_shards", "Emerald Shards",
    emeraldShardActivate, "Adds {lootplot:POINTS_COLOR}+10 points{/lootplot:POINTS_COLOR} to slots, and gives slots {lootplot:TRIGGER_COLOR}Reroll{/lootplot:TRIGGER_COLOR} trigger.\nThen, destroy self.", {
    rarity = lp.rarities.UNCOMMON,
    basePrice = 3,
})

end






defItem("wildcard_shards", "Wildcard Shards", {
    triggers = {"PULSE"},
    activateDescription = loc("If target-item is a shard, transforms into it."),

    unlockAfterWins = constants.UNLOCK_AFTER_WINS.SHARDS,

    rarity = lp.rarities.UNCOMMON,
    basePrice = 8,
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

