
-- item is moved to an inventory slot
-- WARNING: This event is called when an item is moved WITHIN an inventory!
-- For example, if we move item from slot 1 to slot 2 in the same inventory,
-- itemMoved is called.
umg.defineEvent("items:itemMoved")

-- item is removed from an inventory slot
-- WARNING: This event is called when an item is moved WITHIN an inventory!
-- For example, if we move item from slot 1 to slot 2 in the same inventory,
-- itemRemoved is called.
umg.defineEvent("items:itemRemoved")
--[[
    TODO: We might want a event for when item is moved
    BETWEEN inventories
]]





if client then

--  an inventory item is drawn WITHIN the inventory
umg.defineEvent("items:drawInventoryItem")

-- inventory item info is to be drawn (through a Slab UI context)
umg.defineEvent("items:displayItemTooltip")

end



-- item dropped on ground
umg.defineEvent("items:dropGroundItem")

-- item picked up from ground
umg.defineEvent("items:pickupGroundItem")

