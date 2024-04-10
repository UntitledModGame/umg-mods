
local lg = love.graphics


local Scene = ui.Element("ui.basics:Scene")




function Scene:init()
    self:makeRoot()
    self:setPassthrough(true)
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
