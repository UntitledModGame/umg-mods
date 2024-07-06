


local lg=love.graphics

local SHADOW_OFFSET = 3
local ORDER = -10

umg.on("rendering:drawEntity", ORDER, function(slotEnt, x,y, ...)
    if lp.isSlotEntity(slotEnt) and slotEnt.image then
        -- draw shadow
        lg.push("all")
        lg.setColor(0,0,0,0.4)
        rendering.drawImage(slotEnt.image, x+SHADOW_OFFSET,y+SHADOW_OFFSET, ...)
        lg.pop()
    end
end)

