
require("client.followControls")



local follow = {}



local zoom_speed = nil

local DEFAULT_ZOOM_SPEED = 22

local MAX_ZOOM = 10
local MIN_ZOOM = 0.1




function follow.setMaxZoom(max_zoom)
    MAX_ZOOM = max_zoom
end

function follow.setMinZoom(min_zoom)
    MIN_ZOOM = min_zoom
end


local MIN_ZOOM_SPEED = 0.0000001
local MAX_ZOOM_SPEED = 100000000
function follow.setZoomSpeed(speed)
    zoom_speed = math.clamp(speed, MIN_ZOOM_SPEED, MAX_ZOOM_SPEED)
end




local listener = input.InputListener({priority = 0})


listener:onPress({"follow:ZOOM_IN", "follow:ZOOM_OUT"}, function(self, controlEnum)
    local camera = rendering.getCamera()
    local speed = zoom_speed or DEFAULT_ZOOM_SPEED
    if controlEnum == "follow:ZOOM_IN" then
        camera.scale = camera.scale * (1+(1/speed))
    else -- else, ZOOM_OUT
        camera.scale = camera.scale * (1-(1/speed))
    end

    -- now clamp:
    camera.scale = math.clamp(camera.scale, MIN_ZOOM, MAX_ZOOM)

    self:claim(controlEnum)
end)





local last_camx, last_camy = 0, 0




local DEFAULT_PAN_SPEED = 900

local MOUSE_PAN_THRESHOLD = 50 -- X pixels from the screen border to move.


local function followMouseNearEdge(dt)
    --[[
        if the mouse is near the edge of the screen,
        pan the camera towards that direction.
    ]]
    local dx,dy = 0,0
    local x, y = input.getPointerPosition()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local camera = rendering.getCamera()
    local speed = (DEFAULT_PAN_SPEED * dt) / camera.scale

    if x < MOUSE_PAN_THRESHOLD then
        dx = -speed
    elseif x > (w - MOUSE_PAN_THRESHOLD) then
        dx = speed
    end

    if y < MOUSE_PAN_THRESHOLD then
        dy = -speed
    elseif y > (h - MOUSE_PAN_THRESHOLD) then
        dy = speed
    end

    last_camx = last_camx + dx
    last_camy = last_camy + dy
end




local isPanning = false





listener:onUpdate(function(self, dt)
    if self:isDown("follow:CAMERA_PAN") then
        isPanning = true
    else
        isPanning = false
    end

    if isPanning then
        -- move the camera if the mouse is near edge of screen
        followMouseNearEdge(dt)
    else
        local camera = rendering.getCamera()
        last_camx = camera.x
        last_camy = camera.y
    end
end)




listener:onPointerMoved(function(self, dx,dy)
    if isPanning and self:isDown("follow:CAMERA_PAN") then
        -- use middle mouse button to pan camera
        local x,y = input.getPointerPosition()
        local wx1, wy1 = rendering.toWorldCoords(x-dx,y-dy)
        local wx2, wy2 = rendering.toWorldCoords(x,y)
        local wdx, wdy = wx2-wx1, wy1-wy2
        last_camx = last_camx - wdx
        last_camy = last_camy + wdy

        self:claim("follow:CAMERA_PAN")
    end
end)


local CAMERA_PAN_PRIORITY = 50

umg.answer("rendering:getCameraPosition", function()
    if isPanning then
        return last_camx, last_camy, CAMERA_PAN_PRIORITY
    end
    return nil -- allow for another system to take control
end)





umg.expose("follow", follow)

