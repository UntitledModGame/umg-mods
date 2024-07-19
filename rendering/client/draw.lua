
local draw = {}



function draw.drawWorld()
     --[[
        This callback is *highly expensive*. Try to only call once or twice.
    ]]
    local camera = camera.get()

    love.graphics.push()
    love.graphics.applyTransform(camera:getTransform())

    umg.call("rendering:drawBackground", camera)

    -- IN-FUTURE: Draw predraw pixelated effects canvas here.
    -- used for stuff like ground-dust, background-fx, etc

    umg.call("rendering:drawEntities", camera)

    -- IN-FUTURE: Draw pixelated effects canvas here
    -- Used for stuff like spells, powerups, etc

    umg.call("rendering:drawEffects", camera)

    love.graphics.pop()
end



umg.on("state:drawWorld", function()
    draw.drawWorld()
end)




umg.on("state:drawUI", function()
    umg.call("rendering:drawUI")
end)



return draw
