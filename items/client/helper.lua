

local helper = {}


local lg = love.graphics


local function setDark(color)
    local r,g,b = color[1], color[2], color[3]
    lg.setColor(r*r-0.1, g*g-0.1, b*b-0.1)
end


local sqrt=math.sqrt

local function setLight(color)
    local r,g,b = color[1], color[2], color[3]
    lg.setColor(sqrt(r)+0.1, sqrt(g)+0.1, sqrt(b)+0.1)
end


local DEFAULT_LINE_WIDTH = 2

function helper.insetRectangle(x,y,w,h, color, lineWidth)
    color = color or objects.Color.WHITE
    lg.setColor(color)
    lg.rectangle("fill", x,y,w,h)

    lg.setLineWidth(lineWidth or DEFAULT_LINE_WIDTH)
    setLight(color)
    lg.line(x+w, y, x+w, y+h)
    lg.line(x, y+h, x+w, y+h)

    setDark(color)
    lg.line(x, y, x+w+1, y)
    lg.line(x, y, x, y+h+1)
end


function helper.outsetRectangle(x,y,w,h, color, lineWidth)
    color = color or objects.Color.WHITE
    lg.setColor(color)
    lg.rectangle("fill", x,y,w,h)

    lg.setLineWidth(lineWidth or DEFAULT_LINE_WIDTH)
    setDark(color)
    lg.line(x+w, y, x+w, y+h)
    lg.line(x, y+h, x+w, y+h)

    setLight(color)
    lg.line(x, y, x+w+1, y)
    lg.line(x, y, x, y+h+1)
end



return helper
