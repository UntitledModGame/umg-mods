local hoverables = {}

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

local function inRange(ent, x, y)
    if hitboxes.hasHitbox(ent) then
        return hitboxes.isHit(ent, x, y)
    else
        return math.sqrt((ent.x - x) ^ 2 + (ent.y - y) ^ 2) <= DEFAULT_HOVERABLE_DISTANCE
    end
end

local function tryStartHover(ent)
    if not hoveredEntities:has(ent) then
        hoveredEntities:add(ent)
        umg.call("hoverables:startHover", ent)
    end
end

local function tryEndHover(ent, worldX, worldY)
    if not inRange(ent, worldX, worldY) then
        hoveredEntities:remove(ent)
        umg.call("hoverables:endHover", ent)
    end
end

local listener = input.InputListener({priority = 0})
listener:onPointerMoved(function(l, x, y)
    local currentCamera = camera.get()
    local worldX, worldY = currentCamera:toWorldCoords(x, y)
    local dvec = currentCamera:getDimensionVector()

    for _, ent in hoverEntPartition:iterator(dvec) do
        if inRange(ent, worldX, worldY) then
            tryStartHover(ent)
        end
    end

    for _, ent in ipairs(hoveredEntities) do
        tryEndHover(ent, worldX, worldY)
    end
end)

---Check if the specified entity in being hovered by the pointer right now.
---@param ent Entity
---@return boolean
function hoverables.isHovered(ent)
    return hoveredEntities:has(ent)
end

---Get list of entities currently behing hovered by the pointer.
---@return objects.Array entities List of entities.
function hoverables.getHoveredEntities()
    local result = objects.Array()

    for _, ent in ipairs(hoveredEntities) do
        result:add(ent)
    end

    return result
end

return hoverables
