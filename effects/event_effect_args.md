

# For eventEffects, what args should be passed, and where?

First off: We definitely should pass ALL event args into the `eventEffect`.
This just gives us more flexibility.

These args should be passed through `effects.callEvent`:
```lua
umg.on("mod:event", function(ent, arg1, arg2)
    local ownerEnt = ent
    effects.callEvent(ownerEnt, "mod:event", ent, arg1, arg2)
end)
```
