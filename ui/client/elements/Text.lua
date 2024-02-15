

local Text = LUI.Element()
--[[

Text is a text element that will scale itself to
automatically fit the given box.


]]


local lg = love.graphics


local function getTextSize(self)
    local font = love.graphics.getFont()
    local width
    if self.wrap then
        width = font:getWrap(self.text, self.wrap)
    else
        width = font:getWidth(self.text)
    end
    local _, newlineCount = self.text:gsub('\n', '\n')
    local height = font:getHeight() * (newlineCount + 1)
    return width, height
end



function Text:init(args)
    if type(args) == "string" then
        self.text = args
    else
        self.text = args.text
        self.wrap = args.wrap -- whether we do text wrapping
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



local DEFAULT_OUTLINE_COLOR = {0,0,0}
local DEFAULT_COLOR = {1,1,1}


function Text:onRender(x,y,w,h)
    local tw, th = getTextSize(self)
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
        for ox=-am, am, am*2 do
            for oy=-am, am, am*2 do
                lg.printf(self.text, drawX + ox, drawY + oy, limit, self.align, 0, scale, scale, tw/2, th/2)
            end
        end
    end
    lg.setColor(color)
    lg.printf(self.text, drawX, drawY, limit, self.align, 0, scale, scale, tw/2, th/2)
end


function Text:setText(text)
    self.text = text
end

function Text:getText()
    return self.text
end


return Text

