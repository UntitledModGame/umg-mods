
local loc = localization.localize
local interp = localization.newInterpolator

local constants = require("shared.constants")

local itemGenHelper = require("shared.item_gen_helper")




local drawRarityParticles
if client then

local RARITY_PSYS

local function tryLoadPsys()
    if RARITY_PSYS then
        return
    end

    RARITY_PSYS = love.graphics.newParticleSystem(client.atlas:getTexture())
    RARITY_PSYS:setQuads({
        -- client.assets.images.item_rarity_particle_1,
        -- client.assets.images.item_rarity_particle_2,
        -- client.assets.images.item_rarity_particle_3,
        -- client.assets.images.item_rarity_particle_4,
        -- client.assets.images.item_rarity_particle_5,
        -- client.assets.images.item_rarity_particle_6,
        -- client.assets.images.item_rarity_particle_7,

        client.assets.images.ball_1,
        client.assets.images.ball_1,
        client.assets.images.ball_1,
        client.assets.images.ball_2,
        client.assets.images.ball_2,
        client.assets.images.ball_3,
        client.assets.images.ball_4,
    })

    RARITY_PSYS:setEmissionRate(16)
    RARITY_PSYS:setEmissionArea("normal", 3, 1)
    RARITY_PSYS:setSpeed(10,11)
    RARITY_PSYS:setParticleLifetime(1.6,1.8)
    RARITY_PSYS:setDirection(-math.pi/2)
end


umg.on("@update", function(dt)
    tryLoadPsys()
    RARITY_PSYS:update(dt)
end)


local SIGNIFICANT_RARITIES = {
    [lp.rarities.EPIC] = true,
    [lp.rarities.LEGENDARY] = true
}

function drawRarityParticles(ent, x, y)
    local itemEnt = lp.slotToItem(ent)

    if itemEnt and itemEnt.rarity and RARITY_PSYS then
        ---@type lootplot.rarities.Rarity
        local r = itemEnt.rarity
        if SIGNIFICANT_RARITIES[r] then
            local color = r.color
            love.graphics.push("all")
            love.graphics.setColor(color)
            love.graphics.draw(RARITY_PSYS, x, y)
            love.graphics.pop()
        end
    end
end


end


local function defShopSlot(id, name, etype)
    etype.name = loc(name)
    etype.image = etype.image or id

    assert(not etype.onDraw, "onDraw is overridden!! blergh")
    etype.onDraw = drawRarityParticles

    etype.rarity = etype.rarity or lp.rarities.UNCOMMON

    lp.defineSlot("lootplot.s0:" .. id, etype)
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




local entNumTc = typecheck.assert("entity", "number")
local function buyItemAnalytics(itemEnt, itemPrice)
    assert(server, "should only be called server-side")
    entNumTc(itemEnt, itemPrice)

    umg.analytics.collect("lootplot.s0:buyItem", {
        playerWinCount = lp.getWinCount(),
        level = lp.getLevel(itemEnt),
        money = lp.getMoney(itemEnt),
        itemId = itemEnt:getEntityType():getTypename(),
        itemPrice = itemPrice, -- cloud slots pass price=0
    })
end



local BUY_TEXT = interp("BUY ($%{price})")


local function buyClient(slotEnt)
    lp.deselectItem()
    local itemEnt = lp.slotToItem(slotEnt)
    if itemEnt then
        lp.selectItem(itemEnt, true)
    end
end

---@param slotEnt Entity
local function shopButtonBuyItem(slotEnt)
    if server then
        setRerollLock(slotEnt, false)
        local itemEnt = lp.slotToItem(slotEnt)
        if itemEnt then
            buyItemAnalytics(itemEnt, itemEnt.price)
            lp.subtractMoney(slotEnt, itemEnt.price)
            lp.tryTriggerEntity("BUY", itemEnt)
            setItemLock(slotEnt, false)
        end
    elseif client then
        buyClient(slotEnt)
    end
end

local function canDisplayShopButton(ent, clientId)
    return ent.itemLock
end

local function canClickShopButton(ent, clientId)
    local itemEnt = lp.slotToItem(ent)
    if itemEnt and ent.itemLock then
        local money = lp.getMoney(itemEnt) or 0
        if money >= itemEnt.price then
            -- then we can afford the item
            return true
        end
        if itemEnt.price <= 0 then
            -- we can always buy free/negative-price items, 
            -- no matter what.
            -- (This check is needed for when money is negative;
            --  we still want to be able to purchase free-items.)
            return true
        end
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
    local etype = {
        itemLock = true,

        baseMaxActivations = 100,
        triggers = {"REROLL", "PULSE"},
        dontPropagateTriggerToItem = true,
        isItemListenBlocked = true,
        canActivate = function(ent)
            -- if rerollLock=true, then we dont activate!
            return (not ent.rerollLock) or (not lp.slotToItem(ent))
        end,
        canPlayerAccessItemInSlot = function(slotEnt, itemEnt)
            return not slotEnt.itemLock
        end,
        onActivate = function(slotEnt)
            setItemLock(slotEnt, true)
            setRerollLock(slotEnt, false)
        end,
        onItemDraw = function(selfEnt, itemEnt, x,y, _rot, sx,sy)
            if selfEnt.rerollLock then
                rendering.drawImage("slot_reroll_padlock", x,y, 0, sx,sy)
            end
            return drawItemPrice(selfEnt, itemEnt)
        end,
    }
    for k,v in pairs(comps) do
        etype[k]=v
    end
    defShopSlot(id, name, etype)
end




local generateItem

do
generateItem = itemGenHelper.createLazyGenerator(
    function(etype)
        ---@cast etype table
        if lp.hasTag(etype, constants.tags.FOOD) then
            -- dont spawn food-items in normal-shop
            return false
        end
        return true
    end,
    itemGenHelper.createRarityWeightAdjuster({
        COMMON = 10,
        UNCOMMON = 1,
        RARE = 0.03,
        EPIC = 0.02
    })
)
end

makeShopSlot("shop_slot", "Shop Slot", {
    activateDescription = loc("Spawns items to buy"),
    baseMaxActivations = 100,
    itemReroller = generateItem,
    itemSpawner = generateItem,
    actionButtons = {
        SHOP_BUTTON,
        LOCK_REROLL_BUTTON
    }
})



makeShopSlot("emerald_shop_slot", "Emerald Shop Slot", {
    activateDescription = loc("Spawns items to buy, and gives them {lootplot:TRIGGER_COLOR}Reroll{/lootplot:TRIGGER_COLOR} trigger"),
    baseMaxActivations = 100,
    itemReroller = generateItem,
    itemSpawner = generateItem,
    actionButtons = {
        SHOP_BUTTON,
        LOCK_REROLL_BUTTON
    },

    onPostActivate = function(ent)
        local itemEnt = lp.slotToItem(ent)
        if itemEnt then
            lp.addTrigger(itemEnt, "REROLL")
        end
    end,
    unlockAfterWins = 4,
    rarity = lp.rarities.EPIC
})


makeShopSlot("pink_shop_slot", "Pink Shop Slot", {
    activateDescription = loc("Spawns items to buy, and gives them {lootplot:LIFE_COLOR}+3 lives{/lootplot:LIFE_COLOR}"),
    baseMaxActivations = 100,
    itemReroller = generateItem,
    itemSpawner = generateItem,
    actionButtons = {
        SHOP_BUTTON,
        LOCK_REROLL_BUTTON
    },

    onPostActivate = function(ent)
        local itemEnt = lp.slotToItem(ent)
        if itemEnt then
            itemEnt.lives = (itemEnt.lives or 0) + 3
        end
    end,
    unlockAfterWins = 4,
    rarity = lp.rarities.EPIC
})



makeShopSlot("purple_shop_slot", "Purple Shop Slot", {
    activateDescription = loc("Spawns items to buy, and gives them {lootplot:DOOMED_COLOR}DOOMED-10{/lootplot:DOOMED_COLOR}"),
    baseMaxActivations = 100,
    itemReroller = generateItem,
    itemSpawner = generateItem,
    actionButtons = {
        SHOP_BUTTON,
        LOCK_REROLL_BUTTON
    },

    onPostActivate = function(ent)
        local itemEnt = lp.slotToItem(ent)
        if itemEnt then
            itemEnt.doomCount = 10
        end
    end,
    unlockAfterWins = 4,
    rarity = lp.rarities.UNCOMMON
})





local function isFoodItem(etype)
    return lp.hasTag(etype, constants.tags.FOOD)
end

local generateFoodItem = itemGenHelper.createLazyGenerator(
    isFoodItem,
    itemGenHelper.createRarityWeightAdjuster({
        COMMON = 32,
        UNCOMMON = 6,
        RARE = 1,
        EPIC = 0.3,
        LEGENDARY = 0.04
    })
)

makeShopSlot("food_shop_slot", "Food Shop Slot", {
    activateDescription = loc("Spawns food items"),
    baseMaxActivations = 100,

    onActivate = function(slotEnt)
        local itemId = generateFoodItem()
        local etype = server.entities[itemId]
        local ppos = lp.getPos(slotEnt)
        if not ppos then return end

        lp.forceSpawnItem(ppos, etype, slotEnt.lootplotTeam)
        setItemLock(slotEnt, true)
        setRerollLock(slotEnt, false)
    end,

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

            consider(ppos, -1, -1)
            consider(ppos, 1, -1)
            consider(ppos, 1, 1)
            consider(ppos, -1, 1)
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
                    lp.wait(pos1, 0.06)
                end
            end)
        end
    end
end






lp.defineSlot("lootplot.s0:reroll_slot", {
    image = "reroll_slot",
    name = loc("Reroll slot"),
    activateDescription = loc("Transforms items into a random item"),
    triggers = {"REROLL"},
    itemReroller = generateItem,

    dontPropagateTriggerToItem = true,
    isItemListenBlocked = true,
    baseMaxActivations = 500,

    rarity = lp.rarities.RARE,

    canActivate = function(ent)
        return not ent.rerollLock
    end,
    actionButtons = {
        LOCK_REROLL_BUTTON
    }
})






local function alwaysTrue()
    return true
end

local OFFER_BUTTON = {
    action = function(ent, _clientId)
        local itemEnt = lp.slotToItem(ent)
        if server then
            if itemEnt then
                buyItemAnalytics(itemEnt, itemEnt.price or 0)
                lp.tryTriggerEntity("BUY", itemEnt)
            end
            local ppos = lp.getPos(ent)
            if ppos then
                local nullSlotType = server.entities["null_slot"]
                local slotEnt = lp.forceSpawnSlot(ppos, nullSlotType, ent.lootplotTeam)
                if slotEnt then
                    slotEnt.doomCount = 2
                end
            end
        else
            assert(client)
            if itemEnt then
                -- HACK: we need to select the slot next-tick,
                -- This is because the server forceSpawns a null-slot,
                -- and invalidates the old selection.
                scheduling.nextTick(function()
                    if umg.exists(itemEnt) then
                        lp.selectItem(itemEnt, true)
                    end
                end)
            end
        end
    end,
    canDisplay = alwaysTrue,
    canClick = alwaysTrue,
    text = loc("Buy (FREE)"),
    color = objects.Color(0.39,0.66,0.24),
}




defShopSlot("offer_slot", "Offer Slot", {
    itemLock = true,
    image = "cloud_slot",
    color = objects.Color.RED,

    rarity = lp.rarities.UNIQUE,

    triggers = {"PULSE"},

    dontPropagateTriggerToItem = true,
    isItemListenBlocked = true,

    baseMaxActivations = 100,

    canPlayerAccessItemInSlot = function(slotEnt)
        return not slotEnt.itemLock
    end,

    slotListen = {
        trigger = "BUY",
        activate = function(slotEnt)
            slotEnt.doomCount = 1
        end
    },

    onActivate = function(slotEnt)
        if not (lp.slotToItem(slotEnt) or slotEnt:hasComponent("doomCount")) then
            slotEnt.doomCount = 1
        end
    end,

    actionButtons = {
        OFFER_BUTTON
    }
})





lp.defineSlot("lootplot.s0:paper_slot", {
    itemLock = true,
    image = "paper_slot",

    name = loc("Paper slot"),

    triggers = {"PULSE"},

    dontPropagateTriggerToItem = true,
    isItemListenBlocked = true,

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





--[[
This function will delete all "attached" slots;
That is, all items that are within a KING shape of the cloud slot
]]
local function deleteAttachedCloudSlots(ent)
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
        local slot = lp.posToSlot(ppos)
        if slot then
            slot:delete()
        end
    end)
end



local BUY_FREE_BUTTON = {
    action = function(ent, _clientId)
        local itemEnt = lp.slotToItem(ent)
        if server then
            deleteAttachedCloudSlots(ent)
            if itemEnt then
                buyItemAnalytics(itemEnt, itemEnt.price or 0)
                lp.tryTriggerEntity("BUY", itemEnt)
            end
            local ppos = lp.getPos(ent)
            if ppos then
                local nullSlotType = server.entities["null_slot"]
                local slotEnt = lp.forceSpawnSlot(ppos, nullSlotType, ent.lootplotTeam)
                if slotEnt then
                    slotEnt.doomCount = 2
                end
            end
        else
            assert(client)
            if itemEnt then
                -- HACK: we need to select the slot next-tick,
                -- This is because the server forceSpawns a null-slot,
                -- and invalidates the old selection.
                scheduling.nextTick(function()
                    if umg.exists(itemEnt) then
                        lp.selectItem(itemEnt, true)
                    end
                end)
            end
        end
    end,
    canDisplay = alwaysTrue,
    canClick = alwaysTrue,
    text = loc("Buy (FREE)"),
    color = objects.Color(0.39,0.66,0.24),
}


defShopSlot("cloud_slot", "Cloud slot", {
    activateDescription = loc("When picked, destroy nearby cloud slots."),

    rarity = lp.rarities.UNIQUE,

    baseMaxActivations = 1,
    dontPropagateTriggerToItem = true,

    isItemListenBlocked = true,

    itemLock = true,

    canPlayerAccessItemInSlot = function(slotEnt)
        return not slotEnt.itemLock
    end,

    actionButtons = {
        BUY_FREE_BUTTON
    }
})
