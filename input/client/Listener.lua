


local Listener = objects.Class("input:Listener")

input.Listener = Listener

local DEFAULT_LISTENER_PRIORITY = 0



local function sortPrioKey(obj1, obj2)
    -- sorts backwards; i.e. higher priority
    -- comes first in the list 
    
    -- default priority is 0
    return (obj1.priority or 0) > (obj2.priority or 0)
end



function Listener:init(options)
    for k,v in pairs(options)do
        self[k] = v
    end
    
    self.priority = self.priority or DEFAULT_LISTENER_PRIORITY
    table.insert(sortedListeners, self)
    table.sort(sortedListeners, sortPrioKey)
end


function Listener:lockKey(scancode)
    if lockedScancodes[scancode] and lockedScancodes[scancode] ~= self then
        error("scancode was already locked")
    end
    lockedScancodes[scancode] = self
end


function Listener:lockMouseButton(mousebutton)
    if lockedMouseButtons[mousebutton] and lockedMouseButtons[mousebutton] ~= self then
        error("mouse button was already locked")
    end
    lockedMouseButtons[mousebutton] = self
end


function Listener:lockInputEnum(inputEnum)
    local key = self:getKey(inputEnum)
    if key then
        self:lockKey(key)
        return
    end

    local mousebutton = self:getMouseButton(inputEnum)
    if mousebutton then
        self:lockMouseButton(mousebutton)
        return
    end
end



function Listener:getKey(inputEnum)
    return keyboardInputMapping[inputEnum]
end

function Listener:getMouseButton(inputEnum)
    return mouseInputMapping[inputEnum]
end



function Listener:getKeyboardInputEnum(scancode)
    -- gets input enum from keyboard scancode
    return scancodeMapping[scancode]
end

function Listener:getMouseInputEnum(button)
    -- gets input enum from keyboard scancode
    return mouseButtonMapping[button]
end



function Listener:isKeyLocked(scancode)
    return lockedScancodes[scancode] and (lockedScancodes[scancode] ~= self)
end

function Listener:isMouseButtonLocked(mousebutton)
    return lockedMouseButtons[mousebutton] and lockedMouseButtons[mousebutton] ~= self
end


local function isValidInputEnum(value)
    return value and (keyboardInputMapping[value] or mouseInputMapping[value])
end



local lockControlTc = typecheck.assert("string")
function Listener:lockControl(controlEnum)
    lockControlTc(controlEnum)
    controlManager:lockControl(controlEnum, self)
end



function Listener:isControlDown(inputEnum)
    assert(isValidInputEnum(inputEnum), "Invalid input enum: " .. inputEnum)
    local scancode = self:getKey(inputEnum)
    if scancode then
        return self:isKeyDown(scancode)
    end
    local mousebutton = self:getMouseButton(inputEnum)
    if mousebutton then
        return self:isMouseButtonDown(mousebutton)
    end
end


function Listener:isKeyDown(scancode)
    if self:isKeyLocked(scancode) then
        return false
    end
    if keyboardIsLocked then
        return false
    end
    return love.keyboard.isScancodeDown(scancode)
end



function Listener:isMouseButtonDown(mousebutton)
    if mouseButtonsAreLocked then
        return false
    end
    if self:isMouseButtonLocked(mousebutton) then
        return false
    end
    return love.mouse.isDown(mousebutton)
end



--[[
    blocks keyboard events for the rest of the frame
]]
function Listener:lockKeyboard()
    keyboardIsLocked = true
end

--[[
    blocks mouse button events for the rest of the frame
]]
function Listener:lockMouseButtons()
    mouseButtonsAreLocked = true
end

--[[
    blocks mouse wheel events for the rest of the frame
]]
function Listener:lockMouseWheel()
    mouseWheelIsLocked = true
end

--[[
    blocks mouse movement events for the rest of the frame
]]
function Listener:lockMouseMovement()
    mouseMovementIsLocked = true
end

