---@class lootplot.main.RichText: Element
local RichText = ui.Element("lootplot.main:RichText")
--[[
RichText is a text element that will scale itself to
automatically fit the given box + support for rich formatting.
]]


local lg = love.graphics

---@param font love.Font
---@param text string
---@param wrap number?
local function getTextSize(font, text, wrap)
    local width, lines = font:getWrap(text, wrap or 2147483647)
    return width, #lines * font:getHeight()
end


---@param args string|{text:string,font?:love.Font,scale?:number,variables?:table,color?:objects.Color,wrap?:number,class?:(fun(text:string,args:table):text.Text),effectGroup?:text.EffectGroup}
function RichText:init(args)
    local textString

    self.richTextConstructor = text.Text
    self.scale = 1
    self.color = objects.Color.WHITE
    self.effectGroup = nil
    self.vars = _G
    self.font = love.graphics.getFont()

    if type(args) == "string" then
        textString = args
    else
        textString = args.text
        self.color = args.color or objects.Color.WHITE
        self.effectGroup = args.effectGroup
        self.wrap = args.wrap -- whether we do text wrapping
        self.vars = args.variables or _G
        self.scale = args.scale or 1
        self.font = args.font or self.font
        self.richTextConstructor = args.class or text.Text
    end

    self:setFormattedString(textString)
end



local DEFAULT_COLOR = {0,0,0}

function RichText:setFormattedString(text)
    self.richText = self.richTextConstructor(text, {
        font = self.font,
        effectGroup = self.effectGroup,
        variables = self.vars
    })
end

function RichText:onRender(x,y,w,h)
    local wrapval = self.wrap or 2147483647
    local tw, tlines = self.richText:getWrap(self.wrap or wrapval)
    local th = #tlines * self.richText:getFont():getHeight()
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
    lg.setColor(self.color * objects.Color(r, g, b, a))
    self.richText:draw(drawX, drawY, limit, 0, scale, scale, tw / 2, th / 2)
    love.graphics.setColor(r, g, b, a)
end

function RichText:getRichText()
    return self.richText
end

return RichText

