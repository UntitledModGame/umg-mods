---@class lootplot.backgrounds.IBackground: objects.Class
local IBackground = objects.Class("lootplot.backgrounds:IBackground")

function IBackground:init()
end

---@param dt number
function IBackground:update(dt)
end

---@param opacity number
function IBackground:draw(opacity)
end

---@param width number
---@param height number
function IBackground:resize(width, height)
end

return IBackground
