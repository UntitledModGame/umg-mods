
# REQUIREMENTS:

Stuff we need for now:
- A way to hold a single item
- Robustness w/ inventory system

Stuff we want in the future:
- Chargable items
- Repeatable items (ak-47)
- One-use items
- Continuous items (i.e. lazer beam)
- Holding multiple items




# PLANNING:


## Q1: How are items actually held?
Ideas:
- Keep it same as before (only 1 item can be held)
    ^^^ THIS IS THE BEST IDEA.
    If modders want to support multi-hold, they can add the 
    position components themselves and handle all that themselves.
- `holditems` component: A `Set<ItemEnt>` of items that are being held
- Set holdItems manually, and an internal system handles it.




## Q3: How do we handle exotic use types?
Items should be able to be continuous AND chargable simultaneously.

**Components:**
```lua
item.itemChargeTime = X -- time taken to charge this item
item.itemRepeatUsage = true -- repeats usage whilst being used (like ak47)
```

Emit the following callbacks:
- `holdables:itemStartCharge` item starts being charged
- `holdables:itemBeingCharged` called every tick whilst charging (pass in time)
- `holdables:itemUse` item starts being used
- `holdables:itemBeingUsed` called every tick whilst using (pass in time)
- `holdables:itemEndUse` item stops being used
- `holdables:itemCancelCharge` Cancelled (not charged for enough time)




## Q4: How do we interact with the mod to say which items are held?
We can only equip items if the entity has an inventory:
```lua
holdables.equipItem(ent, item) -- equips/unequips item
holdables.unequipItem(ent)
```
TODO: Where do we actually store the info for hold items?
idea: `ent.holdItem` component



## Q5:
How do we handle switching between items?
idea:
- use number keys for quick switching
- use mouse scroll for switching like minecraft


## Q6:
What should the API look like for item usage?
We should probably map it as close to the user input as we can get.
Idea: have a `useItem` function that we must call every tick:
We must also pass in the "mode" of the item, a positive integer.
```lua
-- client side:
local function pollControlEnts(mode)
    local used = false
    for _, ent in ipairs(controlInventoryEnts) do
        if sync.isClientControlling(ent) and isHoldingItem(ent) then
            holdables.useItem(holderEnt, mode)
            -- tells the engine that we are using this item this tick.
            used = true
        end
    end
    return used
end

local MOUSE_MODES = {1,2,3}
umg.on("@tick", function(dt)
    for _, mode in ipairs(MOUSE_MODES) do
        if listener:isMouseButtonDown(mode) then
            local used = pollControlEnts(mode)
            if used then listener:lockMouseButton(mode)
        end
    end
end)
```






- FINAL INVENTORY STUFF TO REMOVE:
```
:_setHoldSlot
:hold
:getHoldItem
.holdItem
autoHold

"setInventoryHoldSlot"
```


