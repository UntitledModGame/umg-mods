
--[[

A DimensionStructure is an abstract data structure that contains
other Objects for each dimension.

It's best understood through examples:


For example:
In the physics system, each dimension gets it's own physics world.
Each physics world is stored cleanly inside of the `DimensionStructure`.
The DimensionStructure handles moving entities between dimensions, by simply
removing entities from one physics world, and putting them in another.

Another example:
For rendering, each dimension has a ZIndexer data structure.
(for ordered drawing.)
All of the ZIndexers are handled by the DimensionStructure.


-------------------------
functions that MUST be overridden:
-------------------------

object = DimensionStructure:newObject(dimension)
DimensionStructure:addEntityToObject(object, ent)
DimensionStructure:removeEntityFromObject(object, ent)

-------------------------
Functions that NEED to be called manually, or else it wont work:
-------------------------

DimensionStructure:super()  must be called on init
DimensionStructure:addEntity(ent)  adds entity
DimensionStructure:removeEntity(ent)  removes entity
DimensionStructure:updateEntityDimension(ent)  call this whenever you want an entity's dimension to be updated

]]

require("shared.dimensions.DimensionVector") -- we need typecheck defs

local getDimension = require("shared.dimensions.getDimension")


local DimensionStructure = objects.Class("spatial:DimensionStructure")




function DimensionStructure:super()
    self.dimensionToObject = {--[[
        [dimension] --> Object
    ]]}

    self.entityToDimension = {--[[
        [entity] -> dimension
    ]]}
end



--[[
    gets the object owned by the following dimension.

    NOTE: 
    If you call `:getObject(ent.dimension)`, it is NOT
    guaranteed to return the object that contains this entity!!!!
    Use `getContainingObject` instead!!
]]
function DimensionStructure:getObject(dimension)
    if self.dimensionToObject[dimension] then
        return self.dimensionToObject[dimension]
    end

    local obj = self:newObject(dimension)
    assert(obj, "You need to return a value from overridden DimensionStructure:newObject()")
    self.dimensionToObject[dimension] = obj
    return obj
end



--[[
    Gets the object that contains the given entity.
]] 
function DimensionStructure:getObjectForEntity(ent)
    local dim = self.entityToDimension[ent]
    if dim then
        return self:getObject(dim)
    end
end




--[[
    call this whenever a dimension gets destroyed
    (:dimensionDestroyed event)

    If this isnt called, it's not the end of the world....
    we will just leak a bit of memory.
]]
function DimensionStructure:destroyDimension(dimension)
    local obj = self.dimensionToObject[dimension]
    if obj then
        self:destroyObject(obj)
    end
    self.dimensionToObject[dimension] = nil
end


--[[
    this doesn't actually *need* to be called.
    But you should call it whenever there's a `:dimensionCreated` event.
]]
function DimensionStructure:createDimension(dimension)
    self:getObject(dimension)
end




local function entityMoved(self, ent, oldDim, newDim)
    if not self:contains(ent) then
        return
    end

    oldDim = self.entityToDimension[ent] or oldDim

    local oldObj = self.dimensionToObject[oldDim]
    local newObj = self:getObject(newDim)

    self.entityToDimension[ent] = newDim -- set the new dimension

    -- move entity between objects:
    if oldObj then
        self:removeEntityFromObject(oldObj, ent)
    end
    self:addEntityToObject(newObj, ent)
end



function DimensionStructure:updateEntityDimension(ent)
    local oldDim = self.entityToDimension[ent]
    local dim = spatial.getDimension(ent)

    if oldDim ~= dim then
        entityMoved(self, ent, oldDim, dim)
    end
end



--[[
    Adds entity to dstructure
]]
function DimensionStructure:addEntity(ent)
    local dim = getDimension(ent)
    self.entityToDimension[ent] = dim
    local obj = self:getObject(dim)
    self:addEntityToObject(obj, ent)
end



--[[
    Removed entity from dstructure
]]
function DimensionStructure:removeEntity(ent)
    local dim = self.entityToDimension[ent]
    self.entityToDimension[ent] = nil
    local obj = self:getObject(dim)
    self:removeEntityFromObject(obj, ent)
end



function DimensionStructure:contains(ent)
    return self.entityToDimension[ent]
end


function DimensionStructure:hasDimension(dimension)
    return self.dimensionToObject[dimension]
end



--[[
==============================================================

Functions that need to be overridden:

==============================================================
]]

function DimensionStructure:newObject(dimension)
    umg.melt("OVERRIDE ME: when a new data structure should be made")
end


function DimensionStructure:addEntityToObject(object, ent)
    umg.melt("OVERRIDE ME: add an entity to the data structure `object`")
end


function DimensionStructure:removeEntityFromObject(object, ent)
    umg.melt("OVERRIDE ME: remove an entity from the data structure `object`")
end



--[[
    Optional Overrides:
]]
function DimensionStructure:destroyObject(object)
    -- Optional override
end


return DimensionStructure
