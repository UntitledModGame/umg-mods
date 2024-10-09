local globalScale = {}

local GLOBAL_SCALE_INCREMENT = 0.5
local globalScaleValue = 1

local function update(w, h)
    local wscale = w / 600
    local hscale = h / 400
    local scale = math.min(wscale, hscale)
    globalScaleValue = math.floor(scale / GLOBAL_SCALE_INCREMENT + 0.5) * GLOBAL_SCALE_INCREMENT
end

umg.on("@load", function()
    update(love.graphics.getDimensions())
end)

umg.on("@resize", update)

function globalScale.get()
    return globalScaleValue
end

return globalScale
