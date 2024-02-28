

local slotService = {}



local ALPHA_BUTTON = 1
local BETA_BUTTON = 2



local focusedSlot = nil
local halfStack = false




local function getFocused()
    -- gets the (inventoryEnt, slot, item) that is being focused
    if not focusedSlot then
        return
    end
    local item = focusedSlot:getItem()
    local invEnt = focusedSlot:getInventory()
    local slot = focusedSlot:getSlot()
    if umg.exists(item) and umg.exists(invEnt) then
        return invEnt, slot, item
    end
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
        if invEnt:canBeAccessedBy(ent) then
            array:add(ent)
        end
    end
    return array
end



local function getDoubleAccessCandidates(inv1, inv2)
    --[[
        Get a list of control-entities that are able to access BOTH
        inv1 AND inv2.
    ]]
    return getAccessCandidates(inv1):filter(function(controlEnt)
        inv2:canBeAccessedBy(controlEnt)
    end)
end



local function getMoveAccessCandidates(srcEnt, targEnt)
    return getDoubleAccessCandidates(srcEnt, targEnt)
        :filter(function(controlEnt)
            
        end)
end




local function moveItem(controlEnt, targetInventory, targetSlot, count)
    -- Moves `count` items from the focused inventory,
    -- to some target inventory.
    local srcInvEnt, slot, item = getFocused()

    local targetEnt = targetInventory.owner
    client.send("inventory:tryMoveInventoryItem",
        controlEnt, 
        srcInvEnt, targetEnt, 
        srcSlot, targetSlot, 
        count
    )
end





local function tryMove(targInv, targSlot, count)
    local controlEnts = getAccessCandidates()

    for _, ent in ipairs(controlEnts) do
        moveItem(controlEnt, targInv, targSlot, count)
    end
end


local function tryMoveOrSwap(slot)
    local _invEnt, _slot, item = getFocused()

    local targItem = slot:getItem()
    if (not targItem) or h.canCombineStacks(item, targItem) then
        -- move: Items can be combined!

    else

    end
    -- swap: When stacks are different, or there's no space
end


function slotService.interact(slotElement, button)
    local isFocused = getFocusedItem()

    local targetSlot = slotElement:getSlot()
    local targetInv = slotElement:getInventory()

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
