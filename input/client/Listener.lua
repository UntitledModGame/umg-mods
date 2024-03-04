


local Listener = objects.Class("input:Listener")

input.Listener = Listener

local DEFAULT_LISTENER_PRIORITY = 0



local function sortPrioKey(obj1, obj2)
    -- sorts backwards; i.e. higher priority
    -- comes first in the list 
    
    -- default priority is 0
    return (obj1.priority or 0) > (obj2.priority or 0)
end



function Listener:init(args)
    objects.assertKeys(args)
    self.priority = args.priority
    
    self.priority = self.priority or DEFAULT_LISTENER_PRIORITY
    table.insert(sortedListeners, self)
    table.sort(sortedListeners, sortPrioKey)
end


local lockControlTc = typecheck.assert("control")
function Listener:lockControl(controlEnum)
    lockControlTc(controlEnum)
    controlManager:lockControl(controlEnum, self)
end



function Listener:isDown(controlEnum)
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

