
local lg = love.graphics
local Element = require("client.newElement")


local Scene = Element("interaction:Scene")




function Scene:init()
    self:makeRoot()
    self:setPassthrough(true)
end


local function renderChild(elem)
    local ent = elem:getEntity()
    if not ent.uiRegion then
        error("Element needs `.region` value to be rendered at root level: " .. elem:getType())
    end
    elem:render(ent.uiRegion:get())
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
