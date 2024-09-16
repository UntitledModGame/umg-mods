local RENDER_AFTER_ENTITY_ORDER = 1

umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER, function(ent, x,y, rot, sx,sy, kx,ky)
    if ent.doomCount then
        local q

        -- Note: This "if" order is also an optimization. There can be more slots than items
        -- but it's unlikely that there are more items than slots.
        if lp.isSlotEntity(ent) then
            if ent.doomCount <= 1 then
                q = client.assets.images.crack_big
            elseif ent.doomCount < 5 then
                q = client.assets.images.crack_small
            end
        elseif lp.isItemEntity(ent) then
            if ent.doomCount <= 1 then
                q = client.assets.images.doom_count_visual
            elseif ent.doomCount < 5 then
                q = client.assets.images.doom_count_warning_visual
            end
        end

        if q then
            rendering.drawImage(q, x, y, rot, sx,sy, kx,ky)
        end
    end
end)




umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER + 0.01, function(ent, x,y, rot, sx,sy, kx,ky)
    if ent.lives and ent.lives > 0 then
        local ox, oy = 0, 0
        local img = client.assets.images.life_visual
        if lp.isItemEntity(ent) then
            ox, oy = 6, 6
            rendering.drawImage(img, x + ox, y + oy, rot, sx,sy, kx,ky)
        elseif lp.isSlotEntity(ent) then
            ox, oy = -6, 6
            rendering.drawImage(img, x + ox, y + oy, rot + math.pi/2, sx * -1,sy, kx,ky)
        end
    end
end)

