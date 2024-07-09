if false then utf8 = require("utf8") end -- sumneko hack

---@class text.SubText: objects.Class
local SubText = objects.Class("text:SubText")

---@param char string
---@param start integer
---@param width number
---@param height number
function SubText:init(char, start, width, height)
    self.char = char
    self.start = start
    self.length = utf8.len(char)
    self.width = width
    self.height = height
    self:reset()
end

---Reset the subtext changes from previous effects.
function SubText:reset()
    self.color = objects.Color.WHITE
    self.x = 0
    self.y = 0
    self.ox = 0
    self.oy = 0
    self.x = 0
    self.y = 0
    self.r = 0
    self.sx = 1
    self.sy = 1
    self.kx = 0
    self.ky = 0
end

---Return the character(s) in this subtext.
---@return string char The character(s) in this subtext.
function SubText:getChar()
    return self.char
end

---Return the length of character(s) in this subtext.
---
---The returned length is Unicode-aware, which may not same as `#SubText:getChar()`.
---@return integer length Length of the character(s).
function SubText:getLength()
    return self.length
end

---Get the index of the current character(s) relative to the parent Text object.
---@return integer index Index of the starting string relative to the parent Text object.
function SubText:getIndex()
    return self.start
end

---Retrieve the text color.
---@return objects.Color
function SubText:getColor()
    return self.color
end

---@param r number
---@param g number
---@param b number
---@param a number
---@diagnostic disable-next-line: duplicate-set-field
function SubText:setColor(r, g, b, a) end

---@param hex string|integer
---@diagnostic disable-next-line: duplicate-set-field
function SubText:setColor(hex) end

---@param color objects.Color
---@diagnostic disable-next-line: duplicate-set-field
function SubText:setColor(color) end

---@param color number[]
---@diagnostic disable-next-line: duplicate-set-field
function SubText:setColor(color) end

---@diagnostic disable-next-line: duplicate-set-field
function SubText:setColor(...)
    if objects.Color.isColor(select(1, ...)) then
        self.color = select(1, ...)
    else
        self.color = objects.Color(...)
    end
end

---Get the text position.
---@return number,number @The text offset position.
function SubText:getPosition()
    return self.x, self.y
end

---Set the text position.
---@param x number X position of the text.
---@param y number Y position of the text.
function SubText:setPosition(x, y)
    self.x, self.y = x, y
end

function SubText:getOffset()
    return self.ox, self.oy
end

---Get the text offset.
---@param ox number X offset of the text.
---@param oy number Y offset of the text.
function SubText:setOffset(ox, oy)
    self.ox, self.oy = ox, oy
end

---Get the text dimensions (width and height).
function SubText:getDimensions()
    return self.width, self.height
end

---@return number
function SubText:getRotation()
    return self.r
end

---@param r number
function SubText:setRotation(r)
    self.r = r
end

function SubText:getScale()
    return self.sx, self.sy
end

---@param sx number
---@param sy number
function SubText:setScale(sx, sy)
    self.sx, self.sy = sx, sy
end

function SubText:getShear()
    return self.kx, self.ky
end

---@param kx number
---@param ky number
function SubText:setShear(kx, ky)
    self.kx, self.ky = kx, ky
end

if false then
    ---@param char string
    ---@param start integer
    ---@param width number
    ---@param height number
    ---@return text.SubText
    ---@diagnostic disable-next-line: cast-local-type, missing-return
    function SubText(char, start, width, height) end
end

return SubText
