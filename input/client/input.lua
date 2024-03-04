
--[[

abstracting away the input.

TODO: Allow for even more custom stuff, like joysticks

]]



-- The input mapping can be defined as anything,
-- but the base mod uses these controls by default:::
local DEFAULT_INPUT_MAPPING =  {
    UP = "w", -- (If you do change the controls, note that you can change the key it points to,
    LEFT = "a", -- but make sure to always keep the UP, DOWN, RIGHT, BUTTON_1, etc.)
    DOWN = "s",
    RIGHT = "d",

    BUTTON_SPACE = "space",
    BUTTON_SHIFT = "lshift",
    BUTTON_CONTROL = "lctrl",

    BUTTON_LEFT = "q",
    BUTTON_RIGHT = "e",

    BUTTON_1 = "r",
    BUTTON_2 = "f",
    BUTTON_3 = "c",
    BUTTON_4 = "x"
}


local DEFAULT_MOUSE_MAPPING = {
    MOUSE_1 = 1,
    MOUSE_2 = 2,
    MOUSE_3 = 3,
    MOUSE_4 = 4
}



local validInputEnums = {}

for enum,_ in pairs(DEFAULT_INPUT_MAPPING) do
    validInputEnums[enum] = true
end

for enum,_ in pairs(DEFAULT_MOUSE_MAPPING) do
    validInputEnums[enum] = true
end



local sortedListeners = {}




local input = {}



--[[
    The reason we need to buffer events, is because listeners can
    implement an :update() method that is called in-order.
]]
local eventBuffer = objects.Array()







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
    eventBuffer:add({
        args = {key, scancode, isrepeat},
        type = "keypressed"
    })
end)


umg.on("@keyreleased", function(key, scancode)
    eventBuffer:add({
        args = {key, scancode},
        type = "keyreleased"
    })
end)


umg.on("@wheelmoved", function(dx, dy)
    eventBuffer:add({
        args = {dx, dy},
        type = "wheelmoved"
    })
end)

umg.on("@mousemoved", function (x, y, dx, dy, istouch)
    eventBuffer:add({
        args = {x, y, dx, dy, istouch},
        type = "mousemoved"
    })
end)

umg.on("@mousepressed", function (x, y, button, istouch, presses)
    eventBuffer:add({
        args = {x, y, button, istouch, presses},
        type = "mousepressed"
    })
end)

umg.on("@mousereleased", function(x, y, button, istouch, presses)
    eventBuffer:add({
        args = {x, y, button, istouch, presses},
        type = "mousereleased"
    })
    lockedMouseButtons[button] = false
end)

umg.on("@textinput", function(txt)
    eventBuffer:add({
        args = {txt},
        type = "textinput"
    })
end)



return input

