

components.project("circle", "drawable")




local lg = love.graphics
local DEFAULT_CIRCLE_THICKNESS = 10

local function drawCircle(ent, x, y, scale)
    local circle = ent.circle
    local size = circle.size or circle.getSize(ent)
    lg.setLineWidth(circle.thickness or DEFAULT_CIRCLE_THICKNESS)
    local mode = ent.mode or "line"
    love.graphics.circle(mode, x, y, size * scale)
end


umg.on("rendering:drawEntity", function(ent, x, y, _rot, sx, sy)
    if ent.circle then
        local scale = (sx + sy)/2 -- scale is average of sx,sy...? i reckon thats "fine"
        drawCircle(ent, x, y, scale)
    end
end)


