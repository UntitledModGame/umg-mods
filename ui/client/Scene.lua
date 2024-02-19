

--[[

UI mod has one root element, that essentially acts as the "Scene"
    for ALL other LUI elements.

]]



local Scene = require("client.SceneElement")

local scene = Scene()


umg.on("rendering:drawUI", function()
    scene:render(ui.getSceneRegion():get())
end)



local uiGroup = umg.group("uiElement")

uiGroup:onAdded(function(ent)
    ent.uiElement:bindEntity(ent)
end)

uiGroup:onRemoved(function(ent)
    scene:removeChild(ent.uiElement)
end)



return scene

