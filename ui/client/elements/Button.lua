local Element = require("client.newElement")
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
    self.image = args.image or nil
    self.hoverColor = args.hoverColor or objects.Color.GRAY
end

if false then
    ---@param args {click:fun(self:ui.Button),text:string?,padding:number?,font:love.Font?,backgroundColor:objects.Color?,outlineColor:objects.Color?,textColor:objects.Color?,image?:string|love.Quad|love.Texture}
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
    local hovColor
    lg.setColor(1,1,1)
    if self:isHovered() then
        hovColor = self.hoverColor
    end
    if self.backgroundColor then
        lg.setColor(hovColor or self.backgroundColor)
        lg.rectangle("fill", r:get())
    end
    if self.outlineColor then
        lg.setColor(self.outlineColor)
        lg.rectangle("line", r:get())
    end

    if self.image then
        if hovColor then
            lg.setColor(hovColor)
        end
        ui.drawImageInBox(self.image, x,y,w,h)
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

