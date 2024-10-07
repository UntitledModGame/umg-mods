


local MIN_DIST = 20

local TOTAL_LIFETIME = 3
local FLOAT_TIME = 0.32


local function updateEnt(ent)
    local dt = love.timer.getAverageDelta()

    local x,y = ent.x, ent.y
    local tx,ty = ent._getTargetPosition()

    ent.friction = 1

    local ddx, ddy = tx-x, ty-y
    local dx,dy = math.normalize(tx-x, ty-y)

    local dot = dx*ent.vx + dy*ent.vy
    local accel = ent._accel

    if (TOTAL_LIFETIME - ent.lifetime) > FLOAT_TIME then
        ent.vx = (dx * accel)
        ent.vy = (dy * accel)
    end

    if math.distance(ddx, ddy) < MIN_DIST then
        -- we have reached target
        ent:delete()
    end
end



---@param dvec spatial.DimensionVector
---@param speedMag number
---@param accel number
---@param getTarget fun(): number,number
local function newPacketEnt(dvec, speedMag, accel, getTarget)
    local ent = client.entities.empty()
    ent.x = dvec.x
    ent.y = dvec.y
    ent.dimension = dvec.dimension

    ent.lifetime = 3

    ent.vx, ent.vy = math.random(-speedMag, speedMag), math.random(-speedMag, speedMag)

    ent._accel = accel
    ent._getTargetPosition = getTarget

    -- HACK: using onDraw as onUpdate. Also, function as rcomp is bad
    -- (it only works because clientside-only entity)
    ent.onDraw = updateEnt

    return ent
end



umg.on("lootplot.tiers:entityUpgraded", function(ent, sourceEnt, oldTier, newTier)
    if not umg.exists(sourceEnt) then return end
    if lp.isItemEntity(ent) and ent.image then
        local dvec = {
            x = sourceEnt.x, y = sourceEnt.y,
            dimension = sourceEnt.dimension
        }
        local packetEnt = newPacketEnt(dvec, 300, 800, function()
            return ent.x or 0, ent.y or 0
        end)
        packetEnt.image = ent.image
    end
end)




umg.on("lootplot:pointsChanged", function(ent, delta)
    if lp.isItemEntity(ent) and ent.image then
        local dvec = {
            x = ent.x, y = ent.y,
            dimension = ent.dimension
        }
        local packetEnt = newPacketEnt(dvec, 300, 800, function()
            local camera = camera.get()
            return camera:toWorldCoords(love.mouse.getPosition())
        end)
        packetEnt.image = "packet3"
    end
end)


