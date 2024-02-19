


-- clientside exports only.
if client then


local scene = require("client.scene")


local ui = {}

ui.elements = require("client.elements")

ui.Region = require("kirigami.Region")

ui.Element = require("client.newElement")


function ui.getSceneRegion()
    return ui.Region(0,0,love.graphics.getDimensions())
end


local function assertUIEnt(ent)
    if not ent.uiElement then
        error("Entity must have a .uiElement component!", 2)
    end
    if (not ent.uiRegion) or (not ent.uiRegion.get) then
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

function ui.getOpenElements()
    return scene:getChildren()
end



umg.expose("ui", ui)

end


