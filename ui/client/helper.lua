

local helper = {}


local lg = love.graphics


function helper.rectangle(elem, x,y,w,h)
    lg.setColor(elem:getOption("backgroundColor"))
    local r = elem:getOption("rectangleRoundingRadius")
    lg.rectangle("fill", x,y,w,h, r,r)
end


function helper.outline(elem, x,y,w,h)
    lg.setLineWidth(elem:getOption("lineWidth"))
    lg.setColor(elem:getOption("outlineColor"))
    local r = elem:getOption("rectangleRoundingRadius")
    lg.rectangle("line", x,y,w,h, r,r)
end




return helper
