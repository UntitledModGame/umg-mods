
-- item is moved to an inventory slot
-- WARNING: This event is called when an item is moved WITHIN an inventory!
-- For example, if we move item from slot 1 to slot 2 in the same inventory,
-- itemAdded is called.
umg.defineEvent("items:itemAdded")

-- item is removed from an inventory slot
-- WARNING: This event is called when an item is moved WITHIN an inventory!
-- For example, if we move item from slot 1 to slot 2 in the same inventory,
-- itemRemoved is called.
umg.defineEvent("items:itemRemoved")
--[[
    TODO: We might want a event for when item is moved
    BETWEEN inventories
]]


-- when stackSzie of an item changes
umg.defineEvent("items:stackSizeChange")




if client then

--  an inventory item is drawn WITHIN the inventory
umg.defineEvent("items:drawInventoryItem")

-- inventory item info is to be drawn (through a Slab UI context)
umg.defineEvent("items:displayItemTooltip")

-- Passes an array, and collects ALL text, to be displayed as a tooltip.
-- Listeners to this event should add text to the array.
umg.defineEvent("items:collectItemTooltips")

-- called when item tooltip is drawn. (Pretty low-level)
umg.defineEvent("items:drawTooltip")

end



-- item dropped on ground
umg.defineEvent("items:dropGroundItem")

-- item picked up from ground
umg.defineEvent("items:pickupGroundItem")

