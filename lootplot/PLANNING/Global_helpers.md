
# Global helpers:

```lua
itemEnt = get(ppos)

activate(ppos)

kill(ppos) -- kills item
killSlot(ppos) -- kills slot!

burn(ppos)
sell(ppos) -- sells item at plotPos

trySpawn(ppos, itemEType)


-- directly sets/gets an item
set(ppos, itemEnt)
get(ppos)


copy(srcPos, targPos) -- copies an item
copySlot(srcPos, targPos) -- copies a slot!

-- looping over ents:
local ents = touching(...) -- gets all ents that we are touching:
touching(...):loop(function(e)
    -- loops over all neighbour ents, `e`
end)

--[[
    TODO:
    Wtf do we pass into `touching(...)`?
    We could pass `ppos`
    We could also pass 
]]

-- We can also use filter API, w/ chaining:
touching(...)
:filter(func)
:filterTraitMatch(ent.traits) -- filters on matching trait(s)
-- (^^^ definitely hardcode common methods like this)
:loop(function(e)
    -- loops over all 
end)


```

