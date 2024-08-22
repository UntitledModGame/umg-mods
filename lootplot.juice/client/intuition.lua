local RENDER_AFTER_ENTITY_ORDER = 1

local function entityHasPosition(ent)
    return ent.x and ent.y
end

umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER, function(ent)
    if entityHasPosition(ent) and ent.doomCount then
        if lp.isItemEntity(ent) then
            if ent.doomCount <= 1 then
                rendering.drawImage(client.assets.images.doom_count_visual, ent.x, ent.y)
            elseif ent.doomCount < 5 then
                rendering.drawImage(client.assets.images.doom_count_warning_visual, ent.x, ent.y)
            end
        end
        -- TODO: Slot entity cracks.
    end
end)
