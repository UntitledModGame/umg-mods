

local h = require("shared.helper")



local slotService = {}



local ALPHA_BUTTON = 1
local BETA_BUTTON = 2



local focusedSlotElem = nil
local halfStack = false




local function getFocused()
    -- gets the (inventoryEnt, slot, item) that is being focused
    if not focusedSlotElem then
        return
    end
    local item = focusedSlotElem:getItem()
    local inv = focusedSlotElem:getInventory().owner
    local slot = focusedSlotElem:getSlot()
    if umg.exists(item) and umg.exists(inv.owner) then
        return inv, slot, item
    end
end




local function focusElement(slotElem, isBeta)
    print("FOC ELEM???")
    focusedSlotElem = slotElem
    halfStack = isBeta
end



local function reset()
    focusedSlotElem = nil
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



local getMoveAccessCandidatesTc = typecheck.assert("table", "number", "table", "number")
local function getMoveAccessCandidates(srcInv, srcSlot, targInv, targSlot)
    getMoveAccessCandidatesTc(srcInv, srcSlot, targInv, targSlot)
    --[[
        gets a list of control-entities that are can move an
        item across inventories, from a slot, to another slot.
    ]]
    local itemEnt = srcInv:get(srcSlot)
    return getDoubleAccessCandidates(srcInv, targInv)
        :filter(function(controlEnt)
            return targInv:itemCanBeAddedBy(controlEnt, targSlot, itemEnt)
        end)
        :filter(function(controlEnt)
            return srcInv:itemCanBeRemovedBy(controlEnt, targSlot)
        end)
end



local function getSwapAccessCandidates(inv1, slot1, inv2, slot2)
    getMoveAccessCandidatesTc(inv1, slot1, inv2, slot2)
    --[[
        gets a set of controlEnts that can swap 2 items in an inventory.
    ]]
    local cand1 = objects.Set(getMoveAccessCandidates(inv1, slot1, inv2, slot2))
    local cand2 = objects.Set(getMoveAccessCandidates(inv2, slot2, inv1, slot1))
    return cand1:intersection(cand2)
end






local function tryMove(targInv, targSlot, count)
    local controlEnt = getMoveAccessCandidates()[1]
    if controlEnt then
        local invEnt, slot, _item = getFocused()
        local targInvEnt = targInv.owner
        client.send("items:tryMoveItem",
            controlEnt, 
            invEnt, slot, 
            targInvEnt, targSlot, 
            count
        )
    end
end


local function trySwap(inv1, slot1)
    local inv2, slot2, _item = getFocused()
    local controlEnt = getSwapAccessCandidates(inv1, slot1, inv2, slot2)[1]
    if controlEnt then
        client.send("items:trySwapItems", controlEnt, inv1, slot1, inv2, slot2)
    end
end




local function tryMoveOrSwap(slotElem, count)
    local _invEnt, _slot, item = getFocused()
    local targItem = slotElem:getItem()

    count = h.getMoveStackCount(item, count, targItem)

    local targInv, targSlot = slotElem:getInventory(), slotElem:getSlot()
    if (not targItem) or (count > 0) then
        -- move: Items can be combined!
        tryMove(targInv, targSlot, count)
    else
        -- swap: When stacks are different, or there's no space
        trySwap(targInv, targSlot)
    end
end



local function getMoveCount()
    local _invEnt, _slot, item = getFocused()
    local stackSize = (item.stackSize or 1)
    if halfStack then
        -- ceil, because when stackSize is 1, we dont want it to drop to 0!
        return math.ceil(stackSize/2)
    else
        return stackSize
    end
end




function slotService.interact(slotElem, button)
    local isFocused = getFocused()


    if button == ALPHA_BUTTON then
        print("INTERACT:", isFocused)
        if isFocused then
            local count = getMoveCount()
            tryMoveOrSwap(slotElem, count)
            reset()
        else
            focusElement(slotElem, false)
        end

    elseif button == BETA_BUTTON then
        if isFocused then
            tryMove(slotElem, 1)
        else
            focusElement(slotElem, true)
        end
    end
end



return slotService
