
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



local function hasMovableItem(slotEnt)
    return umg.exists(slotEnt.item) and slots.canMoveItem(slotEnt)
end


local function trySwapItems(ent1, ent2)
    if hasMovableItem(ent1) and hasMovableItem(ent2) then
        -- swap em!
    else
        -- One (or both) slots can't move items:
        --[[
            TODO: put some juice here;
                - shake the items...?
                - emit a BUZZ sound to imply failure...?
        ]]
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
            trySwapItems(slotEnt, selectedSlot)
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
