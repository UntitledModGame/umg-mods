

umg.on("@newEntityType", function(etype)
    if etype.slot then
        etype.imageShadow = {
            offset = 3
        }
    elseif etype.item then
        etype.imageShadow = {
            offset = 0.5
        }
    end
end)


local lg=love.graphics

local ORDER = -10

umg.on("rendering:drawEntity", ORDER, function(ent, x,y, ...)
    if ent.imageShadow and ent.image then
        -- draw shadow
        local offset = ent.imageShadow.offset
        
        lg.push("all")
        lg.setColor(0,0,0,0.4)
        rendering.drawImage(ent.image, x+offset,y+offset, ...)
        lg.pop()
    end

    if ent.shadow then
        if not ent._renderingShadow then
            -- need to avoid infinite recursion
            -- (TODO: this is EXTREMELY hacky and fragile, OH WELL)
            local offset = ent.shadow.offset or 1
            ent._renderingShadow = true
            local col = {0,0,0,0.6}
            lg.push("all")
            lg.setColor(col)
            local oldCol = ent.color
            ent.color = col
            rendering.drawEntity(ent,x+offset,y+offset,...)
            ent._renderingShadow = false
            ent.color = oldCol
            lg.pop()
        end
    end
end)

