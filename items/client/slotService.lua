

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




local function getAccessCandidates(invEnt)
    --[[
        Gets a list of control-entities that can access invEnt
    ]] 
    local clientId = client.getClient()
    local array = objects.Array()
    for _, ent in ipairs(control.getControlledEntities(clientId)) do
        if invEnt:canBeOpenedBy(ent) then
            array:add(ent)
        end
    end
    return array
end



local function getTransferCandidates(inv1, inv2)
    --[[
        Get a list of control-entities that are able to access BOTH
        inv1 AND inv2.
    ]]
    local array = objects.Array()
    for _, ent in ipairs(control.getControlledEntities()) do
        if inv1:canBeOpenedBy(ent) then
            if inv2 == inv1 or inv2:canBeOpenedBy(ent) then
                array:add(ent)
            end
        end
    end
    return array
end





local function tryMove(slot, count)
    local controlEnt = getAccessCandidates()
    local item = getFocusedItem()
    local targ = inv:get(x,y)
    if (not targ) or targ.itemName == item.itemName then
        client.send("inventory:tryMoveInventoryItem", 
            controlEnt, 
            focus_inv.owner, inv.owner, 
            focusSlot, otherSlot, count
        )
    end
end


local function tryMoveOrSwap(slot)
    local item = getFocusedItem()
    local targItem = slot:getItem()
    if (not targItem) or h.canCombineStacks(item, targItem) then
        -- move: Items can be combined!

    else

    end
    -- swap: When stacks are different, or there's no space
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
            tryMove(slot, 1)
        else
            focusElement(slot, true)
        end
    end
end



return slotService
