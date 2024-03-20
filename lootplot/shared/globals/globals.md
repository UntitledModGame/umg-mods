

# Global functions

These are global functions used internally within lootplot.

These are NOT exported.


```lua

-- typechecks:
posTc(ppos)
slotTc(slotEnt)
itemTc(itemEnt)




--[[
local func = sync.RPC("mod:explode", {"entity"}, function(ent)
    ...
end)

func(ent)
-- If called on server, 
-- will AUTOMATICALLY be dispatched to client.

-- When called on client, 
-- will just be called normally.
]]
RPC("mystring", {"entity", "number"}, 
function(ent, slot)
    ...
end)



```

