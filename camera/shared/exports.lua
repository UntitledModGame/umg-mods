---@meta

local camera = {}
if false then
    ---Availability: Client and Server
    _G.camera = camera
end

local Camera = require("shared.Camera")

local DEFAULT_ZOOM = 3

local globalCamera = Camera(0, 0, nil, nil, DEFAULT_ZOOM)

---Get the highest priority camera.
---
---Availability: Client and Server
---@return camera.Camera
function camera.get()
    return umg.ask("camera:getCamera")
end

---The Camera class. Use this to create your own camera.
---
---Availability: Client and Server
camera.Camera = Camera

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
