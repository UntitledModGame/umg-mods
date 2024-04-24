
--[[

SELECTION SERVICE:

This file handles selecting of slots,
and interacting with said slots.

]]


local selection = {}



local selectedSlot


local function reset()
    selectedSlot = nil
end

local function validate()
    if selectedSlot and (not umg.exists(selectedSlot)) then
        reset()
    end
end


local function isInteractable(slotEnt)
    return false -- just for now.
end




local function canMoveFromTo(srcSlot, targetSlot)
    local item = srcSlot.item
    if not umg.exists(srcSlot.item) then
        return false
    end
    if lp.questions.couldHoldItem(targetSlot, item) and lp.questions.canRemoveItem(srcSlot) then
        return true
    end
end


local function hasItem(slotEnt)
    return umg.exists(slotEnt.item)
end


local function canSwap(slot1, slot2)
    return canMoveFromTo(slot1, slot2) and canMoveFromTo(slot2, slot1)
end

local function deny(slotEnt)
    --[[
        TODO: put some juice here;
            - shake the slot...?
            - emit a BUZZ sound to imply failure...?
    ]]
    umg.melt("todo: make deny juice")
end


local function tryMove(slot1, slot2)
    if hasItem(slot2) then
        -- then we try to swap items
        if canSwap(slot1, slot2) then
            umg.melt("TODO: Swap slot1 <--> slot2")
        else
            deny(slot1)
            deny(slot2)
        end
    else
        -- Else, try move slot1 item --> slot2
        if canMoveFromTo(slot1, slot2) then
            assert(not hasItem(slot2),"???") -- just to be safe lol
            umg.melt("TODO: Move slot1 --> slot2")
        end
    end
end


local function click(slotEnt)
    if isInteractable(slotEnt) then
        -- interact!
        -- (ie; reroll button or something)
    else
        -- else, select:
        selectedSlot = slotEnt
    end
end


function selection.click(slotEnt)
    validate()
    if selectedSlot then
        if slotEnt ~= selectedSlot then
            tryMove(slotEnt, selectedSlot)
        end
    else
        click(slotEnt)
    end
end


function selection.getSelected()
    validate()
    return selectedSlot
end



return selection
