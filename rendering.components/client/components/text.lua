
components.project("text", "drawable")

local ORDER = 1 -- draw text on top of ent

umg.on("rendering:drawEntity", ORDER, function(ent, x,y, rot, sx,sy)
    if not ent.text then
        return
    end

    local text = ent.text
    local font = ent.font or love.graphics.getFont()

    if type(text) == "string" then
        local width = font:getWidth(text)
        local height = font:getHeight()

        love.graphics.print(
            text, 
            x, 
            y,
            rot, sx, sy,
            width/2, height/2
        )
    else
        text:draw(font, x,y, 10000, rot, sx,sy)
    end
end)

