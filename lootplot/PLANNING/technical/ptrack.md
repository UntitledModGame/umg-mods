

# Position-tracking:
Slots and Items need to be able to tell WHERE they are.<br/>
But... its hard to do this without strong-referencing.  
If we reference the `Plot` object in a component; that implies that the slot/item OWNS the plot!!!  
(which is bad)

To solve this, lootplot uses a module called `ptrack`, that keeps back-references to entities:
```lua
Ptrack {
    [ent] -> ppos
}
```
This exposes a robust internal API for tracking slot/item positions:
```lua
ptrack.set(ent, ppos)
ptrack.get(ent, ppos)
```


