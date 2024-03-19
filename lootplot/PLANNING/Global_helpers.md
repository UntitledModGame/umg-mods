
# Global helpers:

```lua



--[[
    Actions:
]]
activate(ent) -- activates an entity.
    -- NOTE: Activating a slot will also activate the item that it holds!
destroy(ent)
sell(ent)
rotate(ent, angle=math.pi/2) -- rotates by an angle.
clonedEnt = clone(ent)
local item = trySpawnItem(ppos, itemEType) -- tries to spawn an item at ppos





--[[
    Item API:
]]
detachItem(item) -- removes an entity from a plot. position info is nilled.
attachItem(slotEnt, item) -- moves an item to slot. Will overwrite
    -- ^^^ These 2 should be dual-functions!
moveItem(item, slotEnt) -- moves an item to slot. Will overwrite
swapItem(item1, item2) -- swaps positions of 2 item entities




--[[
    Slot API:
]]
setSlot(ppos, slotEnt)




--[[
    Positioning:
]]
posToSlot(ppos)
posToItem(ppos)
getPos(item_or_slot)



--[[
    DIRECTIONS:
]]
ppos = above(ppos) -- gets the ppos ABOVE this ppos
_,_,_ = below(ppos), left(ppos), right(ppos)

-- example usage:
item = getItem(above(ppos))
slot = getSlot(above(ppos))





--[[
    SHAPE:
]]

-- looping over ents:
local ents = touching(ent) -- gets all ents that we are touching:

touching(ent):loop(function(ppos)
    -- loops over all neighbour positions, `ppos`
end)

-- We can also use filter API, w/ chaining:
touching(...)
    :filter(func)
    :items() -- ppos --> item
    :loop(function(itemEnt)
        -- loops over all neighbour item ents. 
        -- Note: item
    end)

arr = arr:filterTraitMatch(ent.traits) -- filters on matching trait(s)
val = arr:random() -- randomly picks a value





-- STRETCH / NYI:
burn(ppos)




```


