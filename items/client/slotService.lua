

local slotService = {}



local ALPHA_BUTTON = 1
local BETA_BUTTON = 2



local focusedSlot = nil
local halfStack = false



local function getFocusedItem()
    return focusedSlot:getItem()
end

local function getFocusedEntity()
    return focusedSlot:getInventory().owner
end


local function focusElement(slot, isBeta)
    focusedSlot = slot
    halfStack = isBeta
end



local function reset()
    focusedSlot = nil
    halfStack = false
end




local function getAuthorizedControlEntity(invEnt)
    -- warning: this is O(n)
    local clientId = client.getClient()
    local ents = control.getControlledEntities(clientId)

    for _, ent in ipairs(ents) do
        if invEnt then
            return ent
        end
    end
end




local function getControlTransferEntity(inv1, inv2)
    --[[
        Players can only move things around inventories
        if they have a controlEnt that can facilitate the transer.

        look through all controlled entities, filter for
        the ones controlled by the client, and return any that
        are able to make the transfer between inv1 and inv2.
    ]]
    for _, ent in ipairs(controlInventoryGroup) do
        if sync.isClientControlling(ent) then
            if inv1:canBeOpenedBy(ent) then
                if inv2 == inv1 or inv2:canBeOpenedBy(ent) then
                    return ent
                end
            end
        end
    end
    return false
end





local function tryPutOne(slot)
    local controlEnt = getControlTransferEntity()
    local item = getFocusedItem()
    local targ = inv:get(x,y)
    if (not targ) or targ.itemName == item.itemName then
        client.send("inventory:tryMoveInventoryItem", 
            controlEnt, 
            focus_inv.owner, inv.owner, 
            focusSlot, otherSlot, 1
        )
    end
end


function slotService.interact(slotElement, button)
    local slot = slotElement
    local isFocused = getFocusedItem()

    if button == ALPHA_BUTTON then
        if isFocused then
            tryMoveOrSwap(slot)
            reset()
        else
            focusElement(slot, false)
        end

    elseif button == BETA_BUTTON then
        if isFocused then
            tryPutOne(slot)
        else
            focusElement(slot, true)
        end
    end
end



return slotService
