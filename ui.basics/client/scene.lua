

--[[

UI mod has one root element, that essentially acts as the "Scene"
    for ALL other LUI elements.

]]



local Scene = require("client.SceneElement")

local scene = Scene()


umg.on("rendering:drawUI", function()
    scene:render(ui.basics.getSceneRegion():get())
end)




local listener = input.InputListener()
input.add(listener, 10)


listener:onAnyPressed(function(self, controlEnum)
    local consumed = scene:controlPressed(controlEnum)
    if consumed then
        self:claim(controlEnum)
    end
end)


listener:onAnyReleased(function(_self, controlEnum)
    scene:controlReleased(controlEnum)
end)


listener:onTextInput(function(self, txt)
    local captured = scene:textInput(txt)
    if captured then
        self:lockTextInput()
    end
end)


listener:onPointerMoved(function(_self, x,y, dx,dy)
    scene:pointerMoved(x,y, dx,dy)
end)



umg.on("@resize", function(x,y)
    scene:resize(x,y)
end)





umg.melt([[

todo: this code is deprecated and trash.

maybe delete this entire mod, even?

]])
local uiGroup = umg.group("ui")

uiGroup:onAdded(function(ent)
    local element = ent.ui.element
    element:bindEntity(ent)
end)



return scene

