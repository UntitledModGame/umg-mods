
local gridService = {}
--[[

For GridInventories,
provides easy facilities for converting between slots <---> coords.

Make sure to pass in width,height.


HOLD ON:::
WHY IS THIS IN SHARED/??
The reason this is in `shared/` as opposed to local to `GridInventory`,
is because the server doesn't know about GridInventory.
Thus, it's good to have a single source of truth, so we can do stuff like:
```
effect:
    change all adjacent items in the inventory to blue
```

]]


function gridService.coordsToSlot(x, y, numRows)
    -- converts (x,y) coordinates --> slot index
    -- BIG WARNING!!! (slot) coords are ONE-INDEXED!!
    return y*numRows + x + 1 -- plus-1 for 1-based indexing.
end


function gridService.slotToCoords(slot, numRows)
    -- converts slot index  --->  (x,y) coordinates.
    -- BIG WARNING!!! (x,y) coords are ZERO-INDEXED!!
    slot = slot - 1
    local x = slot % numRows
    local y = math.floor(slot / numRows)
    return x, y
end



for slot=1, 100 do
    local x,y = gridService.slotToCoords(slot, 5,10)
    assert(slot == gridService.coordsToSlot(x,y, 5,10),"?")
end


return gridService

