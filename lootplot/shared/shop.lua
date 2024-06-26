local selection = require("shared.selection")
local util = require("shared.util")

local ShopService = {}

local ENT_1 = {"entity"}

umg.definePacket("lootplot:sellItem", {typelist = ENT_1})
local sellItem = util.remoteServerCall("lootplot:sellItem", ENT_1,
function(clientId, itemEnt)
    -- TODO: check validity of arguments (bad actor could send any entity)
    -- TODO: check that we actually CAN move the items
    -- TODO: use qbus; check if we have permission
    lp.addMoney(itemEnt, ShopService.getSellPrice(itemEnt))
    lp.destroy(itemEnt)
end)

local buyItem = util.remoteServerCall("lootplot:buyItem", ENT_1,
function(clientId, itemEnt)
    -- TODO: check validity of arguments (bad actor could send any entity)
    -- TODO: check that we actually CAN move the items
    -- TODO: use qbus; check if we have permission
    lp.subtractMoney(itemEnt, ShopService.getBuyPrice(itemEnt))
    itemEnt.sellPrice = itemEnt.buyPrice / 2
    itemEnt:removeComponent("buyPrice")
end)

local destroyItem = util.remoteServerCall("lootplot:destroyItem", ENT_1,
function(clientId, itemEnt)
    -- TODO: check validity of arguments (bad actor could send any entity)
    -- TODO: check that we actually CAN move the items
    -- TODO: use qbus; check if we have permission
    lp.destroy(itemEnt)
end)

---Get sell price, affected by modifier
---@param ent lootplot.ItemEntity
function ShopService.getSellPrice(ent)
    local mult = umg.ask("lootplot:getEntitySellMultiplier", ent) or 1
    local add = umg.ask("lootplot:getEntitySellModifier", ent) or 0
    return (ent.sellPrice + add) * mult
end

---Get buy price, affected by modifier
---@param ent lootplot.ItemEntity
function ShopService.getBuyPrice(ent)
    return ent.buyPrice
end

---@param ent lootplot.ItemEntity
function ShopService.sell(ent)
    if ShopService.canSell(ent) then
        sellItem(ent)
        return true
    end

    return false
end

---@param ent lootplot.ItemEntity
function ShopService.buy(ent)
    if ShopService.canBuy(ent) then
        local price = ShopService.getBuyPrice(ent)

        if lp.getMoney(ent) >= price then
            buyItem(ent)
            return true
        else
            print("Not enough money")
        end
    end

    return false
end

---@param ent lootplot.ItemEntity
function ShopService.canSell(ent)
    return ent:hasComponent("sellPrice")
end

---@param ent lootplot.ItemEntity
function ShopService.canBuy(ent)
    return ent:hasComponent("buyPrice")
end

umg.on("lootplot:pollSlotButtons", function(ppos, list)
    local ent = lp.posToItem(ppos)
    if not ent then return end

    if ShopService.canSell(ent) then
        list:add(ui.elements.SellButton({
            onSell = function()
                print("Selling entity", ent)
                if ShopService.sell(ent) then
                    selection.reset()
                end
            end,
            getPrice = function()
                return ShopService.getSellPrice(ent)
            end,
        }))
    elseif ShopService.canBuy(ent) then
        -- add buy button
        list:add(ui.elements.Button({
            onClick = function()
                if ShopService.buy(ent) then
                    selection.reset()
                end
            end,
            text = "Buy"
        }))
    else
        list:add(ui.elements.Button({
            onClick = function()
                print("Destroy pressed")
                destroyItem(ent)
                selection.reset()
            end,
            text = "Destroy"
        }))
    end
end)
