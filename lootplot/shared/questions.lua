

local questions = {}


function questions.canRemoveItem(slotEnt)
    -- whether or not we can REMOVE 
    -- an item from slotEnt
    if not umg.exists(slotEnt.item) then
        return false -- no item to remove!
    end
    return umg.ask("lootplot:isItemRemovalBlocked", slotEnt, slotEnt.item)
end


function questions.couldHoldItem(targSlotEnt, itemEnt)
    --[[
        This functions checks whether or not we COULD hold the item,
        assuming that the slot is empty.

        The reason we need this check, is to check when swapping.
    ]]
    return umg.ask("lootplot:isItemAdditionBlocked", targSlotEnt, itemEnt)
end


function questions.canAddItem(slotEnt, itemEnt)
    -- whether or not we can ADD 
    --  an item to slotEnt
    if umg.exists(slotEnt.item) then
        return false
    end
    return questions.couldHoldItem(slotEnt, itemEnt)
end




return questions

