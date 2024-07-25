---@class lootplot.main.RichText: Element
local RichText = ui.Element("lootplot.main:RichText")
--[[
RichText is a text element that will scale itself to
automatically fit the given box + support for rich formatting.
]]


local lg = love.graphics

---@param args string|{text:string,font?:love.Font,scale?:number,color?:objects.Color,wrap?:number}
function RichText:init(args)
    self.scale = 1
    self.color = objects.Color.WHITE
    self.font = love.graphics.getFont()
    self.text = ""

    if type(args) == "string" then
        self.text = args
    else
        self.text = args.text or ""
        self.color = args.color or objects.Color.WHITE
        self.wrap = args.wrap -- whether we do text wrapping
        self.scale = args.scale or 1
        self.font = args.font or self.font
    end
end

function RichText:getText()
    return self.text
end

---@param text string
function RichText:setText(text)
    self.text = text
end

---@param font love.Font
---@param text string
---@param wrap number?
---@return number,number
local function getTextSize(font, text, wrap)
    local width, lines = font:getWrap(text, wrap or 2147483647)
    return width, #lines * font:getHeight()
end

function RichText:onRender(x,y,w,h)
    local tw, th = getTextSize(self.font, assert(text.clear(self.text)), self.wrap)
    --[[
        TODO: do we want to propagate the text size to the parent
            somehow...?
        So the parent can do nicer rendering of something?
    ]]

    -- scale text to fit box
    local limit = self.wrap or tw
    local scale = math.min(w/limit, h/th) * self.scale
    local drawX, drawY = math.floor(x+w/2), math.floor(y+h/2)

    local r, g, b, a = love.graphics.getColor()
    local oldfont = lg.getFont()
    lg.setColor(self.color * objects.Color(r, g, b, a))
    lg.setFont(self.font)
    text.printRichText(self.text, drawX, drawY, limit, 0, scale, scale, tw / 2, th / 2)
    -- love.graphics.printf(self.text, drawX, drawY, limit, "left", 0, scale, scale, tw / 2, th / 2)
    lg.setFont(oldfont)
    lg.setColor(r, g, b, a)
end

return RichText

