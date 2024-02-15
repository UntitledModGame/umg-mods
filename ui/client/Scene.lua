
local lg = love.graphics


local Scene = ui.Element("ui:Scene")




function Scene:init()
    self:makeRoot()
end


local function renderChild(elem)
    if not elem.region then
        error("Element needs `.region` value to be rendered at root level: " .. elem:getType())
    end
    elem:render(elem.region:get())
end


function Scene:render(x,y,w,h)
    assert(x==0 and y==0, "wot wot?")
    assert(w==lg.getWidth(), "?")
    assert(h==lg.getHeight(),"?")

    for _, childElem in ipairs(self:getChildren()) do
        renderChild(childElem)
    end
end



return Scene
