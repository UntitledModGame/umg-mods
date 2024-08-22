local RENDER_AFTER_ENTITY_ORDER = 1

local function entityHasPosition(ent)
    return ent.x and ent.y
end

---@param quad love.Quad
local function drawQuadInCenterOfEntity(ent, quad)
    local w, h = select(3, quad:getViewport())
    client.atlas:draw(quad, ent.x, ent.y, 0, 1, 1, w / 2, h / 2)
end

umg.on("rendering:drawEntity", RENDER_AFTER_ENTITY_ORDER, function(ent)
    if entityHasPosition(ent) and ent.doomCount then
        if lp.isItemEntity(ent) then
            if ent.doomCount <= 1 then
                drawQuadInCenterOfEntity(ent, client.assets.images.doom_count_visual)
            elseif ent.doomCount < 5 then
                drawQuadInCenterOfEntity(ent, client.assets.images.doom_count_warning_visual)
            end
        end
        -- TODO: Slot entity cracks.
    end
end)
