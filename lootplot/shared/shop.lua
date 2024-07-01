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
    lp.subtractMoney(itemEnt, itemEnt.buyPrice)
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

umg.on("lootplot:pollSlotButtons", function(ppos, list)
    local itemEnt = lp.posToItem(ppos)
    local slotEnt = lp.posToSlot(ppos)
    if not (itemEnt and slotEnt) then
        return
    end

    if slotEnt.shopSlot then
        -- add buy button
        list:add(ui.elements.CostButton({
            onClick = function()
                if shopService.buy(itemEnt) then
                    selection.reset()
                    selection.selectSlot(slotEnt)
                end
            end,
            getCost = function()
                return itemEnt.buyPrice
            end,
            text = "Buy"
        }))
    else
        list:add(ui.elements.CostButton({
            onClick = function()
                print("Destroy or sell pressed")
                sellItem(itemEnt)
                selection.reset()
            end,
            getCost = function()
                return math.abs(itemEnt.sellPrice)
            end,
            text = itemEnt.sellPrice > 0 and "Sell" or "Destroy"
        }))
    end
end)
