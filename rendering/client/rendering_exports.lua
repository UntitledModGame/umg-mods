---@meta

local rendering = {}
if false then _G.rendering = rendering end


local animate = require("client.animate")

local misc = require("client.misc")


local currentCamera = require("client.current_camera")
local cameraLib = require("libs.camera")


-- access to custom cameras
rendering.Camera = cameraLib

rendering.getCamera = currentCamera.getCamera





rendering.isOnScreen = misc.isOnScreen

rendering.drawEntity = misc.drawEntity

rendering.getDrawY = misc.getDrawY
rendering.getDrawDepth = misc.getDrawDepth

rendering.getEntityDrawDepth = misc.getEntityDrawDepth



local entityProperties = require("client.helper.entity_properties")
rendering.entityProperties = entityProperties


local imageSizes = require("client.helper.image_offsets");
rendering.getImageOffsets = imageSizes.getImageOffsets
rendering.getImageSize = imageSizes.getImageSize


rendering.drawImage = require("client.helper.draw_image");






function rendering.toScreenCoords(world_x, world_y)
    local cam = rendering.getCamera()
    return cam:toCameraCoords(world_x, world_y)
end


function rendering.toWorldCoords(x,y)
    local cam = rendering.getCamera()
    return cam:toWorldCoords(x,y)
end


rendering.animate = animate.animate;
rendering.animateEntity = animate.animateEntity;



umg.expose("rendering", rendering)

return rendering

