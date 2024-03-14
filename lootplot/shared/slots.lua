

local slots = {}


function slots.canAdd(slotEnt, itemEnt)
    --[[
        can we add `itemEnt` to `slotEnt`...?
    ]]
    if slotEnt.slot.entity then
        return false -- Slot already taken
    end
end



local function add(slotEnt, itemEnt)
    -- adds `itemEnt` to `slotEnt`
    slotEnt.slot.entity = itemEnt
    umg.call("lootplot:itemAddedToSlot", itemEnt, slotEnt)
    error("todo: sync this")
end


function slots.tryAdd(slotEnt, itemEnt)
    if slots.canAdd(slotEnt, itemEnt) then
        add(slotEnt, itemEnt)
        return true
    end
end



function slots.canRemove(slotEnt, itemEnt)

end


local function remove(slotEnt)
    local item = slotEnt.slot.entity
    if umg.exists(item) then
        umg.call("lootplot:itemRemovedFromSlot", item)
        slotEnt.slot.entity = nil
        error("todo: sync this")
    end
end


function slots.tryRemove(slotEnt)
    -- Tries to remove an item from a slot
    local item = slotEnt.slot.entity
end


return slots

