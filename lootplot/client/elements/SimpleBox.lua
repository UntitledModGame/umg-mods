
--[[
    A simple colored-box element
]]

local SimpleBox = ui.Element("lootplot:SimpleBox")

local lg=love.graphics


function SimpleBox:init(args)
    typecheck.assertKeys(args, {"color"})
    self.color = objects.Color(args.color)
    self.thickness = 4 -- thickness of corner
    self.rounding = args.rounding or 0
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
    local t = self.thickness
    local t2 = t*2
    local t4 = t*4


    local r = self.rounding
    local hasRounding = (r > 0)

    lg.setColor(1,1,1)
    rect(x-t2,y-t2, w+t4,h+t4, r+t2,r+t2, hasRounding)

    lg.setColor(0,0,0)
    rect(x-t,y-t, w+t2,h+t2, r+t,r+t, hasRounding)

    lg.setColor(self.color)
    rect(x,y, w,h, r,r, hasRounding)
end

