
local globalScale = require("client.globalScale")
local fonts = require("client.fonts")



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





local QUITTING_TEXT = localization.localize("Quitting...")
local lg=love.graphics

function helper.drawQuittingScreen(x,y,w,h)
    -- draw background:
    lg.setColor(226/255, 195/255, 127/255)
    lg.rectangle("fill",x,y,w,h)

    local font = fonts.getLargeFont(32)
    lg.setFont(font)
    local W = font:getWidth(QUITTING_TEXT)
    local sc = globalScale.get() * 3

    -- draw outline
    local offset = sc * 2
    lg.setColor(0,0,0)
    local ww,hh = lg.getDimensions()
    lg.print(QUITTING_TEXT,x+ww/2 + offset, y+hh/3 + offset, 0, sc,sc, W/2)
    lg.print(QUITTING_TEXT,x+ww/2 - offset, y+hh/3 - offset, 0, sc,sc, W/2)
    lg.print(QUITTING_TEXT,x+ww/2 + offset, y+hh/3 - offset, 0, sc,sc, W/2)
    lg.print(QUITTING_TEXT,x+ww/2 - offset, y+hh/3 + offset, 0, sc,sc, W/2)

    -- draw txt
    lg.setColor(1,1,1)
    lg.print(QUITTING_TEXT,x+ww/2, y+hh/3, 0, sc,sc, W/2)
end





return helper
