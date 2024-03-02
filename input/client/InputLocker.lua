


local InputLocker = objects.Class("input:ControlManager")
--[[

Handles locking / unlocking of input.

(This ensures that we don't move the player
 when typing in chat, for example.)

This object is for INTERNAL USE ONLY!!!
SHOULD NOT BE USED OUTSIDE OF `input` MOD!!

]]


local function setupLockChecks(self)
    local lockChecks = {}
    function lockChecks.keypressed(key, scancode, isrepeat)
        return self.keyboardIsLocked or self.lockedScancodes[scancode]
    end
    function lockChecks.keyreleased()
        return self.keyboardIsLocked
    end
    function lockChecks.mousepressed(x, y, button, istouch, presses)
        return self.mouseButtonsAreLocked or self.lockedMouseButtons[button]
    end
    function lockChecks.textinput(txt)
        return self.keyboardIsLocked or self.lockedScancodes[txt]
    end
    function lockChecks.wheelmoved()
        return self.mouseWheelIsLocked
    end
    function lockChecks.mousereleased()
        return self.mouseButtonsAreLocked
    end
    function lockChecks.mousemoved()
        return self.mouseMovementIsLocked
    end

    --[[
        TODO:
        Add joysticks here when controller support is added.
    ]]

    self.lockChecks = lockChecks
end



function InputLocker:init()
    self.keyboardIsLocked = false

    self.mouseButtonsAreLocked = false
    self.mouseWheelIsLocked = false
    self.mouseMovementIsLocked = false

    self.lockedScancodes = {--[[
        keeps track of the scancodes that are currently locked by a listener
        [scancode] --> listener
        (the listener that is locking it)
    ]]}

    self.lockedMouseButtons = {--[[
        keeps track of what mouse buttons are locked by what listener
        [mouseButton] -> listenerObject
        (the listener that is locking it)
    ]]}

    setupLockChecks(self)
end



function InputLocker:isEventLocked(event, args)
    --[[
        event = "keypressed" or "mousepressed" etc etc
    ]]
    if not self.lockChecks[event] then
        error("Invalid event")
    end
    return self.lockChecks[event](unpack(args))
end




function InputLocker:lockKey(scancode)
    if self.lockedScancodes[scancode] and self.lockedScancodes[scancode] ~= self then
        error("scancode was already locked")
    end
    self.lockedScancodes[scancode] = self
end


function InputLocker:lockMouseButton(mousebutton)
    if self.lockedMouseButtons[mousebutton] and self.lockedMouseButtons[mousebutton] ~= self then
        error("mouse button was already locked")
    end
    self.lockedMouseButtons[mousebutton] = self
end


function InputLocker:lockInputEnum(inputEnum)
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



function InputLocker:isKeyDown(scancode)
    if self:isKeyLocked(scancode) then
        return false
    end
    if self.keyboardIsLocked then
        return false
    end
    return love.keyboard.isScancodeDown(scancode)
end


function InputLocker:isMouseButtonDown(mousebutton)
    if self.mouseButtonsAreLocked then
        return false
    end
    if self:isMouseButtonLocked(mousebutton) then
        return false
    end
    return love.mouse.isDown(mousebutton)
end



function InputLocker:unlockEverything()
    self.keyboardIsLocked = false
    self.mouseButtonsAreLocked = false
    self.mouseWheelIsLocked = false
    self.mouseMovementIsLocked = false
end



return InputLocker


