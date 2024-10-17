
local loc = localization.localize
local interp = localization.newInterpolator


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



---@param ent Entity
---@param bool boolean
local function setShopLock(ent, bool)
    ent.shopLock = bool
    sync.syncComponent(ent, "shopLock")
end

local BUY_TEXT = interp("BUY ($%{price})")

---@param slotEnt Entity
local function buyServer(slotEnt)
    local itemEnt = lp.slotToItem(slotEnt)
    if itemEnt then
        lp.subtractMoney(slotEnt, itemEnt.price)
        setShopLock(slotEnt, false)
    end
end

local function buyClient(slotEnt)
    lp.deselectItem()
    local itemEnt = lp.slotToItem(slotEnt)
    if itemEnt then
        lp.selectItem(itemEnt, true)
    end
end


local shopButton = {
    action = function(ent, clientId)
        if server then
            buyServer(ent)
        elseif client then
            buyClient(ent)
        end
    end,
    canDisplay = function(ent, clientId)
        return ent.shopLock
    end,
    canClick = function(ent, clientId)
        local itemEnt = lp.slotToItem(ent)
        if itemEnt then
            return lp.getMoney(itemEnt) >= itemEnt.price
        end
    end,
    text = function(ent)
        local itemEnt = lp.slotToItem(ent)
        if not itemEnt then
            return ""
        end
        return BUY_TEXT(itemEnt)
    end,
    color = objects.Color(0.39,0.66,0.24),
}

lp.defineSlot("lootplot.s0.content:shop_slot", {
    shopLock = true,
    image = "shop_slot",
    color = {1, 1, 0.6},
    baseMaxActivations = 100,
    name = loc("Shop slot"),
    triggers = {"REROLL", "PULSE"},
    itemSpawner = generateItem,
    itemReroller = generateItem,
    baseCanSlotPropagate = false,
    canPlayerAccessItemInSlot = function(slotEnt, itemEnt)
        return not slotEnt.shopLock
    end,
    onActivate = function(slotEnt)
        setShopLock(slotEnt, true)
    end,
    actionButtons = {
        shopButton
    }
})




lp.defineSlot("lootplot.s0.content:reroll_slot", {
    image = "reroll_slot",
    name = loc("Reroll slot"),
    description = loc("Put an item inside to reroll it!"),
    triggers = {"REROLL", "PULSE"},
    itemReroller = generateItem,
    baseCanSlotPropagate = false,
    baseMaxActivations = 500,
})

