


local DEFAULT_GLOW_IMG = "light_default_glow"




local DEFAULT_SIZE = 24

local WHITE = {1,1,1,1}


local function drawGlow(ent, x,y, rot, _sx,_sy)
    love.graphics.push("all")
    local g = ent.glow
    love.graphics.setColor(g.color or WHITE)
    local imgname = g.image or DEFAULT_GLOW_IMG
    local glow_quad = client.assets.images[imgname]
    if not glow_quad then
        umg.melt("Unknown image for glow: " .. tostring(imgname))
    end

    local size = g.size or DEFAULT_SIZE
    local scale = size / DEFAULT_SIZE
    -- glow should ignore scale of entity
    rendering.drawImage(glow_quad, x,y, rot, scale, scale)
    love.graphics.pop()
end



local ORDER = 1

umg.on("rendering:drawEntity", ORDER, function(ent, x,y, rot, sx,sy)
    if ent.glow then
        drawGlow(ent)
    end
end)
