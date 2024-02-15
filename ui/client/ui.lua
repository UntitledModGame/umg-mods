


--[[

UI mod has one root element, that essentially acts as the "Scene"
    for ALL other LUI elements.

]]


local ui = {}


local Scene = require("client.Scene")

local scene = Scene()


umg.on("rendering:drawUI", function()
    scene:render(ui.getScreenRegion())
end)



local function assertUIEnt(ent)
    if not ent.uiElement then
        error("Entity must have a .uiElement component!", 2)
    end
    if not ent.uiRegion then
        error("Entity must have a .uiRegion component!", 2)
    end
end


function ui.open(ent)
    assertUIEnt(ent)
    scene:addChild(ent.uiElement)
end

function ui.close(ent)
    assertUIEnt(ent)
    scene:removeChild(ent.uiElement)
end

function ui.isOpen(ent)
    local elem = ent.uiElement
    return scene:hasChild(elem)
end




local uiGroup = umg.group("ui")

uiGroup:onAdded(function(ent)
    ent.uiElement:bindEntity(ent)
end)

uiGroup:onRemoved(function(ent)
    scene:removeChild(ent.uiElement)
end)



return ui

