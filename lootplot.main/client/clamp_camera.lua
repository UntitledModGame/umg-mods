
---@param pos spatial.DimensionVector
local function posFromDVector(pos)
    return pos.x, pos.y
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
        for _, ent in ipairs(control.getControlledEntities(client.getClient())) do
            local offTX = math.max(topWorldX, xt) - xt
            local offTY = math.max(topWorldY, yt) - yt
            local offBX = xb - math.min(bottomWorldX, xb)
            local offBY = yb - math.min(bottomWorldY, yb)

            ent.x = ent.x + offTX - offBX
            ent.y = ent.y + offTY - offBY
        end
    end
end)
