
local draw = {}


local currentCamera = require("client.current_camera")
local constants = require("client.constants")



local function getCameraPosition()
    -- The camera offset, (i.e. camera is offset 10 pixels to the right)
    local dx, dy = umg.ask("rendering:getCameraOffset") 
    if not dx then
        dx, dy = 0, 0
    end

    -- The global camera position in the world
    local x, y = umg.ask("rendering:getCameraPosition") 
    if not x then
        x, y = 0, 0
    end

    return x + dx, y + dy
end






function draw.getCameraPosition()
    --[[
        This provides cacheing, as opposed to polling the reverse
        event buses every single time.
        The "downside" of this is that it has the potential to be one
        frame delayed.
    ]]
    local camera = currentCamera.getCamera()
    return camera.x, camera.y
end


function draw.drawWorld(customCamera)
     --[[
        customCamera is an optional argument.
        should be left nil, most of the time, unless we want something custom.
        
        ALSO: This callback is *highly expensive*. Try to only call once or twice.
    ]]
    local camera = customCamera or currentCamera.getCamera()

    local x, y = getCameraPosition()
    camera:follow(x, y)
    camera:update(love.timer.getDelta())

    camera:attach()

    umg.call("rendering:drawGround", camera)

    -- IN-FUTURE: Draw predraw pixelated effects canvas here.
    -- used for stuff like ground-dust, background-fx, etc

    umg.call("rendering:drawEntities", camera)

    -- IN-FUTURE: Draw pixelated effects canvas here
    -- Used for stuff like spells, powerups, etc

    umg.call("rendering:drawEffects", camera)

    camera:draw()
    camera:detach()
end



umg.on("state:drawWorld", function()
    draw.drawWorld()
end)




umg.on("state:drawUI", function()
    umg.call("rendering:drawUI")
end)



return draw
