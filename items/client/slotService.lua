

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
    local inv = focusedSlotElem:getInventory()
    local slot = focusedSlotElem:getSlot()
    if umg.exists(item) and umg.exists(inv.owner) then
        return inv, slot, item, focusedSlotElem
    end
end




local function focusElement(slotElem, isBeta)
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
    local controlEnts = control.getControlledEntities(clientId)
    for _, ent in ipairs(controlEnts) do
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
        return inv2:canBeAccessedBy(controlEnt)
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
    local inv, slot, _ = getFocused()
    local controlEnt = getMoveAccessCandidates(inv,slot, targInv,targSlot)[1]
    if controlEnt then
        client.send("items:tryMoveItem",
            controlEnt, 
            inv.owner, slot, 
            targInv.owner, targSlot, 
            count
        )
    end
end


local function trySwap(inv1, slot1)
    local inv2, slot2, _item = getFocused()
    local controlEnt = getSwapAccessCandidates(inv1, slot1, inv2, slot2)[1]
    if controlEnt then
        client.send("items:trySwapItems", 
            controlEnt, 
            inv1.owner, slot1, 
            inv2.owner, slot2
        )
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
        if isFocused then
            local count = getMoveCount()
            tryMoveOrSwap(slotElem, count)
            reset()
        else
            focusElement(slotElem, false)
        end

    elseif button == BETA_BUTTON then
        if isFocused then
            local targInv, targSlot = slotElem:getInventory(), slotElem:getSlot()
            tryMove(targInv, targSlot, 1)
        else
            focusElement(slotElem, true)
        end
    end
end





local lg = love.graphics

-- Draw little arrow widget thing

local ORDER = 2
umg.on("rendering:drawUI", ORDER, function()
    local _,_,_,slotElem = getFocused()
    if slotElem then
        local x,y,w,hh = slotElem:getView()
        local cX,cY = x+w/2, y+hh/2
        lg.setLineWidth(5)
        lg.line(cX,cY, love.mouse.getPosition())
    end
end)



return slotService
