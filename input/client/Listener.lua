


local Listener = objects.Class("input:Listener")

input.Listener = Listener


local dummy = function()end

function Listener:init(args)
    objects.assertKeys(args, {"controlManager", "priority"})
    self.controlManager = args.controlManager
    self.priority = args.priority

    self.updateCallback = dummy
    self.pressCallback = dummy
    self.releaseCallback = dummy
end


local lockControlTc = typecheck.assert("control")
function Listener:lockControl(controlEnum)
    lockControlTc(controlEnum)
    self.controlManager:lockControl(controlEnum, self)
end



function Listener:isDown(controlEnum)
    return self.controlManager:isDown(controlEnum, self)
end



function Listener:onUpdate(func)
    self.updateCallback = func
end
function Listener:onPress(func)
    self.pressCallback = func
end
function Listener:onRelease(func)
    self.releaseCallback = func
end


