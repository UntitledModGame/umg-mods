---@param ppos lootplot.PPos
---@param x integer
---@param y integer
local function offsetPPosBy(ppos, x, y)
    return ppos:move(x, y) or ppos:move(x, 0) or ppos:move(0, y) or ppos
end

---@param plot lootplot.Plot
---@param camera camera.Camera
local function getPPosByScreenCoords(plot, camera, sx, sy)
    local wx, wy = camera:toWorldCoords(sx, sy)
    return plot:getClosestPPos(wx, wy)
end

---@param ... lootplot.PPos
local function computeBoundingBox(...)
    local x1, y1, x2, y2 = math.huge, math.huge, -math.huge, -math.huge
    for i = 1, select("#", ...) do
        ---@type lootplot.PPos
        local ppos = select(i, ...)
        local x, y = ppos:getCoords()
        x1 = math.min(x, x1)
        y1 = math.min(y, y1)
        x2 = math.max(x, x2)
        y2 = math.max(y, y2)
    end

    return x1, y1, x2, y2
end

local lastCamera = nil

---@param ppos lootplot.PPos
local function drawFog(ppos)
    if not lastCamera then return end

    local wpos = ppos:getWorldPos()
    love.graphics.circle("fill", wpos.x, wpos.y, 10)
end

---@param camera camera.Camera
umg.on("rendering:drawEffects", function(camera)
    local run = lp.main.getRun()
    if not run then return end

    -- Get plot foreach area
    local plot = run:getPlot()
    local w, h = love.graphics.getDimensions()
    local pposTL = offsetPPosBy(getPPosByScreenCoords(plot, camera, 0, 0), -1, -1)
    local pposTR = offsetPPosBy(getPPosByScreenCoords(plot, camera, w, 0), 1, -1)
    local pposBR = offsetPPosBy(getPPosByScreenCoords(plot, camera, w, h), 1, 1)
    local pposBL = offsetPPosBy(getPPosByScreenCoords(plot, camera, 0, h), -1, 1)
    local x1, y1, x2, y2 = computeBoundingBox(pposTL, pposTR, pposBR, pposBL)

    lastCamera = camera
    love.graphics.setColor(0, 0, 0)
    plot:foreachInArea(x1, y1, x2, y2, drawFog)
end)
