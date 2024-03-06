

--[[

UI mod has one root element, that essentially acts as the "Scene"
    for ALL other LUI elements.

]]



local Scene = require("client.SceneElement")

local scene = Scene()


umg.on("rendering:drawUI", function()
    scene:render(ui.getSceneRegion():get())
end)




local listener = input.InputListener({
    priority = 10
})


listener:onAnyPress(function(self, controlEnum)
    local consumed = scene:controlPress(controlEnum)
    if consumed then
        self:claim(controlEnum)
    end
end)


listener:onAnyRelease(function(_self, controlEnum)
    scene:controlRelease(controlEnum)
end)


listener:onTextInput(function(self, txt)
    local captured = scene:textInput(txt)
    if captured then
        self:lockTextInput()
    end
end)


listener:onPointerMoved(function(_self, dx,dy)
    scene:pointerMoved(dx,dy)
end)




umg.on("@resize", function(x,y)
    scene:resize(x,y)
end)





local uiGroup = umg.group("uiElement")

uiGroup:onAdded(function(ent)
    ent.uiElement:bindEntity(ent)
end)

uiGroup:onRemoved(function(ent)
    scene:removeChild(ent.uiElement)
end)



return scene

