

local h = require("shared.helper")



local slotService = {}





local focusedSlotElem = nil
local halfStack = false


local function resetFocus()
    focusedSlotElem = nil
    halfStack = false
end



local function isFocusValid()
    if not focusedSlotElem then
        return false -- nothing focused!
    end
    local parentEntity = focusedSlotElem:getParentEntity()
    if (uiBasics.isBasicUI(parentEntity)) and (not uiBasics.isOpen(parentEntity)) then
        return false -- nope, parent UI element is closed!
    end
    local item = focusedSlotElem:getItem()
    local inv = focusedSlotElem:getInventory()
    if umg.exists(item) and umg.exists(inv.owner) then
        -- yup; both entities still exist, focus is valid.
        return true
    end
end



local function getFocused()
    -- gets the (inventoryEnt, slot, item) that is being focused
    if not isFocusValid() then
        resetFocus()
        return
    end
    local inv = focusedSlotElem:getInventory()
    local slot = focusedSlotElem:getSlot()
    local item = focusedSlotElem:getItem()
    return inv, slot, item, focusedSlotElem
end




local function focusElement(slotElem, isBeta)
    focusedSlotElem = slotElem
    halfStack = isBeta
end






local function tryMoveOrSwap(slotElem, count)
    local invEnt, slot, item = getFocused()
    local inv = invEnt.inventory
    local targItem = slotElem:getItem()

    count = h.getMoveStackCount(item, count, targItem)

    local targInv, targSlot = slotElem:getInventory(), slotElem:getSlot()
    if (not targItem) or (count > 0) then
        -- move: Items can be combined!
        inv:tryMoveToSlot(targInv, targSlot, count)
    else
        -- swap: When stacks are different, or there's no space
        inv:trySwap(slot, targInv, targSlot)
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



function slotService.interactPrimary(slotElem)
    local isFocused = getFocused()
    if isFocused then
        local count = getMoveCount()
        tryMoveOrSwap(slotElem, count)
        resetFocus()
    else
        focusElement(slotElem, false)
    end
end


function slotService.interactSecondary(slotElem)
    local isFocused = getFocused()
    if isFocused then
        local invEnt, slot = getFocused()
        local inv = invEnt.inventory
        local targInv, targSlot = slotElem:getInventory(), slotElem:getSlot()
        inv:tryMoveToSlot(slot, targInv, targSlot, 1)
    else
        focusElement(slotElem, true)
    end
end




local lg = love.graphics

-- Draw little arrow widget thing
--[[
    TODO: This should *most definitely* be removed / changed up,
    because its kinda stupid.
]]

local ORDER = 2
umg.on("rendering:drawUI", ORDER, function()
    local _,_,_,slotElem = getFocused()
    if slotElem then
        local x,y,w,hh = slotElem:getView()
        local cX,cY = x+w/2, y+hh/2
        lg.setLineWidth(5)
        lg.line(cX,cY, input.getPointerPosition())
    end
end)



return slotService
