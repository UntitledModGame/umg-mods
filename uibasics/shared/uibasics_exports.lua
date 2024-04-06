

local uiBasics = {}



if client then
--[[
    Client-side exports only!!
]]


local scene = require("client.scene")

function uiBasics.getSceneRegion()
    return ui.Region(0,0,love.graphics.getDimensions())
end


local function assertUIEnt(ent)
    local ui = ent.ui
    if not ui then
        umg.melt("Entity must have a .ui component!", 2)
    end
    if not (ui.element and ui.region) then
        umg.melt("Entity ui must have region and element!", 2)
    end
end


function uiBasics.open(ent)
    assertUIEnt(ent)
    scene:addChild(ent.ui.element)
end

function uiBasics.close(ent)
    assertUIEnt(ent)
    scene:removeChild(ent.ui.element)
end

function uiBasics.isOpen(ent)
    if ent.ui and ent.ui.element then
        local elem = ent.ui.element
        return scene:hasChild(elem)
    end
end

function uiBasics.getOpenElements()
    return scene:getChildren()
end

function uiBasics.getMainScene()
    return scene
end



umg.expose("uiBasics", uiBasics)

end

return uiBasics
