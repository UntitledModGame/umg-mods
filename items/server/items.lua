


local inventoryGroup = umg.group("inventory")
-- group of all ents that have an `inventory` component.

local Inventory = require("shared.Inventory")

local groundItems= require("server.ground_items")





inventoryGroup:onAdded(function(ent)
    if not ent:isRegular("inventory") then
        error(".inventory component must be regular. Not the case for: " ..tostring(ent))
    end
    if (getmetatable(ent.inventory) ~= Inventory) then
        error("inventory was assigned incorrectly for ent: " .. tostring(ent))
    end

    ent.inventory.owner = ent
end)



inventoryGroup:onRemoved(function(ent)
    -- delete items
    local inv = ent.inventory
    for slot=1, inv.size do
        local item = inv:get(slot)
        if umg.exists(item) then
            item:delete()
        end
    end
end)



local function isValidSlot(invEnt, slot)
    if math.floor(slot) ~= slot then
        return false
    end
    return (slot >= 1) and (slot <= invEnt.size)
end




local function hasAccess(controlEnt, invEnt)
    --[[
        `controlEnt` is the entity executing the transfer upon invEnt.
        invEnt is the entity holding the inventory
    ]]
    if not umg.exists(invEnt) then
        return false
    end
    if not invEnt.inventory then
        return false
    end

    return invEnt.inventory:canBeOpenedBy(controlEnt)
end



server.on("items:trySwapInventoryItem", function(sender, controlEnt, ent, other_ent, slot, slot2)
    if not sync.isControlledBy(controlEnt, sender) then
        return
    end
    if not (hasAccess(controlEnt, ent) and hasAccess(controlEnt, other_ent)) then
        return
    end

    if (not isValidSlot(slot)) or (not isValidSlot(slot2)) then
        return
    end
    
    local item1 = inv1:get(slot)
    local item2 = inv2:get(slot2)
    
    if not (perms.canActorAddItem(controlEnt,item2,slot) and inv1:hasRemoveAuthority(controlEnt,slot)) then
        return
    end
    if not (perms.canActorAddItem(controlEnt,item1,slot2) and inv2:hasRemoveAuthority(controlEnt,slot2)) then
        return
    end
    
    inv1:trySwap(slot, inv2, slot2)
end)



server.on("items:tryMoveInventoryItem", function(sender, controlEnt, ent, other_ent, slot1, slot2, count)
    if not sync.isControlledBy(controlEnt, sender) then
        return
    end
    if not (hasAccess(controlEnt, ent) and hasAccess(controlEnt, other_ent)) then
        return
    end

    count = count or 1

    local inv1 = ent.inventory
    local inv2 = other_ent.inventory
    if (not inv1) or (not inv2) then
        return
    end

    if (not isValidSlot(slot1)) or (not isValidSlot(slot2)) then
        return
    end

    if (inv1==inv2) and (slot1==slot2) then
        return -- moving an item to it's own position...? nope!
    end

    local item = inv1:get(slot1)
    -- moving `item` from `inv1` to `inv2`
    if not perms.canActorAddItem(controlEnt,item,slot2) then
        return
    end
    if not inv1:hasRemoveAuthority(controlEnt, slot1) then
        return
    end

    inv1:tryMoveToSlot(slot1, inv2, slot2, count)
end)




server.on("items:tryDropInventoryItem", function(sender, controlEnt, ent, slot)
    local inv = ent.inventory
    
    if not sync.isControlledBy(controlEnt, sender) then
        return
    end
    if not (hasAccess(controlEnt, ent)) then
        return
    end

    local item = inv:get(slot)
    if not item then
        return -- exit early
    end

    if not inv:hasRemoveAuthority(controlEnt,slot) then
        return
    end

    if ent.x and ent.y then
        local dvector = ent -- dimensionVector is just the entity
        inv:remove(slot)
        groundItems.drop(item, dvector)
    end
end)


