
# LOOTPLOT NOTEPAD


We have a bit of a problem.

We want items to be able to know their own position in space.
But... items don't actually KNOW their own position!!!

Likewise, `Slot`s shouldn't *really* know their own position either.



## IDEA:
`Slot` entities don't contain a position/ref to plot.
They just contain a `plottable` component.

Keep entity position within the plot as a SSOT.




## ISSUE 2:
We want components to be *simple,* and *reusable.*
### SOLN-2:
How abouts, instead of having a weird
```lua
ent.slot = {
    item = itemEnt,
    ...
}
```
We just have a simpler, `ent.item = itemEnt` component.
```lua
ent.item = itemEnt
```
^^^ This way, items can contain other items!!! 
Isn't that really cool/amazing!!!




## How should we modify items within slots?
IDEA-1:
```lua
api.setItem(slotEnt, itemEnt)
```

IDEA-2:
```lua
plot:setItem(ppos, itemEnt)
-- ^^^ no, this is dumb
```


IDEA-3:
How about we just have a nice global helper?
```lua
set(ppos, itemEnt)
```
YES, ^^^ This is definitely the best idea. :)





