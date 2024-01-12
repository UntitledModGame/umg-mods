

# SYNC MOD:

```lua

sync.proxyEventToClient("modname:hello") 
-- automatically routes umg.call("modname:hello", ...) on server to a 
-- umg.call("modname:hello", ...) on clientside.


-- automatically syncs component `x` in a server-authoritative fashion
sync.autoSyncComponent("x", {
    -- this options table is OPTIONAL.  The values are the defaults:
    syncWhenNil = false
    lerp = false, -- only works for numbers
    numberSyncThreshold = 0.05, -- difference between numbers to sync
    noDeltaCompression = false, -- turns off delta-compression
})



-- Automatically syncs component `lookX` bidirectionally from
-- client --> server when the ent is being controlled by the client,
-- and from server --> client when the ent is NOT being controlled.
sync.autoSyncControllableComponent("lookX", {
    syncWhenNil = false,
    lerp = false, -- only works for numbers
    numberSyncThreshold = 0.05, -- difference between numbers to sync
    noDeltaCompression = false, -- turns off delta-compression
})





-- Can also create custom filters here.
sync.defineFilter("controlEntity", function(sender, x)
    return umg.exists(x) and x.controller == sender
end)

sync.defineFilter("inventoryEntity", function(sender, x)
    return umg.exists(x) and x.inventory
end)


```

