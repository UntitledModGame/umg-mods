


local Listener = objects.Class("input:Listener")

input.Listener = Listener


local dummy = function()end

function Listener:init(args)
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
function Listener:claim(controlEnum)
    lockControlTc(controlEnum)
    self.controlManager:lockControl(controlEnum, self)
end



function Listener:isDown(controlEnum)
    return self.controlManager:isDown(controlEnum, self)
end



function Listener:onUpdate(func)
    self.updateCallback = func
end

local controlFuncTc = typecheck.assert("control", "function")
function Listener:onPress(controlEnum, func)
    controlFuncTc(controlEnum, func)
    self.pressCallbacks[controlEnum] = func
end
function Listener:onRelease(controlEnum, func)
    controlFuncTc(controlEnum, func)
    self.releaseCallbacks[controlEnum] = func
end


function Listener:onAnyPress(func)
    self.anyPressCallback = func
end
function Listener:onAnyRelease(func)
    self.anyReleaseCallback = func
end


function Listener:onPointerMoved(func)
    self.pointerMovedCallback = func
end



--------------------------------------------------
--------- privates:
--------------------------------------------------


--[[
    todo:
    we should probably allow listeners to listen for ANY control type?
]]
function Listener:_dispatchPress(controlEnum)
    local func = self.pressCallbacks[controlEnum] or dummy
    func(self)
    self:anyPressCallback(controlEnum)
end

function Listener:_dispatchRelease(controlEnum)
    local func = self.releaseCallbacks[controlEnum] or dummy
    func(self)
    self:anyReleaseCallback(controlEnum)
end

function Listener:_dispatchPointerMoved(dx,dy)
    self:pointerMovedCallback(dx,dy)
end

function Listener:_update(dt)
    self:updateCallback(dt)
end

