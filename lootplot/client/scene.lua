

--[[

UI mod has one root element, that essentially acts as the "Scene"
    for ALL other LUI elements.

]]



local Scene = require("client.SceneElement")

local scene = Scene()


local BIG=0xfffff

local ORDER = -1
umg.on("rendering:drawEntities", ORDER, function()
    -- we need the scene to be BIG, so mouse inputs dont get chopped off.
    -- (entities within the scene will take world-values anyway)
    scene:render(-BIG,-BIG, BIG,BIG)
end)




local listener = input.InputListener({
    priority = 10
})


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



error([[

TODO:

We need to change the `input.getPointerPosition()` API to account for
different types of positions within different scene contexts.

For example, within the context of world-ui in lootplot,
we need the pointer-position to be transformed by the world-camera.

Thus, `scene:pointerMoved(dx,dy)` should pass in the pointer position,
AND we should have an extra Element function: `Element:getPointerPosition()` 
that gets the pointer position from the last-seen values..

]])

listener:onPointerMoved(function(_self, x,y, dx,dy)
    scene:pointerMoved(x,y, dx,dy)
end)




umg.on("@resize", function(x,y)
    scene:resize(x,y)
end)





local uiGroup = umg.group("ui")

uiGroup:onAdded(function(ent)
    local element = ent.ui.element
    element:bindEntity(ent)
end)



return scene

