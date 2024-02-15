


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



local function assertUIEnt(uiEnt)
    if not uiEnt.ui then
        error("Entity must have a .ui component!", 2)
    end
end


function ui.open(uiEnt)
    assertUIEnt(uiEnt)
    scene:addChild(uiEnt.ui)
end

function ui.close(uiEnt)
    assertUIEnt(uiEnt)
    scene:removeChild(uiEnt.ui)
end

function ui.isOpen(uiEnt)
    local elem = uiEnt.ui
    return scene:hasChild(elem)
end




local uiGroup = umg.group("ui")


uiGroup:onRemoved(function(uiEnt)
    scene:removeChild(uiEnt.ui)
end)



return ui

