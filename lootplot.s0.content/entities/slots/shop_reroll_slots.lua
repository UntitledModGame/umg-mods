
local loc = localization.localize
local interp = localization.newInterpolator

local shopHelper = require("shared.shop_helper")
local itemGenHelper = require("shared.item_gen_helper")


local function defShopSlot(id, name, etype)
    etype.name = loc(name)
    etype.image = etype.image or id
    lp.defineSlot("lootplot.s0.content:" .. id, etype)
end


local truthy = function ()return 1 end
local generateItem = itemGenHelper.createLazyGenerator(
    truthy,
    itemGenHelper.createRarityWeightAdjuster({
        COMMON = 3,
        UNCOMMON = 2,
        RARE = 1,
        EPIC = 0.333,
        LEGENDARY = 0.02,
    })
)


defShopSlot("shop_slot", "Shop slot", {
    itemLock = true,
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
        shopHelper.setItemLock(slotEnt, true)
    end,
    onItemDraw = shopHelper.drawItemPrice,
    actionButtons = {
        shopHelper.SHOP_BUTTON
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
        shopHelper.setItemLock(slotEnt, true)
    end,
    onItemDraw = function(selfEnt, itemEnt, x,y, rot, sx,sy)
        if selfEnt.rerollLock then
            rendering.drawImage("slot_reroll_padlock", x,y, rot, sx,sy)
        end
        return shopHelper.drawItemPrice(selfEnt, itemEnt)
    end,
    actionButtons = {
        shopHelper.SHOP_BUTTON,
        shopHelper.LOCK_REROLL_BUTTON
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
        shopHelper.LOCK_REROLL_BUTTON
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
    onItemDraw = shopHelper.drawItemPrice,
    actionButtons = {
        shopHelper.SHOP_BUTTON
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
    onItemDraw = shopHelper.drawItemPrice,
    actionButtons = {
        shopHelper.SHOP_BUTTON
    }
})


--[[

TODO:
Create CHOICE-SHOP slots.
(Or maybe we should call them "strong" shop-slots...??)

Basically; the idea is that if you buy one item;
all other items disappear.
So you can only choose 1.

]]
local pickButton = {
    action = function(ent, clientId)
        umg.melt([[
        This is bad and broken. Fix this!

        We can actually make this code a WHOLE lot better;
        We should make the whole "consider" thing a helper-function;
        and we should add implicit `queueWithEntity` to it.loc

        Note that we also probably want to reuse this code for other
        slots (specifically; strong-shop-slots; not just cloud-slots.)
        ]])

        shopButton.action(ent, clientId)

        if not server then
            return
        end

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
