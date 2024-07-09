

local moveGroup = umg.group("x", "y", "vx", "vy")





local function doFriction(ent, dt)
    local fric = (ent.friction or 12)
    local divisor = 1 + fric * dt
    ent.vx = ent.vx / divisor
    ent.vy = ent.vy / divisor
end






local function shouldMoveZ(ent)
    if (not ent.z) or (not ent.vz) then
        return
    end
    return true
end




local function updateEnt(ent, dt)
    -- We don't move entities if they are being handled by physics system
    -- (although we do handle the Z component regardless)
    if not ent:isOwned()then
        return
    end
    doFriction(ent, dt)
    ent.x = ent.x + ent.vx * dt
    ent.y = ent.y + ent.vy * dt

    if shouldMoveZ(ent) then
        ent.z = ent.z + ent.vz * dt
    end
end




umg.on("state:gameUpdate", function(dt)
    for _, ent in ipairs(moveGroup) do
        updateEnt(ent, dt)
    end
end)

