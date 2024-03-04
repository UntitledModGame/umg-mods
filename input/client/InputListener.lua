


local InputListener = objects.Class("input:InputListener")



local dummy = function()end

function InputListener:init(args)
    objects.assertKeys(args, {"controlManager", "priority"})
    self.controlManager = args.controlManager
    self.priority = args.priority

    self.updateCallback = dummy
    self.pressCallbacks = {--[[
        [controlEnum] -> function
    ]]}
    self.releaseCallback = {--[[
        [controlEnum] -> function
    ]]}
    
    self.pointerMovedCallback = dummy

    self.anyPressCallback = dummy
    self.anyReleaseCallback = dummy
end


local lockControlTc = typecheck.assert("control")
function InputListener:claim(controlEnum)
    lockControlTc(controlEnum)
    self.controlManager:lockControl(controlEnum, self)
end



function InputListener:lockKeyboard()
    self.controlManager:lockFamily("key")
end
function InputListener:lockMouse()
    self.controlManager:lockFamily("mouse")
end
function InputListener:lockWheel()
    self.controlManager:lockFamily("wheel")
end



function InputListener:isDown(controlEnum)
    return self.controlManager:isDown(controlEnum, self)
end



local funcTc = typecheck.assert("function")
function InputListener:onUpdate(func)
    funcTc(func)
    self.updateCallback = func
end

local controlFuncTc = typecheck.assert("control", "function")
function InputListener:onPress(controlEnum, func)
    controlFuncTc(controlEnum, func)
    self.pressCallbacks[controlEnum] = func
end
function InputListener:onRelease(controlEnum, func)
    controlFuncTc(controlEnum, func)
    self.releaseCallbacks[controlEnum] = func
end


function InputListener:onAnyPress(func)
    funcTc(func)
    self.anyPressCallback = func
end
function InputListener:onAnyRelease(func)
    funcTc(func)
    self.anyReleaseCallback = func
end


function InputListener:onPointerMoved(func)
    funcTc(func)
    self.pointerMovedCallback = func
end

function InputListener:onTextInput(func)
    funcTc(func)
    self.textInputCallback = func
end



--------------------------------------------------
--------- privates:
--------------------------------------------------


--[[
    todo:
    we should probably allow listeners to listen for ANY control type?
]]
function InputListener:_dispatchPress(controlEnum)
    local func = self.pressCallbacks[controlEnum] or dummy
    func(self)
    self:anyPressCallback(controlEnum)
end

function InputListener:_dispatchRelease(controlEnum)
    local func = self.releaseCallbacks[controlEnum] or dummy
    func(self)
    self:anyReleaseCallback(controlEnum)
end

