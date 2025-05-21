


local MIN_DIST = 10

local TOTAL_LIFETIME = 3
local FLOAT_TIME = 0.16


local function updateEnt(ent)
    local x,y = ent.x, ent.y
    local tx,ty = ent._getTargetPosition()

    ent.friction = 1

    local rotSlow = math.min(1.5, (ent.scale or 1))
    ent.rot = love.timer.getTime() * 40 / rotSlow

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
        if ent._onDeleted then
            ent:_onDeleted()
        end
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



local function getPacketScale(delta)
    local x = math.abs(delta)
    -- try experimenting with https://onecompiler.com/lua
    -- these numbers are all NOOMA
    local DIV = 5
    return 1 + (math.log(x, 10) / DIV) - (1/DIV)
end




local currentTick = 0
umg.on("@tick", function()
    currentTick = currentTick + 1
end)

--- A special `on` function that only applies a maximum of ONCE per tick.
--- Useful for sound effects and popup-visuals
---@param event string
---@param func fun(...): boolean
local function limitedOn(event, func)
    local lastTick = 0

    umg.on(event, function(a,b,c,d,e)
        if currentTick == lastTick then
            -- we have already activated this tick!!!
            return -- exit early.
        end
        local triggered = func(a,b,c,d,e)
        if triggered then
            lastTick = currentTick
        end
    end)
end





limitedOn("lootplot:pointsChanged", function(ent, delta)
    if delta>0 then
        local dvec = {
            x = ent.x, y = ent.y,
            dimension = ent.dimension
        }
        local packetEnt = newPacketEnt(dvec, 400, 450, function()
            local camera = camera.get()
            return camera:toWorldCoords(love.mouse.getPosition())
        end)

        packetEnt.image = "packet1"
        packetEnt.color = lp.COLORS.POINTS_COLOR
        packetEnt.scale = getPacketScale(delta)
        return true
    end
    return false
end)



limitedOn("lootplot:multChanged", function(ent, delta)
    if delta>0 then
        local dvec = {
            x = ent.x, y = ent.y,
            dimension = ent.dimension
        }
        local packetEnt = newPacketEnt(dvec, 400, 450, function()
            local camera = camera.get()
            return camera:toWorldCoords(love.mouse.getPosition())
        end)

        packetEnt.image = "packet1"
        packetEnt.color = lp.COLORS.POINTS_MULT_COLOR
        packetEnt.scale = getPacketScale(delta)
        return true
    end
    return false
end)





local dirObj = umg.getModFilesystem()
audio.defineAudioInDirectory(
    dirObj:cloneWithSubpath("assets/sfx"), {"audio:sfx"}, "lootplot.juice:"
)


local COIN_SPIN_SPEED = 4
local MAX_COINS_SPAWN_COUNT = 8

local function spawnMoneyPacket(ent)
    local dvec = {
        x = ent.x, y = ent.y,
        dimension = ent.dimension
    }
    local packetEnt = newPacketEnt(dvec, 500, 350, function()
        local camera = camera.get()
        return camera:toWorldCoords(love.mouse.getPosition())
    end)

    packetEnt.scale = 1
    packetEnt.image = "money_packet"
    packetEnt.color = lp.COLORS.MONEY_COLOR
    packetEnt._onDeleted = function(e)
        audio.play("lootplot.juice:collect_money", {
            pitch = 0.8,
            volume = 0.15
        })
    end

    packetEnt.onUpdateClient = function(e1)
        e1.scaleX = math.sin(love.timer.getTime() * COIN_SPIN_SPEED)
    end
end

limitedOn("lootplot:moneyChanged", function(ent, delta)
    if delta>0 then
        delta = math.min(delta, MAX_COINS_SPAWN_COUNT)
        for i=1, delta do
            spawnMoneyPacket(ent)
        end
        return true
    end
    return false
end)




limitedOn("lootplot:entityBuffed", function(ent, prop, amount, srcEnt)
    if srcEnt then
         local dvec = {
            x = srcEnt.x, y = srcEnt.y,
            dimension = ent.dimension
        }
        local SPD = 250
        local packetEnt = newPacketEnt(dvec, 0, 250, function()
            return ent.x, ent.y
        end)
        packetEnt.vx = (math.random()-0.5)*(SPD/2)
        packetEnt.vy = -SPD

        packetEnt.image = "buff_packet"
        return true
    end
    return false
end)

