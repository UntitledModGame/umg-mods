

# Spatial mod

Handles entity positions in the universe.
That is, `x`,`y`, and `dimension` component.

Also handles velocity components (vx, vy), `speed` component, 
and speed callbacks.

---


# Dimensions overview:

Every entity that has a "position" will have `x, y` components;
and optionally, a `dimension` component.

Think of a "dimension" as a realm where entities can exist in.<br/>
Like, a cave, dungeon, or a room.

---

## DimensionVectors:
`DimensionVectors` are central to this mod.
They represent a concrete position in the universe.

They are just a table of the following shape:
```lua
{
    x = 1,
    y = 439,
    dimension = "nether" -- optional value (defaults to "overworld")
    z = 439, -- optional value (defaults to 0)
}
```
Note that any entity with `x, y` components is also a DimensionVector.
(As such, it's common to pass `ent` around as a DimensionVector)

<br/>

---

## Dimension
At it's core, a "dimension" is just a string.  
However, every dimension has a `dimensionOverseer` entity;
an entity that controls the dimension.

To put an entity inside a dimension, simply change the `.dimension` component:
```lua
ent.dimension = "my_dimension"
-- now `ent` is inside of `my_dimension`
```
If `my_dimension` is an invalid dimension, the entity is moved back into it's previous dimension.  
if `ent.dimension` is nil, then the entity defaults to the `"overworld"`.

We can also create/destroy dimensions:
```lua
local dimOverseerEnt = dimensions.createDimension("nether")
dimensions.destroyDimension("yomi")
```
Destroying a dimension will delete it's overseer entity.



<br/>
<br/>


## DimensionStructures and DimensionPartitions:

These things are kinda complex/advanced.  
You probably won't need to use them.

Check the comments on the files if you want to understand.   
Ask for help on the discord if ur confused.


