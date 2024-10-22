local RENDER_AFTER_ENTITY_ORDER = 1

umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER, function(ent, x,y, rot, sx,sy, kx,ky)
    if ent.doomCount then
        local q
        if lp.isSlotEntity(ent) then
            if ent.doomCount <= 1 then
                q = client.assets.images.crack_big
            else
                q = client.assets.images.crack_small
            end
        elseif lp.isItemEntity(ent) then
            if ent.doomCount <= 1 then
                q = client.assets.images.doom_count_visual
            else
                q = client.assets.images.doom_count_warning_visual
            end
        end

        local dy = 1 * math.sin(love.timer.getTime() * 3)
        if q then
            rendering.drawImage(q, x, y+dy, rot, sx,sy, kx,ky)
        end
    end
end)




umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER + 0.5, function(ent, x,y, rot, sx,sy, kx,ky)
    if ent.lives and ent.lives > 0 then
        local ox, oy = 0, 0
        if lp.isItemEntity(ent) then
            ox, oy = 6, 6
            local img = client.assets.images.life_visual
            rendering.drawImage(img, x + ox, y + oy, rot, sx,sy, kx,ky)
        elseif lp.isSlotEntity(ent) then
            local img = client.assets.images.slot_life_visual
            rendering.drawImage(img, x, y, rot, sx,sy, kx,ky)
        end
    end
end)



umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER + 1, function(ent, x,y, rot, sx,sy, kx,ky)
    local pgen = ent.pointsGenerated
    if pgen and pgen ~= 0 and lp.isSlotEntity(ent) then
        local img
        if pgen > 0 then
            img = "point_up_slot_visual"
        else
            img = "point_down_slot_visual"
        end
        rendering.drawImage(img, x,y,rot,sx,sy,kx,ky)
    end
end)



local RENDER_ON_TOP_ORDER = 20

local PI2=math.pi*2

umg.on("rendering:drawEntity", RENDER_ON_TOP_ORDER, function(ent, x,y, rot, sx,sy, kx,ky)
    local BOUNCE_SPEED = 2
    if lp.isItemEntity(ent) then
        local sel = lp.getCurrentSelection()
        if sel and sel.item then
            if ent ~= sel.item and lp.canCombineItems(sel.item, ent) then
                love.graphics.setColor(lp.COLORS.COMBINE_COLOR)
                local time = love.timer.getTime() * BOUNCE_SPEED
                local sc = 1 + math.sin(time*PI2)/12
                rendering.drawImage("combine_item_visual", x,y, rot, sc,sc)
            end
        end
    end
end)


