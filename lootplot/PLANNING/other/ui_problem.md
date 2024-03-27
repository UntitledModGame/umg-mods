

# The UI Problem


## ISSUE-1: Inventories
We want to be able to swap items between 
inventory, world, and shop, *really easily.*  
---->
This would be GREAT with inventories.... BUT.. that would mean that we
need to render an inventory *into the world.*   
This is not possible, currently.

## ISSUE-2: Juice-entities
Likewise, another big issue is that with UI elements, we can't *really*
use juice-entities very well.
Since juice-entities are rendered BEHIND the ui.
hmmm.
(This would be "solved" if UI was rendered in the world, however.)






## IDEA:
Abstract the concept of UI away.
Remove the whole `ui.open(), ui.close()` bullshit.

Keep the concept of a default scene.... but make it so elements have to be added manually.

----

###  We also have some bloat-y components in the ui mod:
```c
ent.uiElement//  <--- wtf is this??? 
// The only "thing" this rcomp does is hold a ref to a LUI elem. WTF.

ent.uiRegion // <--- this feels kinda shitty and niche; but its needed.
ent.uiSize // <--- this feels a bit bloaty; but not too bad.

ent.clampedUI // Too bloaty!
ent.draggableUI // Toooo bloaty!!

basicUIEntity // this is quite nice actually, we should probably keep this.
```

### We could simplify these, to one or two comps:
```lua
ent.uiProperties = {
    clamped = true,
    draggable = true,
    togglable = true
}
```

And then, the whole `uiRegion` is an interesting one,   
because without the concept of a "main" scene; 
`uiRegion` is a LOT less meaningful.

But... it could still be nice to have. It's very clear and straightforward.
(Maybe keep it, and just call it `region`...?)
Do some thinking.





# Further questions / research:
How do we ergonomically register new UI elements?
- Could be entirely handled by gameplay mods.
- UI Mod shouldn't assume ANYTHING about how its handled.

What do we do about input in world context? 
We dont want to reinvent the wheel each time.
- (Perhaps could provide an auto-setup API, that sets up listener...?)

Should we be doing anything with the `:drawUI` callback...?
- No, I think we keep it.





# OKAY: FINAL THOUGHTS:
- Draw ALL UI in the game-world.
    - Simplify the ui mod to account for this.
    - (Maybe scenes can be extrapolated to the `interaction` mod?)

### What happens to `uiElement` component?
- Get rid of it...?

