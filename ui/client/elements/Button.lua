

local Button = ui.Element("ui:Button")


local DEFAULT_PADDING = 12

local lg=love.graphics


function Button:init(args)
    typecheck.assertKeys(args, {"onClick"})
    self.onClick = args.onClick
    self.text = args.text
    self.padding = args.padding or DEFAULT_PADDING
    self.font = args.font or love.graphics.getFont()
    self.backgroundColor = args.backgroundColor
    self.outlineColor = args.outlineColor
    self.textColor = args.textColor
    if args.image then
        self.imageElement = ui.elements.Image({
            image = args.image
        })
        self:addChild(self.imageElement)
    end
end


local function ensureTextElement(self)
    if not self.textElement then
        self.textElement = ui.elements.Text({
            text = self.text,
            font = self.font,
            color = self.textColor,
        })
        self:addChild(self.textElement)
    end

    if self.textElement.text ~= self.text then
        -- we need to update!
        self.textElement.text = self.text
    end
end




function Button:onRender(x,y,w,h)
    local r = ui.Region(x,y,w,h)
    lg.setColor(self.backgroundColor or objects.Color.WHITE)
    lg.rectangle("fill", r:get())
    lg.setColor(self.outlineColor or objects.Color.BLACK)
    lg.rectangle("line", r:get())

    if self.imageElement then
        self.imageElement:render(x,y,w,h)
    end

    if self.text then
        ensureTextElement(self)
        self.textElement:render(x,y,w,h)
    end
end



function Button:onClickPrimary()
    self:onClick()
end




return Button

