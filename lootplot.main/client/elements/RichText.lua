---@class lootplot.main.RichText: Element
local RichText = ui.Element("lootplot.main:RichText")
--[[
RichText is a text element that will scale itself to
automatically fit the given box + support for rich formatting.
]]


local lg = love.graphics

---@param args string|{text:string|text.RichText,font?:love.Font,scale?:number,variables?:table,color?:objects.Color,wrap?:number,class?:(fun(text:string,args:table):text.RichText),effectGroup?:text.EffectGroup}
function RichText:init(args)
    local textString
    local constructor = text.RichText
    local effectGroup = nil
    local vars = _G

    self.scale = 1
    self.color = objects.Color.WHITE
    self.font = love.graphics.getFont()

    if type(args) == "string" then
        textString = args
    else
        textString = args.text
        vars = args.variables or _G
        constructor = args.class or text.RichText
        effectGroup = args.effectGroup

        self.color = args.color or objects.Color.WHITE
        self.wrap = args.wrap -- whether we do text wrapping
        self.scale = args.scale or 1
        self.font = args.font or self.font
    end

    if text.RichText:isInstance(textString) then
        ---@cast textString text.RichText
        self.richText = textString
    else
        ---@cast textString string
        self.richText = constructor(textString, {
            variables = vars,
            effectGroup = effectGroup
        })
    end
end



local DEFAULT_COLOR = {0,0,0}


function RichText:onRender(x,y,w,h)
    local wrapval = self.wrap or 2147483647
    local tw, tlines = self.richText:getWrap(self.wrap or wrapval, self.font)
    local th = #tlines * self.font:getHeight()
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
    self.richText:draw(self.font, drawX, drawY, limit, 0, scale, scale, tw / 2, th / 2)
    love.graphics.setColor(r, g, b, a)
end

function RichText:getRichText()
    return self.richText
end

---@param rt text.RichText
function RichText:setRichText(rt)
    self.richText = rt
end

return RichText

