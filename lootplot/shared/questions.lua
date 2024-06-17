

local questions = {}

--[[
    TODO:
    Should we be exporting these functions..?
    Idk...  do some thinking.
    It feels a bit "weird".

    For now, embrace yagni.
]]

function questions.canRemoveItem(ppos)
    -- whether or not we can REMOVE an item at ppos
    local itemEnt = lp.posToItem(ppos)
    local slotEnt = lp.posToSlot(ppos)
    if not (itemEnt and slotEnt) then
        return false -- no item to remove!
    end
    return not umg.ask("lootplot:isItemRemovalBlocked", slotEnt, itemEnt)
end

function questions.couldHoldItem(slotEnt, itemEnt)
    --[[
        checks whether or not a slot COULD hold the item,

        We need this check for swapping items.
        (If we use `canAddItem` when swapping items, then we will always
            get false, because theres another item in the slot.)
    ]]
    return not umg.ask("lootplot:isItemAdditionBlocked", slotEnt, itemEnt)
end

function questions.canAddItem(slotEnt, itemEnt)
    -- whether or not we can ADD an item to slotEnt.
    if lp.slotToItem(slotEnt) then
        return false
    end
    return questions.couldHoldItem(slotEnt, itemEnt)
end


return questions