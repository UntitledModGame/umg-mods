
--[[


DISCLAIMER:::

This code REALLY shouldnt be handled here!!!
(It's supposed to be handled in spatial.defaults)

But we need it here, because spatial.defaults has a bunch of 
other stuff like syncing that we don't want.

In the future it would be a lot better if spatial as a whole was a lot more assumptionless, yet powerful to use.

We would probably need contracts for this though.

]]

local moveGroup = umg.group("x", "y", "vx", "vy")



local function doFriction(ent, dt)
    local fric = (ent.friction or 12)
    local divisor = 1 + fric * dt
    ent.vx = ent.vx / divisor
    ent.vy = ent.vy / divisor
end



local function updateEnt(ent, dt)
    -- We don't move entities if they are being handled by physics system
    -- (although we do handle the Z component regardless)
    doFriction(ent, dt)
    ent.x = ent.x + ent.vx * dt
    ent.y = ent.y + ent.vy * dt
end



umg.on("@update", function(dt)
    for _, ent in ipairs(moveGroup) do
        updateEnt(ent, dt)
    end
end)



local syncPacket = "lootplot:syncPlayerPosition"
umg.definePacket(syncPacket, {
    typelist = {"entity", "number", "number"}
})

if client then
local playerGroup = umg.group("x", "y", "controllable")

umg.on("@tick", function(dt)
    for _, ent in ipairs(playerGroup) do
        if sync.isClientControlling(ent) then
            client.send(syncPacket, ent, ent.x, ent.y)
        end
    end
end)

end


if server then

server.on(syncPacket, function(clientId, ent,x,y)
    if sync.isControlledBy(ent, clientId) then
        ent.x = x
        ent.y = y
    end
end)

end
