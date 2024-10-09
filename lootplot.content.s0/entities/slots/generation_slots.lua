local loc = localization.localize

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



lp.defineSlot("lootplot.s0.content:shop_slot", {
    init = function(ent)
        ent.shopLock = true
    end,
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

--[[

text = function()
    return "Buy ($"..itemEnt.price..")"
end,
color = objects.Color(0.39,0.66,0.24),
onClick = function()
    if shopService.buy(itemEnt) then
        selection.reset()
        --[==[
        Don't open selection buttons; 
        (for 2 reasons)
        1: The data is outdated, (serv hasnt responded yet) and we will get wrong buttons
        2: the player has just purchased the item, and won't be interested in selling it anyway!!
        ]==]
        selection.selectSlotNoButtons(slotEnt)
    end
end,
canClick = function()
    return lp.getMoney(itemEnt) >= itemEnt.price
end,
priority = 0,

]]


lp.defineSlot("lootplot.s0.content:reroll_slot", {
    image = "reroll_slot",
    name = loc("Reroll slot"),
    description = loc("Put an item inside to reroll it!"),
    triggers = {"REROLL", "PULSE"},
    itemReroller = generateItem,
    baseCanSlotPropagate = false,
    baseMaxActivations = 500,
})

