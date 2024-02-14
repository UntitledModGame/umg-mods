


## Item Entity Components:
```lua
stackSize -- the current stack size of the item.
-- if this reaches 0, the item is deleted.

-- Item specific components:
maxStackSize = 32; -- Maximum stack size of this item

image = "banana" -- can be shared.
hidden = true/false -- must not be shared!

itemName = "..." -- item name


--===========================================
-- OPTIONAL VALUES:
itemDescription = "..." -- item description

useItem = function(self, holderEnt)
    -- Called when item is used by `holderEnt`
end

dropItem = function(self, holderEnt)
    -- Called when item is dropped by `holderEnt`
end

collectItem = function(self, holderEnt)
    -- Called when item is picked up by `holderEnt`
end


```



# INVENTORY COMPONENTS:
```lua
ent.inventory = Inventory(...)
```

