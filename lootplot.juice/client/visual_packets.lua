


local MIN_DIST = 10

local TOTAL_LIFETIME = 3
local FLOAT_TIME = 0.16


local function updateEnt(ent)
    local x,y = ent.x, ent.y
    local tx,ty = ent._getTargetPosition()

    ent.friction = 1

    ent.rot = love.timer.getTime() * 60

    local ddx, ddy = tx-x, ty-y
    local dx,dy = math.normalize(tx-x, ty-y)

    local timeTravelled = (TOTAL_LIFETIME - ent.lifetime)
    local accel = ent._accel * math.max(1, timeTravelled * 3)
    if timeTravelled > FLOAT_TIME then
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
        local packetEnt = newPacketEnt(dvec, 200, 200, function()
            return ent.x or 0, ent.y or 0
        end)
        packetEnt.image = ent.image
    end
end)



local function getPacketScale(delta)
    local x = math.abs(delta)
    return math.log(x + 4, 10) / 1.4
end



umg.on("lootplot:pointsChanged", function(ent, delta)
    if lp.isItemEntity(ent) and delta>0 then
        local dvec = {
            x = ent.x, y = ent.y,
            dimension = ent.dimension
        }
        local packetEnt = newPacketEnt(dvec, 400, 450, function()
            local camera = camera.get()
            return camera:toWorldCoords(love.mouse.getPosition())
        end)

        packetEnt.image = "packet0"
        packetEnt.scale = getPacketScale(delta)
    end
end)



umg.on("lootplot:moneyChanged", function(ent, delta)
    if lp.isItemEntity(ent) and delta>0 then
        local dvec = {
            x = ent.x, y = ent.y,
            dimension = ent.dimension
        }
        local packetEnt = newPacketEnt(dvec, 400, 450, function()
            local camera = camera.get()
            return camera:toWorldCoords(love.mouse.getPosition())
        end)

        packetEnt.scale = getPacketScale(delta)
        packetEnt.image = "packet0"
        packetEnt.color = lp.COLORS.MONEY_COLOR
    end
end)


