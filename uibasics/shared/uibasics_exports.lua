


if client then
--[[
    Client-side exports only!!
]]


local scene = require("client.scene")

function ui.basics.getSceneRegion()
    return ui.Region(0,0,love.graphics.getDimensions())
end

function ui.basics.is


function ui.basics.isOpen(ent)
    if ent.ui and ent.ui.element then
        local elem = ent.ui.element
        return scene:hasChild(elem)
    end
end

function ui.basics.getOpenElements()
    return scene:getChildren()
end

ui.basics.SCENE = scene


end


