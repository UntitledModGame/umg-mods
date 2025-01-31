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


local ROT_AMOUNT = 0.1 * math.pi
local ROT_SPEED = 0.5

local NUM_CLOUDS = 3
local FOG_CLOUDS = {}
for i=1, NUM_CLOUDS do
    FOG_CLOUDS[i] = "fog_of_war_cloud" .. i
end

---@param ppos lootplot.PPos
local function drawFog(ppos)
    local plot = ppos:getPlot()
    if not plot:isFogRevealed(ppos, lp.main.PLAYER_TEAM) then
        local x,y,_dim = plot:pposToWorldCoords(ppos)
        local i = ppos:getSlotIndex()
        local img = FOG_CLOUDS[(i % NUM_CLOUDS) + 1]
        local a,b = math.floor(i / 2), i
        local flipX, flipY = a%2 == 0, b%2 == 0
        local sx = flipX and -1 or 1
        local sy = flipY and -1 or 1
        local rot = ROT_AMOUNT * math.sin(ROT_SPEED * love.timer.getTime() + i*1.345)
        rendering.drawImage(img, x, y, rot, sx,sy)
    end
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

    -- set fog color
    local background = run:getBackground()
    local bg = lp.backgrounds.getBackgroundInfo(background)
    ---@cast bg lootplot.backgrounds.BackgroundInfoData
    local fogCol = (bg and bg.fogColor) or objects.Color.WHITE
    love.graphics.setColor(fogCol)

    -- draw fog
    plot:foreachInArea(x1, y1, x2, y2, drawFog)
end)

umg.answer("rendering:isHidden", function(ent)
    -- Test if it's behind fog
    local ppos = lp.getPos(ent)
    if not ppos then
        return false -- no PPos, delegate it to other
    end

    local plot = ppos:getPlot()
    return not plot:isFogRevealed(ppos, lp.main.PLAYER_TEAM)
end)
