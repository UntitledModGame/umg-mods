

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


function listener:mousepressed(mx, my, button, istouch, presses)
    local captured = scene:mousepressed(mx, my, button, istouch, presses)
    if captured then
        self:lockMouseButton(button)
    end
end


function listener:mousereleased(mx,my, button)
    scene:mousereleased(mx, my, button)
end


function listener:keypressed(key, scancode, isrepeat)
    local captured = scene:keypressed(key, scancode, isrepeat)
    if captured then
        self:lockKey(scancode)
    end
end


function listener:keyreleased(key, scancode, isrepeat)
    scene:keyreleased(key, scancode, isrepeat)
end


function listener:mousemoved(x,y,dx,dy)
    scene:mousemoved(x,y,dx,dy)
end


function listener:wheelmoved(dx,dy)
    scene:wheelmoved(dx,dy)
end


function listener:textinput(t)
    local captured = scene:textinput(t)
    if captured then
        self:lockKeyboard()
    end
end




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

