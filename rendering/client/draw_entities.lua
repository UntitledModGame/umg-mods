
--[[

Main drawing system for entities.
Will emit draw calls based on position, and in correct order.

]]



local currentCamera = require("client.current_camera")

local constants = require("client.constants")

local DimensionZIndexer = require("client.DimensionZIndexer")


local dimensionZIndexer = DimensionZIndexer()
-- ^^^ is an instance of dimensions.DimensionStructure



umg.on("spatial:dimensionDestroyed", function(dim)
    dimensionZIndexer:destroyDimension(dim)
end)



local drawGroup = umg.group("x", "y", "drawable")


drawGroup:onAdded(function(ent)
    dimensionZIndexer:addEntity(ent)
end)


drawGroup:onRemoved(function(ent)
    dimensionZIndexer:removeEntity(ent)
end)




umg.on("@resize", function()
    local w,h = love.graphics.getDimensions()
    local camera = currentCamera.getCamera()
    camera.w = w
    camera.h = h
end)



umg.on("spatial:entityMovedDimensions", function(ent, _oldDim, _newDim)
    --[[
        TODO: this is kinda hacky, weird code
    ]]
    if drawGroup:has(ent) then
        dimensionZIndexer:updateEntityDimension(ent)
    end
end)


--[[
    main draw function
]]
umg.on("rendering:drawEntities", function(camera)
    local dim = spatial.getDimension(camera:getDimension())
    local zindexer = dimensionZIndexer:getObject(dim)
    if zindexer then
        zindexer:drawEntities(camera)
    end
end)

