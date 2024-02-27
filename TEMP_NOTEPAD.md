



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
- PURGED -- Inventory:_rawset()
- PURGED -- Inventory:set()  

Inventory:count()
Inventory:contains(item)
Inventory:getEmptySlot()

-- Extract ALL of these to `permissionCheck` file.
- PURGED -- Inventory:hasRemoveAuthority(actorEnt, slot)
- PURGED -- Inventory:hasAddAuthority(actorEnt, slot, item)
- PURGED -- Inventory:canBeOpenedBy(actorEnt)

Inventory:canAddToSlot()
Inventory:canRemoveFromSlot()

Inventory:tryAddToSlot(slot, item, count)


Inventory:findAvailableSlot()
Inventory:find()

Inventory:tryMove()
Inventory:tryMoveToSlot()
Inventory:trySwap()


Inventory:add(item, slot_or_nil)
Inventory:remove(slot_or_item)


Inventory:get(slot)

- Inventory:setStackSize(slot, stackSize)

Inventory:getSlotHandle()
Inventory:setSlotHandle()

```

