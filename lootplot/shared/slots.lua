

local slots = {}


function slots.canAdd(slotEnt, itemEnt)
    --[[
        can we add `itemEnt` to `slotEnt`...?
    ]]
end



local function add(slotEnt, itemEnt)
    -- adds `itemEnt` to `slotEnt`
    slotEnt.slot.item = itemEnt
end


function slots.tryAdd(slotEnt, itemEnt)

end


return slots

