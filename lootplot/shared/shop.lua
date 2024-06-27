local selection = require("shared.selection")
local util = require("shared.util")

local shopService = {}

local ENT_1 = {"entity"}

umg.definePacket("lootplot:sellItem", {typelist = ENT_1})
local sellItem = util.remoteServerCall("lootplot:sellItem", ENT_1,
function(clientId, itemEnt)
    -- TODO: check validity of arguments (bad actor could send any entity)
    -- TODO: check that we are allowed to do this!!!
    lp.addMoney(itemEnt, shopService.getSellPrice(itemEnt))
    lp.destroy(itemEnt)
end)

local buyItem = util.remoteServerCall("lootplot:buyItem", ENT_1,
function(clientId, itemEnt)
    -- TODO: check validity of arguments (bad actor could send any entity)
    -- TODO: check that we are allowed to do this!!!
    lp.subtractMoney(itemEnt, shopService.getBuyPrice(itemEnt))
    itemEnt.sellPrice = itemEnt.buyPrice / 2
    itemEnt:removeComponent("buyPrice")
end)

local destroyItem = util.remoteServerCall("lootplot:destroyItem", ENT_1,
function(clientId, itemEnt)
    -- TODO: check validity of arguments (bad actor could send any entity)
    -- TODO: check that we are allowed to do this!!!
    lp.destroy(itemEnt)
end)

---Get sell price, affected by modifier
---@param ent lootplot.ItemEntity
function shopService.getSellPrice(ent)
    -- REMOVING THESE IN FAVOUR OF PROPERTIES::
    -- local mult = umg.ask("lootplot:getEntitySellMultiplier", ent) or 1
    -- local add = umg.ask("lootplot:getEntitySellModifier", ent) or 0
    return (ent.sellPrice + add) * mult
end

---Get buy price, affected by modifier
---@param ent lootplot.ItemEntity
function shopService.getBuyPrice(ent)
    return ent.buyPrice
end

---@param ent lootplot.ItemEntity
function shopService.sell(ent)
    if shopService.canSell(ent) then
        sellItem(ent)
        return true
    end

    return false
end

---@param ent lootplot.ItemEntity
function shopService.buy(ent)
    if shopService.canBuy(ent) then
        local price = shopService.getBuyPrice(ent)

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
function shopService.canSell(ent)
    return ent:hasComponent("sellPrice")
end

---@param ent lootplot.ItemEntity
function shopService.canBuy(ent)
    return ent:hasComponent("buyPrice")
end

umg.on("lootplot:pollSlotButtons", function(ppos, list)
    local ent = lp.posToItem(ppos)
    if not ent then return end

    if shopService.canSell(ent) then
        list:add(ui.elements.SellButton({
            onSell = function()
                print("Selling entity", ent)
                if shopService.sell(ent) then
                    selection.reset()
                end
            end,
            getPrice = function()
                return shopService.getSellPrice(ent)
            end,
        }))
    elseif shopService.canBuy(ent) then
        -- add buy button
        list:add(ui.elements.Button({
            onClick = function()
                if shopService.buy(ent) then
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
