
--[[
    A simple colored-box element.

    The width of this box scales with respect to
]]

---@class lootplot.main.SimpleBox: Element
local SimpleBox = ui.Element("lootplot.main:SimpleBox")

local lg=love.graphics

---@param args {color:objects.Color,rounding:number?}
function SimpleBox:init(args)
    typecheck.assertKeys(args, {"color"})
    self.color = objects.Color(args.color)
    self.thickness = 2 -- thickness of corner
    self.rounding = args.rounding or 0
end

if false then
    ---@param args {color:objects.Color,rounding:number?}
    ---@return lootplot.main.SimpleBox
    function SimpleBox(args) end
end

function SimpleBox:setColor(otherColor)
    -- avoid copy operation:
    self.color = otherColor
end


function SimpleBox:setThickness(n)
    self.thickness = n
end


local function rect(x,y,w,h, rx,ry, hasRounding)
    if hasRounding then
        lg.rectangle("fill", x,y,w,h, rx,ry)
    else
        lg.rectangle("fill", x,y,w,h)
    end
end

function SimpleBox:onRender(x,y,w,h)
    return SimpleBox.draw(self.color, x, y, w, h, self.rounding, self.thickness)
end

---@param color objects.Color
---@param x number
---@param y number
---@param w number
---@param h number
---@param rounding number?
---@param thickness number?
function SimpleBox.draw(color, x, y, w, h, rounding, thickness)
    rounding = rounding or 0
    thickness = thickness or 0

    local t = math.floor(thickness * lg.getWidth()/500)
    local t2 = t*2
    local t4 = t*4

    local r = rounding
    local hasRounding = (r > 0)

    lg.setColor(1,1,1)
    rect(x-t2,y-t2, w+t4,h+t4, r+t2,r+t2, hasRounding)

    lg.setColor(0,0,0)
    rect(x-t,y-t, w+t2,h+t2, r+t,r+t, hasRounding)

    lg.setColor(color)
    rect(x,y, w,h, r,r, hasRounding)
end

return SimpleBox
