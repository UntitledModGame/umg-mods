local cam11 = require("libs.cam11")

---A very thin wrapper around cam11.
---@class camera.Camera: objects.Class
local Camera = objects.Class("camera:Camera")

local getWidth, getHeight
-- Note: We don't have love.graphics in server
if server then
    function getWidth()
        return 800
    end

    function getHeight()
        return 600
    end
else
    getWidth, getHeight = love.graphics.getWidth, love.graphics.getHeight
end

---@param x number
---@param y number
---@param w number?
---@param h number?
---@param scale number?
---@param rotation number?
function Camera:init(x, y, w, h, scale, rotation)
    w = w or getWidth()
    h = h or getHeight()
    self.cam11 = cam11.new(x, y, scale, rotation, 0, 0, w, h)
    self.dimension = spatial.getDefaultDimension()
end

function Camera:setDimension(dimension)
    self.dimension = spatial.getDimension(dimension)
end

function Camera:getDimension()
    return self.dimension
end

---@return spatial.DimensionVector
function Camera:getDimensionVector()
    local x, y = self.cam11:getPos()
    return {x = x, y = y, dimension = self.dimension}
end

---Convert screen coordinates to world coordinates.
---@param x number Screen X position
---@param y number Screen Y position
---@return number,number
function Camera:toWorldCoords(x, y)
    return self.cam11:toWorld(x, y)
end

---Convert world coordinates to screen coordinates.
---@param x number World X position
---@param y number World Y position
---@return number,number
function Camera:toCameraCoords(x, y)
    return self.cam11:toScreen(x, y)
end

---Get camera center world coordinates.
---@return number,number
function Camera:getPos()
    return self.cam11:getPos()
end

---@param x number World X position
---@param y number World Y position
function Camera:setPos(x, y)
    return self.cam11:setPos(x, y)
end

---Get camera scaling.
---@return number
function Camera:getZoom()
    return self.cam11:getZoom()
end

---@param z number Camera scaling.
function Camera:setZoom(z)
    return self.cam11:setZoom(z)
end

---Get camera rotation.
---@return number
function Camera:getAngle()
    return self.cam11:getAngle()
end

---@param r number Camera rotation.
function Camera:setAngle(r)
    return self.cam11:setAngle(r)
end

---@return love.Transform
function Camera:getTransform()
    return self.cam11:getTransform()
end

---@return number,number
function Camera:getViewportDimensions()
    local w, h = select(3, self.cam11:getViewport())
    return w, h
end

---@param w number Screen width.
---@param h number Screen height.
function Camera:setViewportDimensions(w, h)
    return self.cam11:setViewport(0, 0, w, h)
end

--------------------------------------------------------
-- Deprecated/unavailable functions in new Camera API --
--------------------------------------------------------

---@deprecated
function Camera:attach()
    umg.melt("replace Camera:attach() with rendering.attachCamera(Camera)")
end

---@deprecated
function Camera:detach()
    umg.melt("replace Camera:detach() with rendering.detachCamera(Camera)")
end

---@deprecated
function Camera:update(dt)
    umg.melt("Camera:update() is no longer supported")
end

---@deprecated
function Camera:draw()
    umg.melt("Camera:draw() is no longer supported")
end

if false then
    ---Create new camera object.
    ---@param x number X position of the camera in the world (center on the screen).
    ---@param y number Y position of the camera in the world (center on the screen).
    ---@param w number? Width of the viewport.
    ---@param h number? Height of the viewport.
    ---@param scale number? Camera scale.
    ---@param rotation number? Camera rotation.
    ---@return camera.Camera
    function Camera(x, y, w, h, scale, rotation) end ---@diagnostic disable-line: cast-local-type, missing-return
end

return Camera
