
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
local function setItemLock(ent, bool)
    ent.itemLock = bool
    sync.syncComponent(ent, "itemLock")
end

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


local shopButton = {
    action = function(ent, clientId)
        if server then
            buyServer(ent)
        elseif client then
            buyClient(ent)
        end
    end,
    canDisplay = function(ent, clientId)
        return ent.itemLock
    end,
    canClick = function(ent, clientId)
        local itemEnt = lp.slotToItem(ent)
        if itemEnt and ent.itemLock then
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




---@param ent Entity
---@param bool boolean
local function setRerollLock(ent, bool)
    ent.rerollLock = bool
    sync.syncComponent(ent, "rerollLock")
end

local LOCK_TEXT = loc("Lock")
local UNLOCK_TEXT = loc("Unlock")

local lockRerollButton = {
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

local function drawItemPrice(selfEnt, itemEnt)
    if selfEnt.itemLock and itemEnt.price then
        if itemEnt.price > 0 then
            love.graphics.setColor(PRICE_COLOR)
        else
            love.graphics.setColor(GREEN_PRICE_COLOR)
        end
        printCenterWithOutline(PRICE_TEXT(itemEnt), itemEnt.x, itemEnt.y, 0, 0.75, 0.75, 20, 0, 0)
    end
end

lp.defineSlot("lootplot.s0.content:shop_slot", {
    itemLock = true,
    image = "shop_slot",

    name = loc("Shop slot"),
    activateDescription = loc("Spawns a random item."),

    triggers = {"REROLL", "PULSE"},

    itemSpawner = generateItem,
    itemReroller = generateItem,

    baseCanSlotPropagate = false,
    baseMaxActivations = 100,

    canPlayerAccessItemInSlot = function(slotEnt, itemEnt)
        return not slotEnt.itemLock
    end,
    onActivate = function(slotEnt)
        setItemLock(slotEnt, true)
    end,
    onItemDraw = function(selfEnt, itemEnt)
        drawItemPrice(selfEnt, itemEnt)
    end,
    actionButtons = {
        shopButton
    }
})




lp.defineSlot("lootplot.s0.content:lockable_shop_slot", {
    itemLock = true,

    image = "shop_slot",
    -- TODO: make a different image for this!

    baseMaxActivations = 100,
    name = loc("Lockable Shop slot"),
    triggers = {"REROLL", "PULSE"},
    itemSpawner = generateItem,
    itemReroller = generateItem,
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
        drawItemPrice(selfEnt, itemEnt)
    end,
    actionButtons = {
        shopButton,
        lockRerollButton
    }
})




lp.defineSlot("lootplot.s0.content:reroll_slot", {
    image = "reroll_slot",
    name = loc("Reroll slot"),
    activateDescription = loc("Rerolls item."),
    triggers = {"REROLL", "PULSE"},
    itemReroller = generateItem,
    baseCanSlotPropagate = false,
    baseMaxActivations = 500,
})



lp.defineSlot("lootplot.s0.content:lockable_reroll_slot", {
    image = "reroll_slot",
    -- TODO ^^^ different image pls!

    name = loc("Reroll slot"),
    description = loc("Put an item inside to reroll it!"),
    triggers = {"REROLL", "PULSE"},
    itemReroller = generateItem,
    baseCanSlotPropagate = false,
    baseMaxActivations = 500,
    canActivate = function(ent)
        return not ent.rerollLock
    end,
    actionButtons = {
        lockRerollButton
    }
})



lp.defineSlot("lootplot.s0.content:treasure_slot", {
    itemLock = true,
    image = "slot",
    color = {objects.Color.RED:getRGBA()},

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
    onItemDraw = function(selfEnt, itemEnt)
        drawItemPrice(selfEnt, itemEnt)
    end,
    actionButtons = {
        shopButton
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
    onItemDraw = function(selfEnt, itemEnt)
        drawItemPrice(selfEnt, itemEnt)
    end,
    actionButtons = {
        shopButton
    }
})


local pickButton = {
    action = function(ent, clientId)
        shopButton.action(ent, clientId)

        if server then
            -- Set current entity to DOOMED-1
            ent.doomCount = 1
            ent.cloudSlotPicked = true
            local stack = {}

            ---@param ppos lootplot.PPos
            ---@param x integer
            ---@param y integer
            local function consider(ppos, x, y)
                local targPPos = ppos:move(x, y)
                if targPPos then
                    local slotEnt = lp.posToSlot(targPPos)
                    if slotEnt and slotEnt:hasComponent("cloudSlotPicked") and not slotEnt.cloudSlotPicked then
                        stack[#stack+1] = targPPos:getSlotIndex()
                    end
                end
            end

            local ppos = assert(lp.getPos(ent))
            local plot = ppos:getPlot()
            consider(ppos, -1, 0)
            consider(ppos, 0, -1)
            consider(ppos, 1, 0)
            consider(ppos, 0, 1)

            while #stack > 0 do
                local stackPPos = plot:getPPosFromSlotIndex(table.remove(stack))
                local slotEnt = lp.posToSlot(stackPPos)

                if slotEnt and slotEnt:hasComponent("cloudSlotPicked") and not slotEnt.cloudSlotPicked then
                    local itemEnt = lp.posToItem(stackPPos)
                    if itemEnt then
                        -- TODO: Use "delete instantly" mechanism so DESTROY trigger is not triggered.
                        lp.destroy(itemEnt)
                    end

                    lp.destroy(slotEnt)
                    consider(stackPPos, -1, 0)
                    consider(stackPPos, 0, -1)
                    consider(stackPPos, 1, 0)
                    consider(stackPPos, 0, 1)
                end
            end
        end
    end,
    canDisplay = shopButton.canDisplay,
    canClick = shopButton.canClick,
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

    cloudSlotPicked = false, -- used to prevent item being destroyed when propagating across cloud slots.

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
