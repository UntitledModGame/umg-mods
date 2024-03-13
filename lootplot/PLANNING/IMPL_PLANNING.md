

# Implementation planning:
Ok: 
How do we represent everything?


We almost *definitely* want some form of stack-based state-machine;
Just because it's so beautiful.
But... umg-mods don't *really* support stack-based state-machines.
So instead, we should use a stack of LUI elements.
(ie, a stack of UI entities)
We should then create a very nice API to push/pop these entities;
essentially allowing us to "transfer" state, without even needing a state-machine.   
IDEA:
```lua
-- use these for transferring in/out of "states".
pushUI(uiEnt)
popUI(uiEnt)
```
OR... maybe it should be done differently...
This still isn't a very "clean" way to do states.
Perhaps we should just make a state-machine object, that constructs `uiEnt`,
and deletes uiEnt when we call `state:pop()`...?


## REMEMBER TO MAKE HELPERS!!!
Global helper functions are going to be completely PIVOTAL.
Make sure you plan, and constantly re-evaluate helpers.
Simple stuff like:
```lua
activate(ent)
kill(ent)
burn(ent)
sell(ent)

trySpawn(slot, itemEType)


-- use these for transferring in/out of "states".
pushUI(uiEnt)
popUI(uiEnt)


-- looping over ents:
local ents = touching(ent) -- gets all ents that we are touching:
touching(ent):loop(function(e)
    -- loops over all neighbour ents, `e`
end)

-- We can also use filter API, w/ chaining:
touching(ent)
:filter(func)
:filterTraitMatch(ent.traits) -- filters on matching trait(s)
-- (^^^ definitely hardcode common methods like this)
:loop(function(e)
    -- loops over all 
end)


```


---

We also should CLEARLY map out all interactions, BEFORE coding them.
This would allow us to reason about syncing a lot better.



## SUPER IMPORTANT:
When moving items between `Inventories`, the `Slot`s must be updated too.  
This is kinda bad.... because there's 2 sources of truth here.  
Not much we can do about it.

Maybe add a `clean` mechanism or something, to ensure we don't get wanky shit happening...?  

QUESTION: Who should be in control? The `Inventory`, or the `Plot`?  
A: The `Plot` should definitely be in control.
After all; effects are going to be occuring through the Plot;
NOT the inventory.
(The inventory should still update the plot when items are moved.)



