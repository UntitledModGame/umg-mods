

local CAMERA_PRIORITY = 50

local followGroup = umg.group("cameraFollow")

local CAMERA = camera.Camera(0, 0, nil, nil, 3)

umg.on("@update", function()
    local sum_x = 0
    local sum_y = 0
    local len = 0

    for _, ent in ipairs(followGroup) do
        if ent.x and ent.y then
            sum_x = sum_x + ent.x
            sum_y = sum_y + ent.y - (ent.z or 0) / 2
            len = len + 1
        end
    end

    if len > 0 then
        CAMERA:setPos(sum_x / len, sum_y / len)
    end
end)

umg.answer("camera:getCamera", function()
    return CAMERA, CAMERA_PRIORITY
end)

umg.on("@resize", function(w, h)
    CAMERA:setViewportDimensions(w, h)
end)

return CAMERA
