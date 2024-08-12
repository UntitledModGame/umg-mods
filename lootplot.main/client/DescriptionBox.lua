---@class lootplot.main.DescriptionBox: objects.Class
local DescriptionBox = objects.Class("lootplot.main:DescriptionBox")

local RICH_TEXT_TYPE = "richtext"
local DRAWABLE_TYPE = "drawable"
local NEWLINE_TYPE = "\n"

---@alias lootplot.DescriptionBoxFunction fun(x:number,y:number,w:number,h:number)
---@class lootplot.main._DescriptionBoxData
---@field public type string
---@field public height integer?
---@field public data string|fun():string|lootplot.DescriptionBoxFunction
---@field public font love.Font?

---@param defaultFont love.Font?
function DescriptionBox:init(defaultFont)
    ---@private
    self.contents = {} ---@type lootplot.main._DescriptionBoxData[]
    ---@private
    self.defaultFont = defaultFont or love.graphics.getFont()
end

---Add rich text to the description box.
---@param text string|fun():string Formatted rich text to add.
---@param font love.Font? Font to use when rendering this.
function DescriptionBox:addRichText(text, font)
    self.contents[#self.contents+1] = {type = RICH_TEXT_TYPE, data = text, font = font}
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

---Draw the description box.
---@param x number X position of the description box.
---@param y number Y position of the description box.
---@param w number Maximum width of the decription box can use.
---@param h number Maximum height of the description box can use. Any content that exceeded the height will not be rendered.
function DescriptionBox:draw(x, y, w, h)
    local r, g, b, a = love.graphics.getColor()
    local scale = love.graphics.getWidth() / 1280
    local currentHeight = 0
    local lastFont = self.defaultFont

    for _, content in ipairs(self.contents) do
        if content.type == NEWLINE_TYPE then
            -- Let's put the blame on next element
            currentHeight = currentHeight + lastFont:getHeight() * scale
        elseif content.type == RICH_TEXT_TYPE then
            local str = content.data 
            if type(str) == "function" then
                str = str()
            end
            ---@cast str string
            local font = content.font or self.defaultFont
            local strings = select(2, font:getWrap(text.clear(str) or str, w / scale))
            local height = #strings * font:getHeight() * scale

            if (currentHeight + height) > h then
                -- Stop and don't render this content
                break
            end

            love.graphics.setColor(r, g, b, a)
            text.printRich(str, font, x, y + currentHeight, w / scale, "left", 0, scale, scale)

            currentHeight = currentHeight + height
            lastFont = font
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

---Retrieve the best fit domensions for this description box.
---
---The returned width and height
---@param maxWidth number Maximum limit for text.
---@return number width Minimum width that fits the description box.
---@return number height Maximum height that can draw all the description box content.
function DescriptionBox:getBestFitDimensions(maxWidth)
    local currentWidth = 0
    local currentHeight = 0
    local lastFont = self.defaultFont -- For computing newlines
    local scale = love.graphics.getWidth() / 1280

    for _, content in ipairs(self.contents) do
        if content.type == RICH_TEXT_TYPE then
            local str = content.data ---@cast str string
            if type(str) == "function" then
                str = str()
            end
            local font = content.font or self.defaultFont

            local width, strings = font:getWrap(str, maxWidth / scale)

            currentWidth = math.max(currentWidth, width * scale)
            currentHeight = currentHeight + #strings * font:getHeight() * scale
            lastFont = font
        elseif content.type == NEWLINE_TYPE then
            currentHeight = currentHeight + lastFont:getHeight() * scale
        elseif content.type == DRAWABLE_TYPE then
            currentHeight = currentHeight + (content.height or 0) * scale
        end
    end

    return currentWidth, currentHeight
end

if false then
    ---Create new description box.
    ---@param font love.Font? Default font object to use (defaults to `love.graphics.getFont()`).
    ---@return lootplot.main.DescriptionBox
    ---@diagnostic disable-next-line: missing-return, cast-local-type
    function DescriptionBox(font) end
end

return DescriptionBox
