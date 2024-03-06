


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
    self.releaseCallbacks = {--[[
        [controlEnum] -> function
    ]]}

    self.textInputCallback = dummy
    
    self.pointerMovedCallback = dummy

    self.anyPressCallback = dummy
    self.anyReleaseCallback = dummy
end


local lockControlTc = typecheck.assert("control")
function InputListener:claim(controlEnum)
    lockControlTc(controlEnum)
    self.controlManager:lockControl(controlEnum, self)
end



function InputListener:lockTextInput()
    -- we just lock the keyboard
    self.controlManager:lockFamily("key")
end




local enumTc = typecheck.assert("control")
function InputListener:isDown(controlEnum)
    enumTc(controlEnum)
    return self.controlManager:isDownForListener(controlEnum, self)
end



local funcTc = typecheck.assert("function")
function InputListener:onUpdate(func)
    funcTc(func)
    self.updateCallback = func
end

local assertControl = typecheck.assert("control")
local controlFuncTc = typecheck.assert("control|table", "function")
function InputListener:onPress(controlEnum, func)
    controlFuncTc(controlEnum, func)
    if type(controlEnum) == "table" then
        for _, enum in ipairs(controlEnum) do
            assertControl(enum)
            self.pressCallbacks[enum] = func
        end
    else
        self.pressCallbacks[controlEnum] = func
    end
end

function InputListener:onRelease(controlEnum, func)
    controlFuncTc(controlEnum, func)
    if type(controlEnum) == "table" then
        for _, enum in ipairs(controlEnum) do
            self.releaseCallbacks[enum] = func
        end
    else
        self.releaseCallbacks[controlEnum] = func
    end
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
    func(self, controlEnum)
    self:anyPressCallback(controlEnum)
end

function InputListener:_dispatchRelease(controlEnum)
    local func = self.releaseCallbacks[controlEnum] or dummy
    func(self, controlEnum)
    self:anyReleaseCallback(controlEnum)
end


return InputListener
