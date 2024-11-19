
---@param pos spatial.DimensionVector
local function posFromDVector(pos)
    return pos.x, pos.y
end

local function clampByMinMax(value, minV, maxV)
    if value < minV then
        if value > maxV then
            return (minV + maxV) / 2
        else
            return minV
        end
    else
        return math.min(value, maxV)
    end
end

umg.on("@update", function()
    local run = lp.main.getRun()
    if run then
        local plot = run:getPlot()
        local topPPos = plot:getPPos(0, 0)
        local bottomPPos = plot:getPPos(
            lp.main.constants.WORLD_PLOT_SIZE - 1,
            lp.main.constants.WORLD_PLOT_SIZE - 1
        )

        local topWorldX, topWorldY = posFromDVector(topPPos:getWorldPos())
        local bottomWorldX, bottomWorldY = posFromDVector(bottomPPos:getWorldPos())
        topWorldX = topWorldX - lp.constants.WORLD_SLOT_DISTANCE / 2
        topWorldY = topWorldY - lp.constants.WORLD_SLOT_DISTANCE / 2
        bottomWorldX = bottomWorldX + lp.constants.WORLD_SLOT_DISTANCE / 2
        bottomWorldY = bottomWorldY + lp.constants.WORLD_SLOT_DISTANCE / 2

        local cam = camera.get()
        local xt, yt = cam:toWorldCoords(0, 0)
        local xb, yb = cam:toWorldCoords(love.graphics.getDimensions())
        local horzDist = (xb - xt) / 2
        local vertDist = (yb - yt) / 2
        for _, ent in ipairs(control.getControlledEntities(client.getClient())) do
            local minX = topWorldX + horzDist
            local minY = topWorldY + vertDist
            local maxX = bottomWorldX - horzDist
            local maxY = bottomWorldY - vertDist
            ent.x = clampByMinMax(ent.x, minX, maxX)
            ent.y = clampByMinMax(ent.y, minY, maxY)
        end
    end
end)
