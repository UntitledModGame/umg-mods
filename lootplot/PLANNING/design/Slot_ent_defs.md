
## ASSUMPTION LESS DEVELOPMENT:
We don’t need to be as assumption-less as we have been.
Remember; Some assumptions can be done really beautifully, if the right stuff is assumed, and other stuff is left decoupled.

Some stuff we need to think through:

```
pricing (sell/buy)
  - have sellPrice/buyPrice as properties...?

What really constitutes a shop slot??
I don't like how the buyPrice component determines whether an item can be purchased.

For buying, I guess the onus should lie on the slot, not the item...?
```


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

