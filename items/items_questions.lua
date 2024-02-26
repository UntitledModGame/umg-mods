
local OR = reducers.OR


-- whether an inventory can be opened
umg.defineQuestion("items:canOpenInventory", OR)


-- whether an inv is locked
umg.defineQuestion("items:isInventoryLocked", OR)


-- whether an item is blocked from being removed from an inventory
umg.defineQuestion("items:isItemRemovalBlocked", OR)
-- whether an item is blocked from being added to an inventory
umg.defineQuestion("items:isItemAdditionBlocked", OR)


-- whether an item is blocked from being removed from an inventory
umg.defineQuestion("items:isItemRemovalBlockedForActorEntity", OR)
-- whether an item is blocked from being added to an inventory.
umg.defineQuestion("items:isItemAdditionBlockedForActorEntity", OR)
-- These two questions are only asked if a controllable entity is trying to move an item.
-- (i.e. if a player moves an item.)
-- For both questions, the controllable entity is passed in.
-- This allows us to do stuff like,
-- "only red team can add stuff to this chest."



