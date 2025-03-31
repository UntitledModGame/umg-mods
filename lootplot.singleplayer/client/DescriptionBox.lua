
local globalScale = require("client.globalScale")


---@class lootplot.singleplayer.DescriptionBox: objects.Class
local DescriptionBox = objects.Class("lootplot.singleplayer:DescriptionBox")

local RICH_TEXT_TYPE = "richtext"
local SEPARATOR = "---"
local DRAWABLE_TYPE = "drawable"
local NEWLINE_TYPE = "\n"

---@alias lootplot.DescriptionBoxFunction fun(x:number,y:number,w:number,h:number)
---@class lootplot.singleplayer._DescriptionBoxData
---@field public type string
---@field public height integer?
---@field public data string|fun():string|lootplot.DescriptionBoxFunction?
---@field public font love.Font?

---@param defaultFont love.Font?
function DescriptionBox:init(defaultFont)
    ---@private
    self.contents = {} ---@type lootplot.singleplayer._DescriptionBoxData[]
    ---@private
    self.defaultFont = defaultFont or love.graphics.getFont()
    ---@private
    self.borderColor = objects.Color(0.9,0.9,0.9)

    self.time = 0xfffff
end


---@param borderCol objects.Color
function DescriptionBox:setBorderColor(borderCol)
    self.borderColor = borderCol
end


---Add rich text to the description box.
---@param text string|fun():string Formatted rich text to add.
---@param font love.Font? Font to use when rendering this.
function DescriptionBox:addRichText(text, font)
    self.contents[#self.contents+1] = {type = RICH_TEXT_TYPE, data = text, font = font}
end

---Add separator to the description box.
--- This manifests as a horizontal line.
function DescriptionBox:addSeparator()
    self.contents[#self.contents+1] = {type = SEPARATOR}
end

---Add arbitrary drawable to the description box.
---@param func lootplot.DescriptionBoxFunction Function to call when drawing.
---@param occupyHeight number Height of the drawable that occupy.
function DescriptionBox:addDrawable(func, occupyHeight)
    self.contents[#self.contents+1] = {type = DRAWABLE_TYPE, data = func, height = occupyHeight}
end

---Add newline to the description box.
---
---Newline height will be computed using the last font used.
function DescriptionBox:newline()
    self.contents[#self.contents+1] = {type = NEWLINE_TYPE, data = "\n"}
end


function DescriptionBox:startOpen()
    self.time = 0
end


---@param self lootplot.singleplayer.DescriptionBox
---@param x number
---@param y number
---@param w number
---@param h number
function DescriptionBox:drawText(x,y,w,h)
    local r, g, b, a = love.graphics.getColor()
    local scale = globalScale.get() / 2
    local currentHeight = 0
    local lastFont = self.defaultFont

    for _, content in ipairs(self.contents) do
        if content.type == SEPARATOR then
            local c = self.borderColor
            love.graphics.setColor(c[1],c[2],c[3], 0.5)
            local font = content.font or self.defaultFont
            local fontH = font:getHeight() * scale
            local lw = love.graphics.getLineWidth()
            love.graphics.setLineWidth(scale * 2)
            local lineY = y+currentHeight + fontH/2
            love.graphics.line(x, lineY, x + w, lineY)
            currentHeight = currentHeight + fontH
            love.graphics.setLineWidth(lw)
        elseif content.type == NEWLINE_TYPE then
            -- Let's put the blame on next element
            currentHeight = currentHeight + lastFont:getHeight() * scale
        elseif content.type == RICH_TEXT_TYPE then
            local str = content.data
            if objects.isCallable(str) then
                str = str()
            end
            assert(type(str)=="string","?")
            ---@cast str string
            local font = content.font or self.defaultFont
            local stripped = text.stripEffects(str)
            if stripped:gsub("[%s\t\n]", ""):len() > 0 then
                local strings = select(2, font:getWrap(stripped, w / scale))
                local height = #strings * font:getHeight() * scale

                if (currentHeight + height) > h then
                    -- Stop and don't render this content
                    break
                end

                love.graphics.setColor(r, g, b, a)
                text.printRich(str, font, x, y + currentHeight, w / scale, "left", 0, scale, scale)

                currentHeight = currentHeight + height
                lastFont = font
            end
        elseif content.type == DRAWABLE_TYPE then
            local func = content.data ---@cast func lootplot.DescriptionBoxFunction
            local height = content.height or 0

            if (currentHeight + height) > h then
                -- Stop and don't render this content
                break
            end

            love.graphics.setColor(r, g, b, a)
            func(x, y + currentHeight, w, height)

            currentHeight = currentHeight + height
        end
    end

    love.graphics.setColor(r, g, b, a)
end



---Draw the description box.
---@param x number X position of the description box.
---@param y number Y position of the description box.
---@param w number Maximum width of the decription box can use.
---@param h number Maximum height of the description box can use. Any content that exceeded the height will not be rendered.
function DescriptionBox:draw(x, y, w, h)
    local bestWidth, bestHeight = self:getBestFitDimensions(w)

    local descriptionOpenSpeed = h * 20
    self.time = self.time + love.timer.getDelta()
    local maxHeight = self.time * descriptionOpenSpeed
    local theHeight = math.min(maxHeight, bestHeight)

    x = x + (w - bestWidth) -- shift right to account for width change

    local gs = globalScale.get() / 2

    local PAD_Y = 4*gs
    local PAD_X = 8*gs
    -- ^^^ NOOMA (numbers out of my ass)

    local rx,ry,rw,rh = x-PAD_X, y-PAD_Y, bestWidth+PAD_X*2, theHeight+PAD_Y*2

    -- draw BG
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", rx,ry,rw,rh, 10, 10)

    -- draw border
    local c = self.borderColor
    local lw = love.graphics.getLineWidth()
    love.graphics.setLineWidth(gs * 3)
    love.graphics.setColor(c[1], c[2], c[3])
    love.graphics.rectangle("line", rx,ry, rw,rh, 10, 10)
    love.graphics.setLineWidth(lw)

    if maxHeight >= h then
        love.graphics.setColor(1,1,1)
        self:drawText(x,y,w,h)
        return false
    end

    return true
end



---Retrieve the best fit domensions for this description box.
---
---The returned width and height
---@param maxWidth number Maximum limit for text.
---@return number width Minimum width that fits the description box.
---@return number height Maximum height that can draw all the description box content.
function DescriptionBox:getBestFitDimensions(maxWidth)
    local currentWidth = 0
    local currentHeight = 0

    local scale = globalScale.get() / 2

    for _, content in ipairs(self.contents) do
        if content.type == RICH_TEXT_TYPE then
            local str = content.data ---@cast str string
            if objects.isCallable(str) then
                str = str()
            end
            assert(type(str)=="string","?")
            local font = content.font or self.defaultFont

            local width, strings = font:getWrap(text.stripEffects(str), maxWidth / scale)

            currentWidth = math.max(currentWidth, width * scale)
            currentHeight = currentHeight + #strings * font:getHeight() * scale
        elseif content.type == NEWLINE_TYPE then
            local font = self.defaultFont
            currentHeight = currentHeight + font:getHeight() * scale
        elseif content.type == DRAWABLE_TYPE then
            currentHeight = currentHeight + (content.height or 0) * scale
        elseif content.type == SEPARATOR then
            currentHeight = currentHeight + (self.defaultFont:getHeight() * scale)
        end
    end

    return currentWidth, currentHeight
end

if false then
    ---Create new description box.
    ---@param font love.Font? Default font object to use (defaults to `love.graphics.getFont()`).
    ---@return lootplot.singleplayer.DescriptionBox
    ---@diagnostic disable-next-line: missing-return, cast-local-type
    function DescriptionBox(font) end
end

return DescriptionBox
