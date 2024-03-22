
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





---

## Global helper simplicity:
We have a big issue on our hands.

If we want to keep global-helpers generic, we must pass the entity in.

Consider the `onDeath` callback.
If we do `call("onDeath", ent)`, there is NO WAY for the entity 
to know the position that it resides in.

IDEA: Create a new object: `pass`.
A `pass` is of the following shape:
```lua
{
    slot = 12,
    plot = plotObj,
    entity = ent
}
```
A `pass` represents a ppos, AND an entity that is being targeted.

### FINAL IDEA:
Remove `ppos` and `ppass`.
Store positions inside of entities instead.   
Yes, this is more fragile. But is 5x more ergonomic and powerful.








# Issue: setting/moving ents
Moving an item-ent is A LOT different from moving a slot.
(Slot: needs to change position within plot)
(Item: needs to change slot.item component)

How should we handle this?
Maybe, we have flag-components for slots and items that allows us to differentiate them at an engine level...?

### SOLN-1:
Don't allow movement of slots.
Just allow for movement of items.
This makes a lot more sense; since slots aren't really supposed to be moved.






# Rendering UI Slots:
We have a *smol* lil issue here:

- Entities are rendered in the world, fine (All handled by ZIndexer)
- Entities can't *really* be rendered well in a UI context
    - (Must do a bunch of fucky scaling/translations before we render)

Is this *too* much of a big deal...?

IDEA:
Revamp rendering entirely.
Don't use `ent.x, ent.y` as positions to images.
Instead, translate the entity FULLY before rendering.

This way, we have *way* more control when we render entities in alternative contexts (like GUI.)
Ask Xander







# Automatic creation of PlotUIs
Hmm.. I have a feeling that creating PlotUIs will be quite tedious.
I wonder if there's a clean way we can make it generic, or if there's a helper we can create.


