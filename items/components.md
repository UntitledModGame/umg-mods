


## ITEM ENTITY EXAMPLE:
```lua
{
    ent.stackSize -- the current stack size of the item.
    -- if this reaches 0, the item is deleted.

    -- Item specific components:
    maxStackSize = 32; -- Maximum stack size of this item
    
    image = "banana" -- can be shared.
    hidden = true/false -- must not be shared!

    itemName = "..." -- item name


    --===========================================
    -- OPTIONAL VALUES:
    itemDescription = "..." -- item description

    displayItemTooltip = function(self)
        -- Used when you want to display Item info.
    end
    
    useItem = function(self, holderEnt)
        -- Called when item is used by `holderEnt`
    end

    dropItem = function(self, holderEnt)
        -- Called when item is dropped by `holderEnt`
    end

    collectItem = function(self, holderEnt)
        -- Called when item is picked up by `holderEnt`
    end


    --===========================================
    -- OPTIONAL: USING ITEMS: 
    -- Used for stuff like consumables, weapons, tools, etc.

    canUseItem = function(self, holderEnt, ...)
        -- returns true/false, depending on whether the 
        -- item can be used or not.
        -- `...` is some arbitrary arguments, passed by 
        --    item:use(...)
        -- CALLED ON BOTH SERVERSIDE __AND__ CLIENTSIDE!
    end

    useItem = function(self, holderEnt, ...)
        -- Called when `holderEnt` attempts to use this item.

        -- The return value for this function is how many items should be deleted
        -- after use. (default is 0.)
        -- `...` is some arbitrary arguments, passed by 
        --    item:use(...)
        -- CALLED ON BOTH SERVERSIDE __AND__ CLIENTSIDE!
    end

    useItemDeny = function(self, holderEnt, ...)
        -- Called when an item is tried to be used, but is denied.
        -- (This will only called on the client that did 
        --   item:use(...) unsuccessfully.)
    end


    itemCooldown = 1 -- this item has a 1 second cooldown


    -- How this item should be held.
    -- (If this value is nil, the item cannot be held)
    itemHoldType = 
        "tool"  -- holds in direction of mouse
        "spin"  -- holds in direction of mouse, spinning when used
        "swing" -- holds in direction of mouse, swings when used (think sword)
        "recoil"-- holds in direction of mouse, recoils back when used (think shotgun)
        "above" -- item is above head of entity
        "custom" -- custom positioning, defined by ent.itemHoldUpdate

    itemHoldRotation = math.pi -- change the hold item's rotation


    -- ONLY USE THIS IF YOU KNOW WHAT YOU ARE DOING!
    itemHoldUpdate = function(item_ent, holder_ent)
        item_ent.x = holder_ent.x
        item_ent.y = holder_ent.y -- see item_holding.lua for examples
    end

    itemHoldDistance = 30 -- holds 30 pixels away (default is 10)
}
```




# INVENTORY COMPONENTS:
```lua

return {
    -- right click to open this chest
    openable = {
        distance = 100; -- default distance that player can open the chest from
        public = true/false, -- whether this inv is publically accessible
        openSound = "chestOpen"; -- default open/close sounds.
        closeSound = "chestClose",
    }

    image = "chest_image",

    inventoryName = "My Inventory" -- We can name inventories like this

    initXY = true

    init = function(ent)
        -- Upon creation, the `inventory` component should be set to a table,
        -- like the following:
        chest.inventory = Inventory({
            name = "my inventory", -- OR, name inventories like this
            width = 6 -- width of inventory slots
            height = 3 -- height

            -- OPTIONAL VALUES:
            hotbar = true -- DST / minecraft like hotbar.
                -- (only works for controllable entities)
        })
    end
}
```

