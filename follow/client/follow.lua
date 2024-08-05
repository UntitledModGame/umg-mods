
require("client.followControls")



local follow = {}

local CAMERA = require("client.camera_follow")
local PAN_CAMERA

local DEFAULT_ZOOM_SPEED = 22
local DEFAULT_ZOOM_FACTOR = 0
local DEFAULT_ZOOM_MULTIPLER = CAMERA:getZoom()
local ZOOM_FACTOR_MULTIPLER = 0.2

local MIN_ZOOM_FACTOR = -10
local MAX_ZOOM_FACTOR = 10

local zoom_speed = DEFAULT_ZOOM_SPEED
local targetZoomFactor = DEFAULT_ZOOM_FACTOR
local previousZoomFactor = DEFAULT_ZOOM_FACTOR
local displayZoomFactor = DEFAULT_ZOOM_FACTOR
local zoomFactorLerp = 1

local function computeScaleValue(value)
    return DEFAULT_ZOOM_MULTIPLER * 2 ^ (value * ZOOM_FACTOR_MULTIPLER)
end

---@param display boolean?
function follow.getScaleFromZoom(display)
    return computeScaleValue(display and displayZoomFactor or targetZoomFactor)
end

function follow.setMaxZoom(max_zoom)
    MAX_ZOOM_FACTOR = max_zoom
end

function follow.setMinZoom(min_zoom)
    MIN_ZOOM_FACTOR = min_zoom
end

function follow.getCurrentZoomMultipler()
    return DEFAULT_ZOOM_MULTIPLER
end

---@param zm number
function follow.setZoomMultipler(zm)
    DEFAULT_ZOOM_MULTIPLER = zm
end

function follow.getZoomFactor()
    return targetZoomFactor
end

function follow.getZoomFactorRange()
    return MIN_ZOOM_FACTOR, MAX_ZOOM_FACTOR
end

local MIN_ZOOM_SPEED = 0.0000001
local MAX_ZOOM_SPEED = 100000000
function follow.setZoomSpeed(speed)
    zoom_speed = math.clamp(speed, MIN_ZOOM_SPEED, MAX_ZOOM_SPEED)
end

---@param zf number
function follow.initiateZoom(zf)
    previousZoomFactor = displayZoomFactor
    targetZoomFactor = math.clamp(zf, MIN_ZOOM_FACTOR, MAX_ZOOM_FACTOR)
    zoomFactorLerp = 0
end

local function updateZoomValues(dt)
    zoomFactorLerp = math.clamp(zoomFactorLerp + dt * zoom_speed, 0, 1)
    local t = zoomFactorLerp * zoomFactorLerp -- make it quadratic smooth
    displayZoomFactor = (1 - t) * previousZoomFactor + t * targetZoomFactor

    local z = computeScaleValue(displayZoomFactor)
    CAMERA:setZoom(z)
    if PAN_CAMERA then
        PAN_CAMERA:setZoom(z)
    end
end

local listener = input.InputListener({priority = 0})


listener:onPressed({"input:SCROLL_UP", "input:SCROLL_DOWN"}, function(self, controlEnum)
    -- local speed = zoom_speed or DEFAULT_ZOOM_SPEED
    -- local factor = 1
    -- if controlEnum == "input:SCROLL_UP" then
    --     -- zoom in:
    --     factor = (1+(1/speed))
    -- else 
    --     -- else, zoom out:
    --     factor = (1-(1/speed))
    -- end

    -- -- now clamp:
    -- local z = math.clamp(CAMERA:getZoom() * factor, MIN_ZOOM, MAX_ZOOM)
    -- umg.log.trace("Zooming from to", CAMERA:getZoom(), z)
    -- CAMERA:setZoom(z)
    -- if PAN_CAMERA then
    --     PAN_CAMERA:setZoom(z)
    -- end

    -- self:claim(controlEnum)
    local zf = follow.getZoomFactor()
    if controlEnum == "input:SCROLL_UP" then
        -- zoom in:
        follow.initiateZoom(zf + 1)
    else 
        -- else, zoom out:
        follow.initiateZoom(zf - 1)
    end

    self:claim(controlEnum)
end)




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
    local speed = (DEFAULT_PAN_SPEED * dt) / PAN_CAMERA:getZoom()

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

    local cx, cy = PAN_CAMERA:getPos()
    PAN_CAMERA:setPos(cx + dx, cy + dy)
end

listener:onPressed("follow:CAMERA_PAN", function(l, controlEnum)
    PAN_CAMERA = CAMERA:clone()
    l:claim(controlEnum)
end)

listener:onReleased("follow:CAMERA_PAN", function()
    PAN_CAMERA = nil
end)

listener:onPointerMoved(function(self, x, y, dx,dy)
    if PAN_CAMERA and self:isDown("follow:CAMERA_PAN") then
        -- use middle mouse button to pan camera
        local wx1, wy1 = PAN_CAMERA:toWorldCoords(x-dx,y-dy)
        local wx2, wy2 = PAN_CAMERA:toWorldCoords(x,y)
        local wdx, wdy = wx2-wx1, wy1-wy2
        local cx, cy = PAN_CAMERA:getPos()
        PAN_CAMERA:setPos(cx - wdx, cy + wdy)

        self:claim("follow:CAMERA_PAN")
    end
end)


local CAMERA_PRIORITY = 51

umg.answer("camera:getCamera", function()
    return PAN_CAMERA or CAMERA, CAMERA_PRIORITY
end)

umg.on("@update", function(dt)
    if PAN_CAMERA then
        -- move the camera if the mouse is near edge of screen
        followMouseNearEdge(dt)
    end

    updateZoomValues(dt)
end)

umg.expose("follow", follow)

