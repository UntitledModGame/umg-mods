
---@type generation.Generator
local itemGenerator
umg.on("@load", function()
    itemGenerator = lp.newItemGenerator()
end)


local NULL_ITEM = "manure"

local function generateItem(ent)
    local itemName = itemGenerator
        :query(function(entityType)
            return lp.getDynamicSpawnChance(entityType, ent)
        end)
    return itemName or NULL_ITEM
end



lp.defineSlot("lootplot.content.s0:shop_slot", {
    image = "shop_slot",
    color = {1, 1, 0.6},
    baseMaxActivations = 100,
    shopLock = true,
    name = localization.localize("Shop slot"),
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
    name = localization.localize("Reroll slot"),
    triggers = {"REROLL", "PULSE"},
    itemReroller = generateItem,
    baseCanSlotPropagate = false,
    baseMaxActivations = 500,
})

