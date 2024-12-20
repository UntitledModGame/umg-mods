
local loc = localization.localize
local interp = localization.newInterpolator

local constants = require("shared.constants")

local itemGenHelper = require("shared.item_gen_helper")


local function defShopSlot(id, name, etype)
    etype.name = loc(name)
    etype.image = etype.image or id
    lp.defineSlot("lootplot.s0.content:" .. id, etype)
end



---@param ent Entity
---@param bool boolean
local function setItemLock(ent, bool)
    ent.itemLock = bool
    sync.syncComponent(ent, "itemLock")
end





---@param ent Entity
---@param bool boolean
local function setRerollLock(ent, bool)
    ent.rerollLock = bool
    sync.syncComponent(ent, "rerollLock")
end

local LOCK_TEXT = loc("Lock")
local UNLOCK_TEXT = loc("Unlock")


local LOCK_REROLL_BUTTON = {
    action = function(ent, clientId)
        if server then
            setRerollLock(ent, not ent.rerollLock)
        end
    end,
    canDisplay = function(ent, clientId)
        return lp.slotToItem(ent)
    end,
    canClick = function(ent, clientId)
        return lp.slotToItem(ent)
    end,
    text = function(ent)
        if ent.rerollLock then
            return UNLOCK_TEXT
        else
            return LOCK_TEXT
        end
    end,
    color = objects.Color(0.7,0.7,0.7),
}



local BUY_TEXT = interp("BUY ($%{price})")

---@param slotEnt Entity
local function buyServer(slotEnt)
    local itemEnt = lp.slotToItem(slotEnt)
    if itemEnt then
        lp.subtractMoney(slotEnt, itemEnt.price)
        lp.tryTriggerEntity("BUY", itemEnt)
        setItemLock(slotEnt, false)
    end
end

local function buyClient(slotEnt)
    lp.deselectItem()
    local itemEnt = lp.slotToItem(slotEnt)
    if itemEnt then
        lp.selectItem(itemEnt, true)
    end
end

---@param ent Entity
---@param clientId string
local function shopButtonBuyItem(ent, clientId)
    if server then
        setRerollLock(ent, false)
        buyServer(ent)
    elseif client then
        buyClient(ent)
    end
end

local function canDisplayShopButton(ent, clientId)
    return ent.itemLock
end

local function canClickShopButton(ent, clientId)
    local itemEnt = lp.slotToItem(ent)
    if itemEnt and ent.itemLock then
        return lp.getMoney(itemEnt) >= itemEnt.price
    end
end

local function getShopButtonText(ent)
    local itemEnt = lp.slotToItem(ent)
    if not itemEnt then
        return ""
    end
    return BUY_TEXT(itemEnt)
end


local SHOP_BUTTON = {
    action = shopButtonBuyItem,
    canDisplay = canDisplayShopButton,
    canClick = canClickShopButton,
    text = getShopButtonText,
    color = objects.Color(0.39,0.66,0.24),
}



local TEXT_MAX_WIDTH = 200
---@param text string
---@param x number
---@param y number
---@param rot number
---@param sx number
---@param sy number
---@param oy number
---@param kx number
---@param ky number
local function printCenterWithOutline(text, x, y, rot, sx, sy, oy, kx, ky)
    local r, g, b, a = love.graphics.getColor()
    local ox = TEXT_MAX_WIDTH / 2

    love.graphics.setColor(0, 0, 0, a)
    for outY = -1, 1 do
        for outX = -1, 1 do
            if not (outX == 0 and outY == 0) then
                love.graphics.printf(text, x + outX * sx, y + outY * sy, TEXT_MAX_WIDTH, "center", rot, sx, sy, ox, oy, kx, ky)
            end
        end
    end

    love.graphics.setColor(r, g, b, a)
    love.graphics.printf(text, x, y, TEXT_MAX_WIDTH, "center", rot, sx, sy, ox, oy, kx, ky)
end


local PRICE_TEXT = interp("$%{price}")
local PRICE_COLOR = objects.Color.fromByteRGBA(252, 211, 3)
local GREEN_PRICE_COLOR = objects.Color.fromByteRGBA(100, 252, 30)

local function drawItemPrice(slotEnt, itemEnt)
    if slotEnt.itemLock and itemEnt.price then
        if itemEnt.price > 0 then
            love.graphics.setColor(PRICE_COLOR)
        else
            love.graphics.setColor(GREEN_PRICE_COLOR)
        end
        printCenterWithOutline(PRICE_TEXT(itemEnt), itemEnt.x, itemEnt.y, 0, 0.75, 0.75, 20, 0, 0)
    end
end






local function makeShopSlot(id, name, comps)
    local full_id = "lootplot.s0.content:" .. id
    local etype = {
        itemLock = true,

        image = id,

        baseMaxActivations = 100,
        name = loc(name),
        triggers = {"REROLL", "PULSE"},
        baseCanSlotPropagate = false,
        canActivate = function(ent)
            -- if rerollLock=true, then we dont activate!
            return (not ent.rerollLock) or (not lp.slotToItem(ent))
        end,
        canPlayerAccessItemInSlot = function(slotEnt, itemEnt)
            return not slotEnt.itemLock
        end,
        onActivate = function(slotEnt)
            setItemLock(slotEnt, true)
        end,
        onItemDraw = function(selfEnt, itemEnt, x,y, rot, sx,sy)
            if selfEnt.rerollLock then
                rendering.drawImage("slot_reroll_padlock", x,y, rot, sx,sy)
            end
            return drawItemPrice(selfEnt, itemEnt)
        end,
    }
    for k,v in pairs(comps) do
        etype[k]=v
    end
    lp.defineSlot(full_id, etype)
end




local allFilter = function () return true end


local generateWeakItem

do
local OK_RARITIES = {lp.rarities.COMMON, lp.rarities.UNCOMMON}

generateWeakItem = itemGenHelper.createLazyGenerator(
    function(etype)
        if itemGenHelper.hasRarity(etype, OK_RARITIES) then
            return true
        end
        ---@cast etype table
        if lp.hasTag(etype, constants.tags.FOOD) then
            return true -- (Food items are OK to spawn here.)
        end
        return false
    end,
    itemGenHelper.createRarityWeightAdjuster({
        COMMON = 11,
        UNCOMMON = 1,
        
        -- NOTE: RARE/EPIC items aren't actually spawned;
        -- UNLESS they are food-items
        RARE = 0.4,
        EPIC = 0.1
    })
)
end
makeShopSlot("weak_shop_slot", "Weak Shop Slot", {
    activateDescription = loc("Spawns weak items"),
    baseMaxActivations = 100,
    itemReroller = generateWeakItem,
    itemSpawner = generateWeakItem,
    actionButtons = {
        SHOP_BUTTON,
        LOCK_REROLL_BUTTON
    }
})




local function isTreasureItem(etype)
    --[[
    TODO: implement this!
    We might need trait system again...?
    ]]
    return lp.hasTag(etype, constants.tags.TREASURE)
end

local generateTreasureItem = itemGenHelper.createLazyGenerator(
        -- TODO: implement
    isTreasureItem,
    itemGenHelper.createRarityWeightAdjuster({
        COMMON = 2,
        UNCOMMON = 5,
        RARE = 1.5,
        EPIC = 0.3,
        LEGENDARY = 0.04
    })
)
makeShopSlot("treasure_shop_slot", "Treasure Shop Slot", {
    activateDescription = loc("Spawns treasure items"),
    baseMaxActivations = 10,
    itemReroller = generateTreasureItem,
    itemSpawner = generateTreasureItem,
    actionButtons = {
        SHOP_BUTTON,
        LOCK_REROLL_BUTTON
    }
})





--- Iterates over all touching slot-entities of the same type as `rootSlotEnt`.
--- Useful for deleting all slots of the same type that are touching, for example.
--- Or, for clearing all touching shop-slots.
---@param rootSlotEnt lootplot.SlotEntity
---@param func fun(e: lootplot.SlotEntity, ppos: lootplot.PPos)
local function foreachTouchingSlot(rootSlotEnt, func)
    local seen = {--[[
        [ppos] -> bool
        true if we have already search this ppos.
    ]]}

    ---@param pos lootplot.PPos?
    ---@return boolean
    local function isMatch(pos)
        local slotEnt = pos and lp.posToSlot(pos)
        if slotEnt and slotEnt:type() == rootSlotEnt:type() then
            return true
        end
        return false
    end

    ---@param p lootplot.PPos
    ---@param x integer
    ---@param y integer
    local function consider(p, x, y)
        local ppos = p:move(x, y)
        if ppos and (not seen[ppos]) and isMatch(ppos) then
            -- we havent discovered this one yet:
            seen[ppos] = true

            consider(ppos, -1, 0)
            consider(ppos, 0, -1)
            consider(ppos, 1, 0)
            consider(ppos, 0, 1)
        end
    end

    local ppos = lp.getPos(rootSlotEnt)
    if ppos then
        consider(ppos, 0,0)
    end

    for pos, _ in pairs(seen) do
        local slotEnt = lp.posToSlot(pos)
        if slotEnt then
            lp.queueWithEntity(slotEnt, function(ent)
                local pos1 = lp.getPos(ent)
                if pos1 then
                    func(ent, pos1)
                    lp.wait(pos1, 0.4)
                end
            end)
        end
    end
end


--[[
This function will delete all "attached" items;
That is, all items that are 
]]
local function deleteAttachedItems(ent)
    assert(server,"?")
    foreachTouchingSlot(ent, function(e, ppos)
        if e == ent then
            -- we delete every item, EXCEPT self.
            return
        end
        local item = lp.posToItem(ppos)
        if item then
            item:delete()
        end
    end)
end



local STRONG_SHOP_BUTTON = {
    action = function(ent, clientId)
        shopButtonBuyItem(ent, clientId)
        if server then
            deleteAttachedItems(ent)
        end
    end,
    canDisplay = canDisplayShopButton,
    canClick = canClickShopButton,
    text = getShopButtonText,
    color = objects.Color(0.39,0.66,0.24),
}


local generateStrongItem = itemGenHelper.createLazyGenerator(
    allFilter,
    itemGenHelper.createRarityWeightAdjuster({
        UNCOMMON = 2,
        RARE = 5,
        EPIC = 1,
        LEGENDARY = 0.04
    })
)
makeShopSlot("strong_shop_slot", "Strong Shop Slot", {
    activateDescription = loc("Spawns RARE items or above.\nWill delete all neighbouring items when an item is purchased."),
    baseMaxActivations = 1,
    itemReroller = generateStrongItem,
    itemSpawner = generateStrongItem,
    actionButtons = {
        STRONG_SHOP_BUTTON,
    }
})






lp.defineSlot("lootplot.s0.content:reroll_slot", {
    image = "reroll_slot",
    name = loc("Reroll slot"),
    activateDescription = loc("Rerolls item."),
    triggers = {"REROLL", "PULSE"},
    itemReroller = generateWeakItem,
    baseCanSlotPropagate = false,
    baseMaxActivations = 500,

    canActivate = function(ent)
        return not ent.rerollLock
    end,
    actionButtons = {
        LOCK_REROLL_BUTTON
    }
})



lp.defineSlot("lootplot.s0.content:offer_slot", {
    itemLock = true,
    image = "slot",
    color = objects.Color.RED,

    name = loc("Treasure slot"),

    triggers = {"PULSE"},

    baseCanSlotPropagate = false,
    baseMaxActivations = 100,
    slotItemProperties = {
        multipliers = {
            price = 1.15
        },
        modifiers = {
            price = 2
        }
    },
    slotListen = {
        trigger = "BUY",
        activate = function(slotEnt)
            slotEnt.doomCount = 1
        end
    },

    canPlayerAccessItemInSlot = function(slotEnt)
        return not slotEnt.itemLock
    end,
    onActivate = function(slotEnt)
        if not (lp.slotToItem(slotEnt) or slotEnt:hasComponent("doomCount")) then
            slotEnt.doomCount = 1
        end
    end,
    onItemDraw = drawItemPrice,
    actionButtons = {
        SHOP_BUTTON
    }
})


lp.defineSlot("lootplot.s0.content:paper_slot", {
    itemLock = true,
    image = "paper_slot",

    name = loc("Paper slot"),

    triggers = {"PULSE"},

    baseCanSlotPropagate = false,
    baseMaxActivations = 100,
    slotListen = {
        trigger = "BUY",
        activate = function(slotEnt)
            slotEnt.doomCount = 1
        end
    },

    canPlayerAccessItemInSlot = function(slotEnt)
        return not slotEnt.itemLock
    end,
    onActivate = function(slotEnt)
        local itemEnt = lp.slotToItem(slotEnt)
        if itemEnt then
            local itemPrice = properties.computeProperty(itemEnt, "price")
            assert(type(itemPrice) == "number")

            local priceToSub = math.min(itemPrice, 5)
            lp.modifierBuff(itemEnt, "price", -priceToSub)
        elseif not slotEnt:hasComponent("doomCount") then
            slotEnt.doomCount = 1
        end
    end,
    onItemDraw = drawItemPrice,
    actionButtons = {
        SHOP_BUTTON
    }
})





local pickButton = {
    action = function(ent, clientId)
        shopButtonBuyItem(ent, clientId)
        if server then
            deleteAttachedItems(ent)
            ent.doomCount = 1
        end
    end,
    canDisplay = canDisplayShopButton,
    canClick = canClickShopButton,
    text = loc("PICK"),
    color = objects.Color(0.39,0.66,0.24),
}

lp.defineSlot("lootplot.s0.content:cloud_slot", {
    image = "cloud_slot",
    name = loc("Cloud slot"),
    description = loc("Pick single item from the adjacent cloud slots then destroy the others."),
    triggers = {},
    baseMaxActivations = 0,
    itemLock = true,

    slotItemProperties = {
        multipliers = {
            price = 0 -- make it free
        }
    },

    canPlayerAccessItemInSlot = function(slotEnt)
        return not slotEnt.itemLock
    end,

    actionButtons = {
        pickButton
    }
})
