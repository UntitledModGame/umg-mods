


# Final idea:

Have `effectEffects` tag onto events directly, ie:
```lua
ent.eventEffect = {
    event = "mortality:onDeath",
    trigger = function(ent)
        print("yo! death effect!")
    end
}
```
The issue is that the first-argument MUST be the effect-entity.

All in all, this is just the cleanest way to do things.
We have a bunch of event-infrastructure set up already; no point in
re-inventing the wheel.

---------

Q: "But what if our event doesn't pass the entity as first arg??"

A: Simply create a new event that DOES pass it as first-arg.
For example, enemy-deaths:
```lua

umg.on("mortality:onDeath", function(ent)
    if ent.type == "enemy" then
        -- Alert nearby entities that you died!
        local dvec = ent
        for e in partition:iter(dvec) do
            if e~=ent and isInRange(e, ent) then
                umg.call("game:nearbyEnemyDeath", e, ent)
            end
        end
    end
end)
```
```lua

ent.eventEffect = {
    event = "game:nearbyEnemyDeath",
    trigger = function(ent, enemyDeath)
        print("A nearby enemy has died!")
    end
}
```
^^^ Solved! :D














## --------------------
## OLD PLANNING: UNUSED!
## --------------------

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


