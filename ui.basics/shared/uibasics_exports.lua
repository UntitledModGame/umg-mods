
umg.melt([[


TODO:


rewrite this mod.
Elements shouldnt contain entities; instead, ents should contain elems,
through a special component.

]])


if client then
--[[
    Client-side exports only!!
]]


local scene = require("client.scene")

function ui.basics.getSceneRegion()
    return ui.Region(0,0,love.graphics.getDimensions())
end


local function getElement(elem_or_ent)
    local elem = elem_or_ent
    if umg.exists(elem_or_ent) then
        if not elem_or_ent.ui then
            return nil, "UI entity needs .ui component!"
        end
        elem = elem_or_ent.ui.element
    end
    return elem
end

local function ensureElement(elem_or_ent)
    local elem, er = getElement(elem_or_ent)
    if not elem then
        umg.melt(er)
    end
    return elem
end


function ui.basics.open(elem_or_ent)
    local elem = ensureElement(elem_or_ent)
    assert(elem:getDefaultRegion(), "Element needs a default region!")
    scene:addChild(elem)
end


function ui.basics.close(elem_or_ent)
    local elem = ensureElement(elem_or_ent)
    scene:removeChild(elem)
end


function ui.basics.isOpen(elem_or_ent)
    local elem = getElement(elem_or_ent)
    return scene:hasChild(elem)
end


function ui.basics.getOpenElements()
    return scene:getChildren()
end



ui.basics.SCENE = scene


end


