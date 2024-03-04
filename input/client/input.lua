
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


local Listener = require("client.Listener")

function input.Listener(args)
    args = args or {}
    local listener = Listener({
        controlManager = controlManager,
        priority = args.priority or DEFAULT_LISTENER_PRIORITY
    })
    table.insert(sortedListeners, listener)
    table.sort(sortedListeners, sortPrioKey)
    return listener
end



local function pollEvents(listener)
    for _, event in ipairs(eventBuffer) do
        if listener[event.type] then
            local isLocked = inputLocker:isEventLocked(event.type, event.args)
            if (not isLocked) then
                local func = listener[event.type]
                assert(type(func) == "function", "listeners must be functions")
                func(listener, unpack(event.args))
                -- ensure to pass self as first arg 
            end
        end
    end
end



umg.on("@update", function(dt)
    if not client.isPaused() then
        for _, listener in ipairs(sortedListeners) do
            pollEvents(listener)
            
            if listener.update then
                listener:update(dt)
            end
        end
    end

    eventBuffer:clear()
    input.unlockEverything()
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

umg.on("@mousepressed", function (x, y, button, istouch, presses)
    controlManager:mousepressed(x, y, button, istouch, presses)
end)

umg.on("@mousereleased", function(x, y, button, istouch, presses)
    controlManager:mousereleased(x, y, button, istouch, presses)
end)

umg.on("@textinput", function(txt)
    controlManager:textinput(txt)
end)



return input

