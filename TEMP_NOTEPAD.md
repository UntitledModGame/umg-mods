

# Clientside entities Juice refactor:

We have a couple of issues (or opportunities!) here:

- How do we determine whether an entity is rendered via pixel-perfect API
- How should we enforce usage of screen-space coords vs world coords...?


---

# Screen-space coords:
Idea: Use `screenX` and `screenY` variables
```lua
local screenDrawGroup = umg.group("screenX", "screenY", "drawable")
```



# Pixel-perfect API:
IDEATION: 

Perhaps we could have an extra layer object, `Renderer`, 
that is in charge of rendering ents. 

`Renderer` will contain a pixel-perfect canvas for pixel-rendering,
AND will also be able to render stuff to the main buffer (screen).

The idea is that ALL draw-functionality will work the same with
pixelated, AND non-pixelated entities.

IDEA: KISS- `pixelated` component
```lua
ent.pixelated = true
```



