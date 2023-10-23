

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

However, if an `eventEffect` is applying a `usable` item,
then obviously, we are unable to pass the arguments.

This is OK.
We just need to ensure that the `usable` API can take a 3rd argument:
`applierEnt` which is the entity that the usable-entity is being applied to.

```lua
usables.use(usableEnt, ownerEnt, applyEnt)
--[[
    usableEnt: the ent with the .usable component
    ownerEnt: the entity that owns usableEnt
    applyEnt: the entity that the usable entity is applying to.
]]
```






