
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




## SLOTS:
Do we need these functions...?
Hmm... maybe we should keep some of them..?

But I also think that some of them should be global helpers instead
```lua
function slots.canAdd()
function slots.tryAdd()
function slots.canRemove()
```

OK.
lets think: How would we implement a slot that can only take {trait} items?

Definitely should be emitting a question.
I guess the question is:
WHERE should we emit said question from?
This is what this file would be great for.

Do we want to allow blocking of removal..?
I feel like thats a bit weird... idk

Are there any valid use-cases for blocking item-removal?
(Not really, I feel like!)
But it'd add symmetry.



