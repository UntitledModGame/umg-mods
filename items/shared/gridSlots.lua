
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


function gridService.coordsToSlot(x, y, _width, height)
    -- converts (x,y) coordinates --> slot index
    -- BIG WARNING!!! (x,y) coords are ZERO-INDEXED!!
    return y * height + x + 1
end


function gridService.slotToCoords(slot, _width, height)
    -- converts slot index  --->  (x,y) coordinates.
    -- BIG WARNING!!! (x,y) coords are ZERO-INDEXED!!
    slot = slot - 1
    local x = slot % height
    local y = math.floor(slot / height)
    return x, y
end

--[[
    oops, we dont actually use `width` here... 
    but im gonna keep the argument coz its more clear.
]]


return gridService

