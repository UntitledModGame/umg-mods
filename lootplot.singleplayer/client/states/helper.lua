
local helper = {}


function helper.drawBackground()
    local t = love.timer.getTime() * 3

    local r,g,b = objects.Color.HSLtoRGB(t, 0.6, 0.7)

    love.graphics.clear(r,g,b)
end



function helper.createStateListener(scene)
    local listener = input.InputListener()

    listener:onAnyPressed(function(this, controlEnum)
        this:claim(controlEnum) -- Don't propagate
        scene:controlPressed(controlEnum)
    end)

    listener:onPressed({"input:ESCAPE"}, function(this, controlEnum)
        -- TODO: Should we show pause box here?
        this:claim(controlEnum)
    end)

    listener:onPressed({"input:CLICK_PRIMARY", "input:CLICK_SECONDARY"}, function(this, controlEnum)
        local x,y = input.getPointerPosition()
        this:claim(controlEnum) -- Don't propagate
        scene:controlClicked(controlEnum,x,y)
    end)

    listener:onAnyReleased(function(_, controlEnum)
        if scene then
            scene:controlReleased(controlEnum)
        end
    end)

    listener:onTextInput(function(this, txt)
        if scene then
            local captured = scene:textInput(txt)
            if captured then
                this:lockTextInput()
            end
        end
    end)

    listener:onPointerMoved(function(this, x,y, dx,dy)
        return scene:pointerMoved(x,y, dx,dy)
    end)

    return listener
end


return helper
