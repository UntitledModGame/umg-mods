

# Spatial mod

Handles entity positions in the universe.
That is, `x`,`y`, and `dimension` component.

Also handles velocity components (vx, vy), `speed` component, 
and speed callbacks.


------

# Spatial mod planning:

- no getters/setters for entities changing dimensions

- automatically emits `:entityMovedDimensions` if an entity changes dimensions.

- spatial partitions have a dimension value too



```lua
local dim = spatial.getDimension(ent.dimension)


-- If entities aren't assigned a dimension, they will end up here.
local dim = dimensions.getDefaultDimension() -- "overworld"


local my_dim = dimensions.generateUniqueDimension("name") 
-- generates a new unique dimension name containing the word "name",
-- like `name_30948945845` or something.  Great for temporary dimensions.


local arr = dimensions.getAllDimensions() -- gets all dimensions



umg.on(":entityMovedDimensions", function(ent, oldDim, newDim)
    ... -- called when an entity moves dimensions
end)

umg.on(":dimensionCreated", function(dim_name)
    ... -- Called when a new dimension is created
end)

umg.on(":dimensionDestroyed", function(dim_name)
    ... -- called when a dimension is destroyed
end)




local ent = dimensions.server.createDimension(dimName, ent?)
-- creates a new dimension.
-- If an entity is passed in, this entity is the controller for this dim

dimensions.server.destroyDimension(dimName)
-- destroys a dimension




```

