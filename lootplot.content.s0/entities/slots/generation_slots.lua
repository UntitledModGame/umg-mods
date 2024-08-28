local loc = localization.newLocalizer()

---@type generation.Generator
local itemGen

local function generateItem(ent)
    itemGen = itemGen or lp.newItemGenerator()
    local itemName = itemGen
        :query(function(entityType)
            return lp.getDynamicSpawnChance(entityType, ent)
        end)
    return itemName or lp.FALLBACK_NULL_ITEM
end



lp.defineSlot("lootplot.content.s0:shop_slot", {
    image = "shop_slot",
    color = {1, 1, 0.6},
    baseMaxActivations = 100,
    shopLock = true,
    name = loc("Shop slot"),
    triggers = {"REROLL", "PULSE"},
    itemSpawner = generateItem,
    itemReroller = generateItem,
    baseCanSlotPropagate = false,
    onActivate = function(shopEnt)
        shopEnt.shopLock = true
    end
})


lp.defineSlot("lootplot.content.s0:reroll_slot", {
    image = "reroll_slot",
    name = loc("Reroll slot"),
    description = loc("Put an item inside to reroll it!"),
    triggers = {"REROLL", "PULSE"},
    itemReroller = generateItem,
    baseCanSlotPropagate = false,
    baseMaxActivations = 500,
})

