local selection = require("shared.selection")
local util = require("shared.util")

local shopService = {}

local ENT_1 = {"entity"}

umg.definePacket("lootplot:sellItem", {typelist = ENT_1})
local sellItem = util.remoteServerCall("lootplot:sellItem", ENT_1,
function(clientId, itemEnt)
    -- TODO: check validity of arguments (bad actor could send any entity)
    -- TODO: check that we are allowed to do this!!!
    if itemEnt.sellPrice > 0 then
        lp.addMoney(itemEnt, itemEnt.sellPrice)
    else
        lp.subtractMoney(itemEnt, -itemEnt.sellPrice)
    end

    lp.destroy(itemEnt)
end)

local buyItem = util.remoteServerCall("lootplot:buyItem", ENT_1,
function(clientId, itemEnt)
    -- TODO: check validity of arguments (bad actor could send any entity)
    -- TODO: check that we are allowed to do this!!!
    local slotEnt = lp.itemToSlot(itemEnt)
    if slotEnt then
        lp.subtractMoney(itemEnt, itemEnt.buyPrice)
        itemEnt.ownerPlayer = clientId -- mark as owned by player
        slotEnt.shopLock = false
    end
end)

---@param ent lootplot.ItemEntity
function shopService.sell(ent)
    sellItem(ent)
    return true
end

---@param ent lootplot.ItemEntity
function shopService.buy(ent)
    if lp.getMoney(ent) >= ent.buyPrice then
        buyItem(ent)
        return true
    else
        print("Not enough money")
    end

    return false
end

-- This handles buy/sell/destroy button
umg.answer("lootplot:pollSlotButtons", function(ppos)
    local itemEnt = lp.posToItem(ppos)
    local slotEnt = lp.posToSlot(ppos)
    if not (itemEnt and slotEnt) then
        return nil
    end

    if slotEnt.shopLock then
        -- add buy button
        return {
            text = text.RichText("Buy (${$buyPrice})", {
                variables = itemEnt
            }),
            color = objects.Color.GREEN,
            onClick = function()
                if shopService.buy(itemEnt) then
                    selection.reset()
                    -- selection.selectSlot(slotEnt)
                end
            end,
            priority = 0,
        }
    else
        local isSell = itemEnt.sellPrice > 0
        local kind = isSell and "Sell" or "Destroy"
        return {
            text = text.RichText(kind.." (${$getPrice()})", {
                variables = {
                    getPrice = function()
                        return math.abs(itemEnt.sellPrice)
                    end
                }
            }),
            color = isSell and objects.Color.GOLD or objects.Color.RED,
            onClick = function()
                if lp.canPlayerAccess(itemEnt, client.getClient()) then
                    shopService.sell(itemEnt)
                    selection.reset()
                end
            end,
            canClick = function()
                return lp.canPlayerAccess(itemEnt, client.getClient())
            end,
            priority = 0,
        }
    end
end)
