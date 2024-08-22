local RENDER_AFTER_ENTITY_ORDER = 1

umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER, function(ent, x, y)
    if ent.doomCount then
        local q

        -- Note: This "if" order is also an optimization. There can be more slots than items
        -- but it's unlikely that there are more items than slots.
        if lp.isSlotEntity(ent) then
            if ent.doomCount <= 1 then
                q = client.assets.images.crack_effect_only
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
            rendering.drawImage(q, x, y)
        end
    end
end)
