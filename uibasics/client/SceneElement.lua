
local lg = love.graphics


local Scene = ui.Element("ui.basics:Scene")




function Scene:init()
    self:makeRoot()
    self:setPassthrough(true)
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


function Scene:open(elem_or_ent)
    local elem = ensureElement(elem_or_ent)
    assert(elem:getDefaultRegion(), "Element needs a default region!")
    self:addChild(elem)
end


function Scene:close(elem_or_ent)
    local elem = ensureElement(elem_or_ent)
    self:removeChild(elem)
end


function Scene:isOpen(elem_or_ent)
    local elem = getElement(elem_or_ent)
    return self:hasChild(elem)
end


function Scene:getOpenElements()
    return self:getChildren()
end




local function renderChild(elem)
    local r = elem:getDefaultRegion()
    assert(elem:getDefaultRegion(), "Element needs a default region!")
    elem:render(r.x,r.y, r.w,r.h)
end


function Scene:onRender(x,y,w,h)
    assert(x==0 and y==0, "wot wot?")
    assert(w==lg.getWidth(), "?")
    assert(h==lg.getHeight(),"?")

    for _, childElem in ipairs(self:getChildren()) do
        renderChild(childElem)
    end
end




return Scene
