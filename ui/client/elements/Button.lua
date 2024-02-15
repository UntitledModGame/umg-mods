

local Button = LUI.Element()


local DEFAULT_PADDING = 12


function Button:init(args)
    self.onClick = args.onClick
    self.text = args.text
    self.padding = args.padding or DEFAULT_PADDING
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
            text = self.text
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
    ui.style:rectangle(r:get())

    if self.imageElement then
        self.imageElement:render(x,y,w,h)
    end

    if self.text then
        ensureTextElement(self)
        self.textElement:render(x,y,w,h)
    end
end



function Button:onMousePress(x,y)
    if self.onClick then
        self:onClick(x,y)
    end
end




return Button

