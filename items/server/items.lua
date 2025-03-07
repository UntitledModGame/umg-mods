

local groundItems= require("server.ground_items")



local function invOk(invEnt)
    if umg.exists(invEnt) and invEnt.inventory then
        return true
    end
end




local function isValidSlot(invEnt, slot)
    if not invOk(invEnt) then
        return false
    end
    return invEnt.inventory:isValidSlot(slot)
end



local function hasAccess(controlEnt, invEnt)
    if not invEnt.inventory then
        return false
    end
    return invEnt.inventory:canBeAccessedBy(controlEnt)
end




local function hasSwapPermission(controlEnt, inv, slot, itemToBeSwapped)
    local addOk = inv:itemCanBeAddedBy(controlEnt, slot, itemToBeSwapped)
    if addOk then
        local removeOk = inv:itemCanBeRemovedBy(controlEnt, slot)
        return removeOk
    end
end



server.on("items:trySwapItems", function(sender, controlEnt, invEnt, slot1, invEnt2, slot2)
    if not sync.isControlledBy(controlEnt, sender) then
        return
    end
    if not (hasAccess(controlEnt, invEnt) and hasAccess(controlEnt, invEnt2)) then
        return
    end
    if (not isValidSlot(invEnt, slot1)) or (not isValidSlot(invEnt2, slot2)) then
        return
    end
    
    local inv1 = invEnt.inventory
    local inv2 = invEnt2.inventory
    local item1 = inv1:get(slot1)
    local item2 = inv2:get(slot2)
    
    if not hasSwapPermission(controlEnt, inv1, slot1, item2) then
        return
    end
    if not hasSwapPermission(controlEnt, inv2, slot2, item1) then
        return
    end
    
    inv1:trySwap(slot1, inv2, slot2)
end)



server.on("items:tryMoveItem", function(sender, controlEnt, invEnt1, slot1, invEnt2, slot2, count)
    if not sync.isControlledBy(controlEnt, sender) then
        return
    end
    if not (hasAccess(controlEnt, invEnt1) and hasAccess(controlEnt, invEnt2)) then
        return
    end
    if (not isValidSlot(invEnt1, slot1)) or (not isValidSlot(invEnt2, slot2)) then
        return
    end

    count = count or 1
    local inv1 = invEnt1.inventory
    local inv2 = invEnt2.inventory
    if (inv1==inv2) and (slot1==slot2) then
        return -- moving an item to it's own position...? nope!
    end

    local item = inv1:get(slot1)
    -- moving `item` from `inv1` to `inv2`
    if not inv2:itemCanBeAddedBy(controlEnt,slot2,item) then
        return
    end
    if not inv1:itemCanBeRemovedBy(controlEnt,slot1) then
        return
    end

    inv1:tryMoveToSlot(slot1, inv2, slot2, count)
end)




server.on("items:tryDropItem", function(sender, controlEnt, invEnt, slot)
    local inv = invEnt.inventory
    if not sync.isControlledBy(controlEnt, sender) then
        return
    end
    if not isValidSlot(invEnt, slot) then
        return
    end
    if not (hasAccess(controlEnt, invEnt)) then
        return
    end
    local item = inv:get(slot)
    if not item then
        return -- exit early
    end
    if not inv:itemCanBeRemovedBy(controlEnt,slot) then
        return
    end

    if invEnt.x and invEnt.y then
        local dvector = invEnt -- dimensionVector is just the entity
        if inv:tryRemove(slot) then
            -- if removal succeeds: drop item
            groundItems.drop(item, dvector)
        end
    end
end)


