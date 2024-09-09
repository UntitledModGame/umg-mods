local selection = require("shared.selection")
local util = require("shared.util")

local shopService = {}

local ENT_1 = {"entity"}


local buyItem = util.remoteServerCall("lootplot:buyItem", ENT_1,
function(clientId, itemEnt)
    -- TODO: check validity of arguments (bad actor could send any entity)
    -- TODO: check that we are allowed to do this!!!
    local slotEnt = lp.itemToSlot(itemEnt)
    if slotEnt then
        lp.subtractMoney(itemEnt, itemEnt.price)
        itemEnt.lootplotTeam = clientId -- mark as owned by player
        slotEnt.shopLock = false
    end
end)


---@param ent lootplot.ItemEntity
function shopService.buy(ent)
    if lp.getMoney(ent) >= ent.price then
        buyItem(ent)
        umg.log.trace("Buying item: ", ent)
        return true
    end
    umg.log.trace("Buy failed! ", ent)
    return false
end

-- This handles buy/sell/destroy button
umg.answer("lootplot:pollSelectionButtons", function(ppos)
    local itemEnt = lp.posToItem(ppos)
    local slotEnt = lp.posToSlot(ppos)
    if not (itemEnt and slotEnt) then
        return nil
    end

    if slotEnt.shopLock then
        -- add buy button
        return {
            text = function()
                return "Buy ($"..itemEnt.price..")"
            end,
            color = "green",
            onClick = function()
                if shopService.buy(itemEnt) then
                    selection.reset()
                    --[[
                    Don't open selection buttons; 
                    (for 2 reasons)
                    1: The data is outdated, (serv hasnt responded yet) and we will get wrong buttons
                    2: the player has just purchased the item, and won't be interested in selling it anyway!!
                    ]]
                    selection.selectSlotNoButtons(slotEnt)
                end
            end,
            canClick = function()
                return lp.getMoney(itemEnt) >= itemEnt.price
            end,
            priority = 0,
        }
    end
end)
