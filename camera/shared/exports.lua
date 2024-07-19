---@meta

local camera = {}
if false then _G.camera = camera end

local Camera = require("shared.Camera")

local DEFAULT_ZOOM = 3

local globalCamera = Camera(0, 0, nil, nil, DEFAULT_ZOOM)

---Get the highest priority camera.
---@return camera.Camera
function camera.get()
    return umg.ask("camera:getCamera")
end

---Get the global camera object.
---@deprecated
function camera.getGlobalCamera()
    return globalCamera
end

if client then
    umg.on("@resize", function(w, h)
        globalCamera:setViewportDimensions(w, h)
    end)
end

umg.answer("camera:getCamera", function()
    return globalCamera, 0
end)

umg.expose("camera", camera)
return camera
