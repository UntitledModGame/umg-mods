
# Global helpers:

```lua
itemEnt = get(ppos)

activate(ppos_or_ent) -- activates an ITEM at a ppos.
-- can also pass in an ent for more fine-grained control.

destroy(ppos) -- kills item at ppos
destroySlot(ppos) -- kills slot at ppos!

sell(ppos) -- sells item at plotPos
rotate(ppos, angle=math.pi/2) -- rotates item by an angle.

trySpawn(ppos, itemEType)


-- directly sets/gets an item
set(ppos, itemEnt)
get(ppos)


copy(srcPos, targPos) -- copies an item


-- STRETCH / NYI:
burn(ppos)



-- looping over ents:
local ents = touching(...) -- gets all ents that we are touching:
touching(...):loop(function(ppos)
    -- loops over all neighbour positions, `ppos`
end)

--[[
    TODO:
    Wtf do we pass into `touching(...)`?
    We could pass original posititon- `ppos`
]]

-- We can also use filter API, w/ chaining:
touching(...)
:filter(func)
:filterTraitMatch(ent.traits) -- filters on matching trait(s)
-- (^^^ definitely hardcode common methods like this)
:loop(function(ppos)
    -- loops over all 
end)


```

