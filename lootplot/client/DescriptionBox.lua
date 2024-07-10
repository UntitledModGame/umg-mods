---@class lootplot.DescriptionBox: objects.Class
local DescriptionBox = objects.Class("lootplot:DescriptionBox")

local BASIC_TEXT_TYPE = "basictext"
local RICH_TEXT_TYPE = "richtext"
local DRAWABLE_TYPE = "drawable"
local NEWLINE_TYPE = "\n"

---@alias lootplot.DescriptionBoxFunction fun(x:number,y:number,w:number,h:number)
---@class lootplot._DescriptionBoxData
---@field public type string
---@field public height integer?
---@field public data text.Text|string|lootplot.DescriptionBoxFunction

---@param font love.Font?
function DescriptionBox:init(font)
    ---@private
    self.contents = {} ---@type lootplot._DescriptionBoxData[]
    ---@private
    self.font = font or love.graphics.getFont()
end

---Add plain text or rich text to the description box.
---@param text text.Text|string (Rich) text to add.
function DescriptionBox:addText(text)
    if type(text) == "string" then
        self.contents[#self.contents+1] = {type = BASIC_TEXT_TYPE, data = text}
    else
        self.contents[#self.contents+1] = {type = RICH_TEXT_TYPE, data = text}
    end
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
    local currentHeight = 0
    local lastFont = self.font -- For computing newlines

    for _, content in ipairs(self.contents) do
        if content.type == BASIC_TEXT_TYPE then
            local text = content.data ---@cast text string
            local strings = select(2, self.font:getWrap(text, w))
            local height = #strings * self.font:getHeight()

            if (currentHeight + height) > h then
                -- Stop and don't render this content
                break
            end

            love.graphics.setColor(r, g, b, a)
            love.graphics.printf(text, self.font, x, y, w, "left")

            lastFont = self.font
            currentHeight = currentHeight + height
        elseif content.type == NEWLINE_TYPE then
            -- Let's put the blame on next element
            currentHeight = currentHeight + lastFont:getHeight()
        elseif content.type == RICH_TEXT_TYPE then
            local richText = content.data ---@cast richText text.Text
            local font = richText:getFont()
            local strings = select(2, richText:getWrap(w))
            local height = #strings * font:getHeight()

            if (currentHeight + height) > h then
                -- Stop and don't render this content
                break
            end

            love.graphics.setColor(r, g, b, a)
            richText:draw(x, y, w)

            lastFont = font
            currentHeight = currentHeight + height
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
    local lastFont = self.font -- For computing newlines

    for _, content in ipairs(self.contents) do
        if content.type == BASIC_TEXT_TYPE then
            local text = content.data ---@cast text string
            local width, strings = self.font:getWrap(text, maxWidth)

            lastFont = self.font
            currentWidth = math.max(currentWidth, width)
            currentHeight = currentHeight + #strings * self.font:getHeight()
        elseif content.type == NEWLINE_TYPE then
            currentHeight = currentHeight + lastFont:getHeight()
        elseif content.type == RICH_TEXT_TYPE then
            local richText = content.data ---@cast richText text.Text
            local font = richText:getFont()
            local width, strings = richText:getWrap(maxWidth)

            lastFont = font
            currentWidth = math.max(currentWidth, width)
            currentHeight = currentHeight + #strings * font:getHeight()
        elseif content.type == DRAWABLE_TYPE then
            currentHeight = currentHeight + (content.height or 0)
        end
    end

    return currentWidth, currentHeight
end

if false then
    ---Create new description box.
    ---@param font love.Font? Default font object to use (defaults to `love.graphics.getFont()`).
    ---@return lootplot.DescriptionBox
    ---@diagnostic disable-next-line: missing-return, cast-local-type
    function DescriptionBox(font) end
end

return DescriptionBox
