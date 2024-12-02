---Provides functions related to drawing to screen.
---
---Availability: **Client**
---@class rendering
local rendering = {}
if false then
    _G.rendering = rendering
end


local animate = require("client.animate")
local draw = require("client.draw")
local misc = require("client.misc")



---@param dVec spatial.DimensionVector
---@param leighway number?
---@return boolean
function rendering.isOnScreen(dVec, leighway)
    return misc.isOnScreen(dVec, leighway)
end


---@param ent Entity
---@param x number?
---@param y number?
---@param rot number?
---@param sx number?
---@param sy number?
---@param kx number?
---@param ky number?
function rendering.drawEntity(ent, x,y, rot, sx,sy, kx,ky)
    return misc.drawEntity(ent, x, y, rot, sx, sy, kx, ky)
end

function rendering.drawWorld()
    return draw.drawWorld()
end


---gets the "screen" Y from y and z position.
---@param y number
---@param z number?
---@return number
function rendering.getDrawY(y, z)
    return misc.getDrawY(y, z)
end

---@param y number
---@param z number?
---@return integer
function rendering.getDrawDepth(y, z)
    return misc.getDrawDepth(y, z)
end


---@param ent Entity
---@return integer
function rendering.getEntityDrawDepth(ent)
    return misc.getEntityDrawDepth(ent)
end



local entityProperties = require("client.helper.entity_properties")
rendering.entityProperties = entityProperties


local imageSizes = require("client.helper.image_offsets")

---@param quad_or_name string|love.Quad
---@return number,number
function rendering.getImageOffsets(quad_or_name)
    return imageSizes.getImageOffsets(quad_or_name)
end

---@param quad_or_name string|love.Quad
---@return number,number
function rendering.getImageSize(quad_or_name)
    return imageSizes.getImageSize(quad_or_name)
end

local drawImage = require("client.helper.draw_image")

---@param quadName_or_quad string|love.Quad
---@param x number?
---@param y number?
---@param rot number?
---@param sx number?
---@param sy number?
---@param kx number?
---@param ky number?
function rendering.drawImage(quadName_or_quad, x, y, rot, sx, sy, ox, oy, kx, ky)
    return drawImage(quadName_or_quad, x, y, rot, sx, sy, ox, oy, kx, ky)
end


---@param frames integer
---@param time number
---@param x number
---@param y number
---@param z number?
---@param color objects.Color?
function rendering.animate(frames, time, x,y,z, color)
    return animate.animate(frames, time, x, y, z, color)
end

---@param ent Entity
---@param frames integer
---@param time number
function rendering.animateEntity(ent, frames, time)
    return animate.animateEntity(ent, frames, time)
end



umg.expose("rendering", rendering)
return rendering
