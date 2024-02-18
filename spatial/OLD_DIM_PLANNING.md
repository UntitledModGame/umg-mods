

# Old planning for the dimensions mod:
This had a few useful tid-bits / idioms, so im gonna keep some stuff.




# Persistence:
How are dimensions persisted to disk?

IDEA: `overseeingDimension` component.
This component signifies that this entity owns/controls this dimension.

That way, when we mutate dimensions, we can simply change the 
components within the controller entity.

This is a great idea, because dimension properties will be automatically
propagated to clients when they join the server.
None of that needs to be done manually.


If this entity is deleted, then the dimension is also deleted.
(e.g. if portal to a dimension is deleted, the dimension is also deleted)


Question:
what happens if we want 2 entities as dimensionOverseers?
i.e. two portals pointing to the same dimension...?
A: ^^^ this shouldn't be possible. It would overcomplicate things.

-------

With this setup, we could write code like so:
```lua
function lighting.setBaseLighting(dimension, color)
    strTc(dimension)
    local ent = spatial.getDimensionOverseer(dimension)
    if ent then
        ent.dimensionLighting = color
        sync.syncComponent(ent, "dimensionLighting")
    end
end
```



## How other mods should do stuff
```lua
weather.rain.setOptions(dimension, {...})
weather.fog.setOptions(dimension, {...})

rendering.setGroundTextures(dimension,  {"tex1", ...})

light.setBaseLighting(dimension,  {1,1,1})
light.setDayNightCycle(dimension, {
    ...
})

```

