

# TECH_DEBT!
List of tech-debt in spatial mod:



## DimensionStructure:
entityMoved idiom:
```lua
umg.on("spatial:entityMoved", function(ent, oldDim, newDim)
    if systemHas(ent) then
        dimensionStructure:entityMoved(ent)
    end
end)
```
^^^ this is a STUPID idiom.   
This is NOT how events should be used.   
umg events should NOT be used for fragile/critical systems.

The main reason it's bad, is because `ent` is not even guaranteed
to be owned by the `dimensionStructure` !!!!
It's fragile, and bad.
### SOLN:
Use `:entityUpdate` instead of `:entityMoved`. 
The dimensionStructure should manage it internally, from there.

## DONE.






## Default dimension overseer:
dimensionOverseer is *great* being an entity.

But... it's kinda weird having a `dimensionOverseer` entity type within the spatial mod.   
It would be great if we had a default `empty` entity-type deployed by UMG.

IDEA: `server.emptyEntity()`?
^^^ Either this, or deploy `objects.emptyEntity` in the objects mod.




