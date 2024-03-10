

# clickables TODO:


TODO IN THE FUTURE:

We should add `clickables:entityReleased`, 
for when the client has clicked on an entity, 
and then releases the mouse-click.

This would be great, as it'd allow for us to drag entities;
like the worldedit mod.
Also, we should provide an API that allows us to check whether an entity
is currently being clicked on.
Something like:
```lua
local ent = clickables.getClickedOnEntity()
```
That way, we could implement dragging REALLY EASILY,
just by using it inside of `@update` on the server.

Also; what about an event: `clickables:entityDragged`...?

