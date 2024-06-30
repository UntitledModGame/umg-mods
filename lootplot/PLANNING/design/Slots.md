

# Slot
Slots live in `Plot`s.

A Slot is like a container for an item to exist in.
Can be placed in the world; but also exist within inventories.

Important things to note:
- `Slot`s CANNOT be moved out of a `Plot`.
    - They can only be deleted/augmented.


----







----

# ENT DEFINITION EXAMPLES:

## Reroll/Spawner slot definition:
```lua
defineSlot("rerollSlot", {
	-- Activate: Rerolls an existing item.
	-- (if there is no item in the slot, do nothing)
	itemReroller = generator:newQuery(...)
})

defineSlot("spawnerSlot", {
	-- Activate: Spawns a new item in slot.
	-- (if theres already an item in the slot, do nothing)
	itemSpawner = generator:newQuery(...)
})

-- Note that `itemReroller` and `itemSpawner` can coexist!!
```

### BUT WAIT!!! What we want more customizable rerolls???
Although it's not possible with this component, It's still possible.
we just need to do it directly:
```lua
defineSlot("customRerollSlot", {
	onActivate = function(ent)
		local itemEnt
		if cond() then
			itemEnt = oneQuery()
		else
			itemEnt = twoQuery()
		end
	end
	
})
```

---

## Shop slot definition:
We can combine our work from reroll and spawner slots:
```lua
defineSlot("shopSlot", {
	activation = {NORMAL, REROLL, RESET},

	itemSpawner = generator:newQuery(...)
	itemReroller = generator:newQuery(...)
	
	onActivate = function(ent)
		-- reroll item
		-- lock item-movement, reset buy state (<-- should be single source truth)
	end
})
```


## Slot property effects:
```lua

defineSlot("superSlot", {
	activation = {NORMAL},

    -- Modifies properties the item it holds:
    itemEffects = {
        -- item in this slot get: 
		--		+4 power, x2 buyPrice
        multipliers = { buyPrice = 2 },
        modifiers = { power = 4 }
    }
})
```

