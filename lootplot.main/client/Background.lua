---@class lootplot.main.Background: objects.Class
local Background = objects.Class("lootplot.main:Background")

function Background:init()
end

---@param dt number
function Background:update(dt)
end

---@param opacity number
function Background:draw(opacity)
end

---@param width number
---@param height number
function Background:resize(width, height)
end

return Background
