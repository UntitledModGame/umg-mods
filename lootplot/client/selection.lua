
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



local function canMoveItem(slotEnt)
    return umg.exists(slotEnt.item) and slots.canMoveItem(slotEnt)
end


local function doubleInteraction(ent1, ent2)
    if canMoveItem(ent1) and canMoveItem(ent2) then
        -- swap em!
    else
        -- One (or both) slots can't move items:

    end
end


local function singleInteraction(slotEnt)
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
            doubleInteraction(slotEnt, selectedSlot)
        end
    else
        singleInteraction(slotEnt)
    end
end


function selection.getSelected()
    validate()
    return selectedSlot
end



return selection
