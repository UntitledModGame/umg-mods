

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

SOLUTION: KISS.
Change `.particles` component into a regular particleSystem.
From tehre, we can just call `ent.particles:emit(X)`





# Shockwaves:

So, we got the `circle` component being rendered well.
But, how should this work with the `shockwave` component...?

IDEA:
Maybe we don't even need a `shockwave` component!!!
Perhaps `juice.shockwave` could just create an entity with a growing circle,
and decreasing opacity.

OK; I think that ^^^ setup is quite beautiful.
But we need a few things:
- A way to track "lifetime" (DONE)
- A way to make the circle size scale with the lifetime 
    (function upon `circle` component?)
- Opacity needs to scale with lifetime 
    (fade component?)








