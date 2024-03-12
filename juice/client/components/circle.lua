

components.project("circle", "drawable")




local lg = love.graphics
local DEFAULT_CIRCLE_THICKNESS = 10

local function drawCircle(ent)
    local circle = ent.circle
    local size = circle.size or circle.getSize(ent)
    lg.setLineWidth(circle.thickness or DEFAULT_CIRCLE_THICKNESS)
    local mode = ent.mode or "line"
    love.graphics.circle(mode, ent.x, ent.y, size)
end


umg.on("rendering:drawEntity", function(ent)
    if ent.circle then
        drawCircle(ent)
    end
end)


