
--[[
    A simple colored-box element
]]

local SimpleBox = ui.Element("lootplot:SimpleBox")

local lg=love.graphics


function SimpleBox:init(args)
    typecheck.assertKeys(arg, {"color"})
    self.color = objects.Color(args.color)
    self.thickness = 4 -- thickness of corner
    self.rounding = args.rounding or 0 -- corner rounding
end


function SimpleBox:setColor(otherColor)
    -- avoid copy operation:
    for i=1,4 do
        self.color[i] = otherColor
    end
end


function SimpleBox:setThickness(n)
    self.thickness = n
end


function SimpleBox:onRender(x,y,w,h)
    local t = self.thickness
    local t2 = t*2
    local t4 = t*2

    local r = self.rounding

    lg.setColor(objects.Color.WHITE)
    lg.rectangle("fill", x-t2,y-t2, w+t4,h+t4, r+t2,r+t2)

    lg.setColor(objects.Color.BLACK)
    lg.rectangle("fill", x-t,y-t, w+t2,h+t2, r+t,r+t)

    lg.setColor(self.color)
    lg.rectangle("fill", x,y, w,h, r,r)
end

