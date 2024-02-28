



```lua

Inventory:init()
- PURGED -- Inventory:setup()

-- Should be inlined within `server.items` file
- PURGED -- Inventory:slotExists()

-- callbacks:
Inventory:onItemMoved()
Inventory:onItemRemoved()
Inventory:onItemStackSizeChange()

-- Remove this shit
- LOCALLED -- Inventory:_rawset()
- LOCALLED -- Inventory:set()  

Inventory:count()
Inventory:contains(item)
Inventory:getEmptySlot()

-- Extract ALL of these to `permissionCheck` file.
- PURGED -- Inventory:hasRemoveAuthority(actorEnt, slot)
- PURGED -- Inventory:hasAddAuthority(actorEnt, slot, item)
- PURGED -- Inventory:canBeOpenedBy(actorEnt)

Inventory:canAddToSlot()
Inventory:canRemoveFromSlot()

-- Change to `tryAdd`, with `slot` as optional argument
- Inventory:tryAddItem(item, count, slot)
ADD - Inventory:tryRemoveItem(slot, count)


Inventory:findAvailableSlot()
Inventory:find()

Inventory:tryMove()
Inventory:tryMoveToSlot()
Inventory:trySwap()


-- Make these local:
- LOCALLED -- Inventory:add(item, slot_or_nil)
- LOCALLED -- Inventory:remove(slot_or_item)


Inventory:get(slot)

- PURGED -- Inventory:setStackSize(slot, stackSize)

Inventory:getSlotHandle()
Inventory:setSlotHandle(sh)

```

