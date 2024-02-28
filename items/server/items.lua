


local inventoryGroup = umg.group("inventory")
-- group of all ents that have an `inventory` component.

local Inventory = require("shared.Inventory")

local groundItems= require("server.ground_items")


local perms = require("shared.actorPerms")



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





local function invOk(invEnt)
    if umg.exists(invEnt) and invEnt.inventory then
        return true
    end
end





local function isValidSlot(invEnt, slot)
    if not invOk(invEnt) then
        return false
    end
    if math.floor(slot) ~= slot then
        return false
    end
    return (slot >= 1) and (slot <= invEnt.size)
end


local function hasAccess(controlEnt, invEnt)
    if not invEnt.inventory then
        return false
    end
    return perms.canAccess(invEnt, controlEnt)
end




server.on("items:trySwapInventoryItem", function(sender, controlEnt, invEnt, invEnt2, slot, slot2)
    if not sync.isControlledBy(controlEnt, sender) then
        return
    end
    if not (hasAccess(controlEnt, invEnt) and hasAccess(controlEnt, invEnt2)) then
        return
    end
    if (not isValidSlot(invEnt, slot)) or (not isValidSlot(invEnt2, slot2)) then
        return
    end
    
    local inv1 = invEnt.inventory
    local inv2 = invEnt2.inventory
    local item1 = inv1:get(slot)
    local item2 = inv2:get(slot2)
    
    if not (perms.canActorAddItem(controlEnt,item2,slot) and perms.canActorRemoveItem(controlEnt,slot)) then
        return
    end
    if not (perms.canActorAddItem(controlEnt,item1,slot2) and perms.canActorRemoveItem(controlEnt,slot2)) then
        return
    end
    
    inv1:trySwap(slot, inv2, slot2)
end)



server.on("items:tryMoveInventoryItem", function(sender, controlEnt, invEnt1, invEnt2, slot1, slot2, count)
    if not sync.isControlledBy(controlEnt, sender) then
        return
    end
    if not (hasAccess(controlEnt, invEnt1) and hasAccess(controlEnt, invEnt2)) then
        return
    end
    if (not isValidSlot(slot1)) or (not isValidSlot(slot2)) then
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
    if not perms.canActorAddItem(controlEnt,invEnt2,item,slot2) then
        return
    end
    if not perms.canActorRemoveItem(controlEnt,invEnt1,slot1) then
        return
    end

    inv1:tryMoveToSlot(slot1, inv2, slot2, count)
end)




server.on("items:tryDropInventoryItem", function(sender, controlEnt, invEnt, slot)
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
    if not perms.canActorRemoveItem(controlEnt,invEnt,slot) then
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


