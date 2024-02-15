
local ScrollBox = LUI.Element()
--[[

ScrollBox

ScrollBox is an element that holds another element, `content`.

If `content`s height is bigger than the ScrollBox,
then the ScrollBox will create a ScrollBar that allows you to
scroll down to see the rest of `content`.


]]


local SCROLL_WIDTH = 20



function ScrollBox:init(args)
    assert(args.content, "No content given!")

    self.scrollWidth = args.scrollWidth or SCROLL_WIDTH

    self:addChild(args.content)
    self.content = args.content

    self.scroll = ui.elements.ScrollBar({
        sensitivity = args.sensitivity
    })
    self:addChild(self.scroll)
end



function ScrollBox:onRender(x,y,w,h)
    love.graphics.rectangle("line",x,y,w,h)
    local region = ui.Region(x,y,w,h)

    -- common idiom to create fixed-size splits:
    local content, scroll = region:splitHorizontal(w-self.scrollWidth, self.scrollWidth)

    assert(self.content.getHeight, "Content inside of ScrollBox needs a :getHeight method!")
    local contentHeight = self.content:getHeight()
    
    if h < contentHeight then
        self.scroll:render(scroll:get())

        local dy = -self.scroll:getScrollRatio() * (contentHeight - h)
        local X,Y,W,_ = content:offset(0,dy):get()
        self:startStencil(region:get())
        self.content:render(X,Y,W,contentHeight)
        self:endStencil()
    else
        self.content:render(region:get())
    end
end


function ScrollBox:onWheelMoved(_,dy)
    self.scroll:scroll(dy)
end


return ScrollBox


