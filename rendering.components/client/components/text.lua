

components.project("text", "drawable")
--[[

ent.text = "my_txt" 

OR 

ent.text = {
    text = "my_txt",
    getText = function(ent) return "txt_dynamic" end
    ox = 0,
    oy = 0
}

]]

local function getText(ent, tabl)
    if tabl.text then
        return tabl.text
    end

    if tabl.component and ent[tabl.component] then
        -- component referencing idiom:
        return ent[tabl.component]
    end

    if tabl.getText then
        return tabl.getText(ent)
    end

    return tabl.default or ""
end



local ORDER=1 -- draw on top of ent

umg.on("rendering:drawEntity", ORDER, function(ent, x,y, rot, sx,sy)
    if not ent.text then
        return
    end

    local txt = ent.text

    if type(txt) == "table" then
        txt = getText(ent, txt)
        local font = txt.font or love.graphics.getFont()
        text.printRichText(txt, font, x,y, rot, sx,sy)
    elseif type(txt) == "string" then
        local font = love.graphics.getFont()
        text.printRichText(txt, font, x,y, rot, sx,sy)
    else
        umg.melt("")
    end
end)

