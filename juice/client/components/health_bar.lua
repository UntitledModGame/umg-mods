

--[[

.healthBar component

:-)

]]


local DEFAULT_DRAW_HEIGHT = 5
local DEFAULT_DRAW_WIDTH = 20

local DEFAULT_OFFSET_Y = 10

local DEFAULT_HEALTH_COLOR = {1,0.2,0.2}
local DEFAULT_OUTLINE_COLOR = {0,0,0}
local DEFAULT_BACKGROUND_COLOR = {0.4,0.4,0.4,0.4}

local lg=love.graphics

local function drawHealthBar(ent, x,y, r, sx,sy)
    -- draw the healthbar!
    local hb = ent.healthBar
    local w = hb.drawWidth or DEFAULT_DRAW_WIDTH
    local h = hb.drawHeight or DEFAULT_DRAW_HEIGHT
    local oy = hb.offset or DEFAULT_OFFSET_Y
    local hcol = hb.healthColor or hb.color or DEFAULT_HEALTH_COLOR
    local ocol = hb.outlineColor or DEFAULT_OUTLINE_COLOR
    local bgcol = hb.backgroundColor or DEFAULT_BACKGROUND_COLOR

    lg.push("all")
    lg.rotate(r)

    lg.setLineWidth(1)
    x = x - w/2
    y = y - h/2 - oy

    lg.setColor(bgcol) -- background
    lg.rectangle("fill", x, y, w, h)
    
    -- health bar:
    local ratio = ent.health / (ent.maxHealth or 0xfffffffff)
    ratio = math.max(0, ratio)
    lg.setColor(hcol)
    lg.rectangle("fill", x, y, w * ratio, h)

    if hb.shiny then
        -- TODO: Do this properly with hue or something
        local DIFF = 0.2
        local H = h/3
        lg.setColor(hcol[1]+DIFF, hcol[2]+DIFF, hcol[3]+DIFF)
        lg.rectangle("fill", x, y, w * ratio, H)
        lg.setColor(hcol[1]-DIFF, hcol[2]-DIFF, hcol[3]-DIFF)
        lg.rectangle("fill", x, y + (h - H), w * ratio, H)
    end

    -- outline of health bar:
    lg.setColor(ocol)
    lg.rectangle("line", x, y, w, h)

    lg.pop()
end



umg.on("rendering:drawEntity", function(ent, x,y, rot, sx,sy)
    if ent.healthBar and ent.health then
        drawHealthBar(ent, x, y, rot, sx,sy)
    end
end)


