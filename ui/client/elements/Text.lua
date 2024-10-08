local Element = require("client.newElement")

---@class ui.Text: Element
local Text = Element("ui:Text")
--[[

Text is a text element that will scale itself to
automatically fit the given box.


]]


local lg = love.graphics

---@param font love.Font
---@param text string
---@param wrap number?
---@return number,number
local function getTextSize(font, text, wrap)
    local width, lines = font:getWrap(text, wrap or 2147483647)
    return width, #lines * font:getHeight()
end


---@param args string|{text:string,wrap:number?,font:love.Font?,align:love.AlignMode?,color:objects.Color?,outline:number?,outlineColor:objects.Color?,getScale?:fun():number}
function Text:init(args)
    self.font = love.graphics.getFont()
    self.getScale = nil
    if type(args) == "string" then
        self.text = args
    else
        self.text = args.text
        self.wrap = args.wrap -- whether we do text wrapping
        self.font = args.font or self.font
        self.getScale = args.getScale
    end

    self.align = args.align or "center"

    self.color = args.color

    self.outline = args.outline
    self.outlineColor = args.outlineColor
    if self.outline then
        assert(type(self.outline) == "number", "Outline must be number")
    end
end

if false then
    ---@param args string|{text:string,wrap:number?,font:love.Font?,align:love.AlignMode?,color:objects.Color?,outline:number?,outlineColor:objects.Color?,getScale?:fun():number}
    ---@return ui.Text
    ---@diagnostic disable-next-line: cast-local-type, missing-return
    function Text(args) end
end

local DEFAULT_OUTLINE_COLOR = {1,1,1}
local DEFAULT_COLOR = {0,0,0}


function Text:onRender(x,y,w,h)
    local tw, th = getTextSize(self.font, self.text, self.wrap)

    local limit = math.max(tw, w)
    ---@cast limit number

    -- scale text to fit box
    local scale = math.min(w/tw, h/th)
    if self.getScale then
        scale = self.getScale()
    end


    local drawX, drawY = x - (limit - w) / 2, y
    local color = self.color or DEFAULT_COLOR
    local realLimit = limit / scale

    if self.outline then
        local outlineColor = self.outlineColor or DEFAULT_OUTLINE_COLOR
        local am = self.outline
        lg.setColor(outlineColor)
        for ox=-am, am, am do
            for oy=-am, am, am do
                local oxs, oys = ox/scale, oy/scale
                lg.printf(self.text, self.font, drawX + oxs, drawY + oys, realLimit, self.align, 0, scale, scale)
            end
        end
    end
    lg.setColor(color)
    lg.printf(self.text, self.font, drawX, drawY, realLimit, self.align, 0, scale, scale)
end


function Text:setText(text)
    self.text = text
end

function Text:getText()
    return self.text
end


return Text

