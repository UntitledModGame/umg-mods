local Element = require("client.newElement")
local Image = require("client.elements.Image")
local Text = require("client.elements.Text")

---@class ui.Button: Element
local Button = Element("ui:Button")


local DEFAULT_PADDING = 12

local lg=love.graphics


function Button:init(args)
    typecheck.assertKeys(args, {"click"})
    self.click = args.click
    self.text = args.text
    self.padding = args.padding or DEFAULT_PADDING
    self.font = args.font or love.graphics.getFont()
    self.backgroundColor = args.backgroundColor
    self.outlineColor = args.outlineColor
    self.textColor = args.textColor
    self.textElement = nil
    if args.image then
        self.imageElement = Image({
            image = args.image
        })
        self:addChild(self.imageElement)
    end
end

if false then
    ---@param args {click:fun(self:ui.Button),text:string?,padding:number?,font:love.Font?,backgroundColor:objects.Color?,outlineColor:objects.Color?,textColor:objects.Color?,image:string?}
    ---@return ui.Button
    function Button(args) end
end

---@param self ui.Button
local function ensureTextElement(self)
    if not self.textElement then
        self.textElement = Text({
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
    local r = layout.Region(x,y,w,h)
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



function Button:onClick(controlEnum)
    if controlEnum == "input:CLICK_PRIMARY" then
        self:click()
    end
end




return Button

