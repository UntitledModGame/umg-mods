

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



local function setDark(elem, color)
    local c = color or elem:getOption("backgroundColor")
    local r,g,b = c[1], c[2], c[3]
    lg.setColor(r*r-0.1, g*g-0.1, b*b-0.1)
end


local sqrt=math.sqrt

local function setLight(elem, color)
    local c = color or elem:getOption("backgroundColor")
    local r,g,b = c[1], c[2], c[3]
    love.graphics.setColor(sqrt(r)+0.1, sqrt(g)+0.1, sqrt(b)+0.1)
end


function helper.insetRectangle(elem, x,y,w,h, color, lineWidth)
    helper.rectangle(elem, x,y,w,h)

    lg.setLineWidth(lineWidth or elem:getOption("lineWidth"))
    setLight(elem, color)
    love.graphics.line(x+w, y, x+w, y+h)
    love.graphics.line(x, y+h, x+w, y+h)

    setDark(elem, color)
    love.graphics.line(x, y, x+w+1, y)
    love.graphics.line(x, y, x, y+h+1)
end


function helper.outsetRectangle(elem, x,y,w,h, color, lineWidth)
    helper.rectangle(elem, x,y,w,h)

    lg.setLineWidth(lineWidth or elem:getOption("lineWidth"))
    setDark(elem, color)
    love.graphics.line(x+w, y, x+w, y+h)
    love.graphics.line(x, y+h, x+w, y+h)

    setLight(elem, color)
    love.graphics.line(x, y, x+w+1, y)
    love.graphics.line(x, y, x, y+h+1)
end



return helper
