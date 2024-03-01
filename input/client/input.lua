
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



local function invert(mapping)
    local inverted = {}
    for k,v in pairs(mapping) do
        assert(not inverted[v], "Duplicate entry in control mapping: " .. tostring(v))
        inverted[v] = k
    end
    return inverted
end



local function newInputEnums()
    return setmetatable({}, {
        __index = function(t,k)
            error("Unknown function, or unknown input enum: " .. k)
        end
    })
end



local keyboardInputMapping = DEFAULT_INPUT_MAPPING 
-- { [inputEnum] -> scancode }

local scancodeMapping = invert(DEFAULT_INPUT_MAPPING)
-- { [scancode] -> inputEnum }

local mouseInputMapping = DEFAULT_MOUSE_MAPPING
-- { [inputEnum] -> mouseButton }

local mouseButtonMapping = invert(DEFAULT_MOUSE_MAPPING)
-- { [mousebutton] -> inputEnum }

local inputEnums = newInputEnums()
-- { [inputEnum] -> inputEnum } used by input table.
-- i.e.  input.BUTTON_1



local lockedScancodes = {--[[
    keeps track of the scancodes that are currently locked by a listener
    [scancode] --> listener
]]}

local lockedMouseButtons = {--[[
    keeps track of what mouse buttons are locked by what listener
    [mouseButton] -> listener
]]}




local sortedListeners = {}


local keyboardIsLocked = false


local mouseButtonsAreLocked = false
local mouseWheelIsLocked = false
local mouseMovementIsLocked = false




local input = setmetatable({}, {
    __index = function(t,k)
        if rawget(inputEnums, k) then
            return inputEnums[k]
        else
            error("Accessed an undefined key in input table: " .. tostring(k))
        end
    end
})



local lockChecks = {}
function lockChecks.keypressed(key, scancode, isrepeat)
    return keyboardIsLocked or lockedScancodes[scancode]
end
function lockChecks.keyreleased()
    return keyboardIsLocked
end
function lockChecks.mousepressed(x, y, button, istouch, presses)
    return mouseButtonsAreLocked or lockedMouseButtons[button]
end
function lockChecks.textinput(txt)
    return keyboardIsLocked or lockedScancodes[txt]
end
function lockChecks.wheelmoved()
    return mouseWheelIsLocked
end
function lockChecks.mousereleased()
    return mouseButtonsAreLocked
end
function lockChecks.mousemoved()
    return mouseMovementIsLocked
end












local function updateTables(keyboardMapping, mouseMapping)
    inputEnums = newInputEnums()

    keyboardInputMapping = keyboardMapping
    scancodeMapping = invert(keyboardMapping)

    mouseInputMapping = mouseMapping
    mouseButtonMapping = invert(mouseMapping)

    -- Add input enums:
    for inpEnum, _ in pairs(keyboardMapping)do
        inputEnums[inpEnum] = inpEnum
    end
    for inpEnum, _ in pairs(mouseMapping) do
        inputEnums[inpEnum] = inpEnum
    end
end



local function assertKeysValid(keyMapping)
    for inputEnum, scancode in pairs(keyMapping) do
        if not validInputEnums[inputEnum] then
            error("invalid input enum: " .. inputEnum, 2)
        end
        love.keyboard.getKeyFromScancode(scancode) -- this just asserts that the scancode is valid.
    end
end


local VALID_MOUSE_BUTTONS = {
    1,2,3,4,5
}

local function assertMousebuttonsValid(mouseMapping)
    for inputEnum, mousebutton in pairs(mouseMapping) do
        if not validInputEnums[inputEnum] then
            error("invalid input enum: " .. inputEnum, 2)
        end
        assert(VALID_MOUSE_BUTTONS[mousebutton], "Invalid mouse button:" .. mousebutton)
    end
end





function input.unlockEverything()
    keyboardIsLocked = false
    mouseButtonsAreLocked = false
    mouseWheelIsLocked = false
    mouseMovementIsLocked = false
end




local setControlsTc = typecheck.assert("table", "table")


function input.setControls(keyboardMapping, mouseMapping)
    setControlsTc(keyboardMapping, mouseMapping)
    assertKeysValid(keyboardMapping)
    assertMousebuttonsValid(mouseMapping)
    updateTables(keyboardMapping, mouseMapping)
end


input.setControls(DEFAULT_INPUT_MAPPING, DEFAULT_MOUSE_MAPPING)








--[[
    The reason we need to buffer events, is because listeners can
    implement an :update() method that is called in-order.
]]
local eventBuffer = objects.Array()







local function pollEvents(listener)
    for _, event in ipairs(eventBuffer) do
        if listener[event.type] then
            local isLocked = lockChecks[event.type](unpack(event.args))
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
    lockedScancodes[scancode] = nil
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

