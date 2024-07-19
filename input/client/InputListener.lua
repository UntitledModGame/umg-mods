

---@class input.InputListener: objects.Class
---@field package updateCallback input.InputListenerKeyCallback
---@field private pressCallbacks table<string, input.InputListenerKeyCallback>
---@field private releaseCallbacks table<string, input.InputListenerKeyCallback>
---@field package textInputCallback input.InputListenerTextInputCallback
---@field package pointerMovedCallback input.InputListenerPointerMoveCallback
---@field private anyPressCallback input.InputListenerKeyCallback
---@field private anyReleaseCallback input.InputListenerKeyCallback
local InputListener = objects.Class("input:InputListener")

---@alias input.InputListenerUpdateCallback fun(listener:input.InputListener,dt:number)
---@alias input.InputListenerKeyCallback fun(listener:input.InputListener,controlEnum:string)
---@alias input.InputListenerTextInputCallback fun(listener:input.InputListener,text:string)
---@alias input.InputListenerPointerMoveCallback fun(listener:input.InputListener,x:number,y:number,dx:number,dy:number)

local dummy = function()end

function InputListener:init(args)
    typecheck.assertKeys(args, {"controlManager", "priority"})
    ---@private
    self.controlManager = args.controlManager
    ---@private
    self.priority = args.priority

    self.updateCallback = dummy
    self.pressCallbacks = {--[[
        [controlEnum] -> function
    ]]}
    self.releaseCallbacks = {--[[
        [controlEnum] -> function
    ]]}
    ---@type input.InputListenerTextInputCallback
    self.textInputCallback = dummy
    ---@type input.InputListenerPointerMoveCallback
    self.pointerMovedCallback = dummy
    ---@type input.InputListenerKeyCallback
    self.anyPressCallback = dummy
    ---@type input.InputListenerKeyCallback
    self.anyReleaseCallback = dummy
end


local lockControlTc = typecheck.assert("control")
---@param controlEnum string
function InputListener:claim(controlEnum)
    lockControlTc(controlEnum)
    self.controlManager:lockControl(controlEnum, self)
end



function InputListener:lockTextInput()
    -- we just lock the keyboard
    self.controlManager:lockFamily("key")
end




local enumTc = typecheck.assert("control")
---@param controlEnum string
function InputListener:isDown(controlEnum)
    enumTc(controlEnum)
    return self.controlManager:isDownForListener(controlEnum, self)
end



local funcTc = typecheck.assert("function")
---@param func input.InputListenerUpdateCallback
function InputListener:onUpdate(func)
    funcTc(func)
    self.updateCallback = func
end

local assertControl = typecheck.assert("control")
local controlFuncTc = typecheck.assert("control|table", "function")
---@param controlEnum string|string[]
---@param func input.InputListenerKeyCallback
function InputListener:onPressed(controlEnum, func)
    controlFuncTc(controlEnum, func)
    if type(controlEnum) == "table" then
        assert(#controlEnum > 0, "No controls to listen to?")
        for _, enum in ipairs(controlEnum) do
            assertControl(enum)
            self.pressCallbacks[enum] = func
        end
    else
        self.pressCallbacks[controlEnum] = func
    end
end

---@param controlEnum string
---@param func input.InputListenerKeyCallback
function InputListener:onReleased(controlEnum, func)
    controlFuncTc(controlEnum, func)
    if type(controlEnum) == "table" then
        for _, enum in ipairs(controlEnum) do
            self.releaseCallbacks[enum] = func
        end
    else
        self.releaseCallbacks[controlEnum] = func
    end
end

---@param func input.InputListenerKeyCallback
function InputListener:onAnyPressed(func)
    funcTc(func)
    self.anyPressCallback = func
end

---@param func input.InputListenerKeyCallback
function InputListener:onAnyReleased(func)
    funcTc(func)
    self.anyReleaseCallback = func
end

---@param func input.InputListenerPointerMoveCallback
function InputListener:onPointerMoved(func)
    funcTc(func)
    self.pointerMovedCallback = func
end

---@param func input.InputListenerTextInputCallback
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
---@private
function InputListener:_dispatchPress(controlEnum)
    local func = self.pressCallbacks[controlEnum] or dummy
    func(self, controlEnum)
    self:anyPressCallback(controlEnum)
end

---@private
function InputListener:_dispatchRelease(controlEnum)
    local func = self.releaseCallbacks[controlEnum] or dummy
    func(self, controlEnum)
    self:anyReleaseCallback(controlEnum)
end

---@cast InputListener +fun(...):input.InputListener
return InputListener
