

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



# Component-warping:
How do we deal with component-warping?

For example: In popups, we lerp upwards, based on the `timeElapsed`.
but... we can't really do that when it's a regular entity.

To solve this, we kinda gotta look at warping the values of components
manually.



# ParticleSystem burst emit:
How do we evoke "bursts" in ParticleSystems?
Obviously we could just call `:emit` on the particleSystem directly...
but that's kinda weird, because it's reaching INTO the component.

