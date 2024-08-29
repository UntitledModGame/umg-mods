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


---@param args string|{text:string,wrap:boolean?,font:love.Font?,scale:number?,align:love.AlignMode?,color:objects.Color?,outline:number?,outlineColor:objects.Color?}
function Text:init(args)
    self.font = love.graphics.getFont()
    if type(args) == "string" then
        self.text = args
    else
        self.text = args.text
        self.wrap = args.wrap -- whether we do text wrapping
        self.font = args.font or self.font
    end

    self.scale = args.scale or 1
    self.align = args.align or "left"

    self.color = args.color

    self.outline = args.outline
    self.outlineColor = args.outlineColor
    if self.outline then 
        assert(type(self.outline) == "number", "Outline must be number")
    end
end

if false then
    ---@param args string|{text:string,wrap:boolean?,font:love.Font?,scale:number?,align:love.AlignMode?,color:objects.Color?,outline:number?,outlineColor:objects.Color?}
    ---@return ui.Text
    function Text(args) end
end

local DEFAULT_OUTLINE_COLOR = {1,1,1}
local DEFAULT_COLOR = {0,0,0}


function Text:onRender(x,y,w,h)
    local tw, th = getTextSize(self.font, self.text, self.wrap)
    --[[
        TODO: do we want to propagate the text size to the parent
            somehow...?
        So the parent can do nicer rendering of something?
    ]]

    -- scale text to fit box
    local limit = self.wrap or tw
    local scale = math.min(w/limit, h/th) * self.scale
    local drawX, drawY = math.floor(x+w/2), math.floor(y+h/2)

    local color = self.color or DEFAULT_COLOR

    if self.outline then
        local outlineColor = self.outlineColor or DEFAULT_OUTLINE_COLOR
        local am = self.outline
        lg.setColor(outlineColor)
        for ox=-am, am, am do
            for oy=-am, am, am do
                lg.printf(self.text, self.font, drawX + ox, drawY + oy, limit, self.align, 0, scale, scale, tw/2, th/2)
            end
        end
    end
    lg.setColor(color)
    lg.printf(self.text, self.font, drawX, drawY, limit, self.align, 0, scale, scale, tw/2, th/2)
end


function Text:setText(text)
    self.text = text
end

function Text:getText()
    return self.text
end


return Text

