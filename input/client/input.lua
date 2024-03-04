
--[[

abstracting away the input.

TODO: Allow for even more custom stuff, like joysticks

]]


local sortedListeners = {}


local input = {}


--[[
    The reason we need to buffer events, is because listeners can
    implement an :update() method that is called in-order.
]]
local eventBuffer = objects.Array()




local ControlManager = require("client.ControlManager")

local controlManager = ControlManager({
    onControlPress = function(controlEnum)
        eventBuffer:add({
            type = "press",
            controlEnum = controlEnum
        })
    end,
    onControlRelease = function(controlEnum)
        eventBuffer:add({
            type = "release",
            controlEnum = controlEnum
        })
    end
})



local DEFAULT_LISTENER_PRIORITY = 0

local function sortPrioKey(obj1, obj2)
    -- sorts backwards; i.e. higher priority
    -- comes first in the list 
    
    -- default priority is 0
    return (obj1.priority or 0) > (obj2.priority or 0)
end


local InputListener = require("client.InputListener")

function input.InputListener(args)
    args = args or {}
    local listener = InputListener({
        controlManager = controlManager,
        priority = args.priority or DEFAULT_LISTENER_PRIORITY
    })
    table.insert(sortedListeners, listener)
    table.sort(sortedListeners, sortPrioKey)
    return listener
end


local EVENTS = objects.Enum({
    RELEASE = true,
    PRESS = true,
    POINTER_MOVED = true,
    TEXT_INPUT = true
})


local function update(listener, dt)
    for _, event in ipairs(eventBuffer) do
        local controlEnum = event.controlEnum
        if event.type == EVENTS.PRESS then
            local isLocked = controlManager:isLocked(controlEnum, listener)
            if not isLocked then
                listener:_dispatchPress(controlEnum)
            end
        elseif event.type == EVENTS.RELEASE then
            --[[
            TODO: currently, we are dispatching release to EVERY Listener...
            regardless of whether the system claimed it.
            Maybe we should only dispatch if it was claimed BY this exact Listener?
            ]]
            listener:_dispatchRelease(controlEnum)
        elseif event.type == EVENTS.POINTER_MOVED then
            listener:onPointerMovedCallback(event.dx, event.dy)
        elseif event.type == EVENTS.TEXT_INPUT then
            if not controlManager:isFamilyLocked("key") then
                listener:textInputCallback(event.text)
            end
        end
    end

    listener:updateCallback(dt)
end




umg.on("@update", function(dt)
    if not client.isPaused() then
        for _, listener in ipairs(sortedListeners) do
            update(listener, dt)
        end
    end

    eventBuffer:clear()
    controlManager:resetLocks()
end)




umg.on("@keypressed", function(key, scancode, isrepeat)
    controlManager:keypressed(key, scancode, isrepeat)
end)

umg.on("@keyreleased", function(key, scancode)
    controlManager:keyreleased(key, scancode)
end)

umg.on("@wheelmoved", function(dx, dy)
    controlManager:wheelmoved(dx, dy)
end)

umg.on("@mousemoved", function (x, y, dx, dy, istouch)
    controlManager:mousemoved(x, y, dx, dy, istouch)
end)

umg.on("@mousereleased", function(x, y, button, istouch, presses)
    controlManager:mousereleased(x, y, button, istouch, presses)
end)

umg.on("@textinput", function(txt)
    controlManager:textinput(txt)
end)

umg.on("@mousepressed", function(x, y, button, istouch, presses)
    controlManager:mousepressed(x, y, button, istouch, presses)
end)



--------------
-- Special events:
--------------
umg.on("@textinput", function(text)
    eventBuffer:add({
        type = EVENTS.TEXT_INPUT,
        text = text
    })
end)

umg.on("@mousemoved", function(x,y,dx,dy)
    --[[
        TODO: Provide a blocking API here.
        If the player is playing with a controller, we don't want
        mouse-input to be affecting user.
    ]]
    eventBuffer:add({
        type = EVENTS.POINTER_MOVED,
        dx = dx,
        dy = dy
    })
end)



function input.getPointer()
    --[[
        TODO: provide support for controllers in future here.

        We should probably create a separate module for the pointer...?
        Because we want to add a TONNE of flexibility.
    ]]
    return love.mouse.getPosition()
end


return input

