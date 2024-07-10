local hoverEnts = umg.group("x", "y", "hoverable")
local hoveredEntities = objects.Set()

-- pretty arbitrary size, lol
local hoverEntPartition = spatial.DimensionPartition(200)

hoverEnts:onAdded(function(ent)
    hoverEntPartition:addEntity(ent)
end)
hoverEnts:onRemoved(function(ent)
    hoverEntPartition:removeEntity(ent)
end)

-- TODO: put scheduler here for efficiency.
umg.on("@update", function()
    for _, ent in ipairs(hoverEnts) do
        hoverEntPartition:updateEntity(ent)
    end
end)

local DEFAULT_HOVERABLE_DISTANCE = 30

local function inRange(ent, dist)
    return (ent.hoverableDistance or DEFAULT_HOVERABLE_DISTANCE) >= dist
end

local function tryStartHover(ent)
    if not hoveredEntities:has(ent) then
        hoveredEntities:add(ent)
        umg.call("hoverables:startHover", ent)
    end
end

local function tryEndHover(ent, worldX, worldY)
    local drawX, drawY = ent.x, rendering.getDrawY(ent.y, ent.z)
    local dist = math.distance(drawX - worldX, drawY - worldY)
    if not inRange(ent, dist) then
        hoveredEntities:remove(ent)
        umg.call("hoverables:endHover", ent)
    end
end

local listener = input.InputListener({priority = 0})
listener:onPointerMoved(function(l, x, y)
    local currentCamera = rendering.getCamera()
    local worldX, worldY = rendering.toWorldCoords(x, y)
    local dvec = currentCamera:getDimensionVector()

    for _, ent in hoverEntPartition:iterator(dvec) do
        local drawX, drawY = ent.x, rendering.getDrawY(ent.y, ent.z)
        local dist = math.distance(drawX - worldX, drawY - worldY)
        if inRange(ent, dist) then
            tryStartHover(ent)
        end
    end

    for _, ent in ipairs(hoveredEntities) do
        tryEndHover(ent, worldX, worldY)
    end
end)
