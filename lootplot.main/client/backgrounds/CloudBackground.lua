local Background = require("client.Background")

---@class lootplot.main.CloudBackground: lootplot.main.Background
local CloudBackground = objects.Class("lootplot.main:CloudBackground"):implement(Background)

function CloudBackground:init()
    ---@type love.Texture[]
    self.cloudCanvases = {}
    self.cloudInstance = {}
    self.directionAngle = 0
    self.timeUntilDirectionChange = 0
    self.changeOfDirectionAngle = 0
    self.rng = love.math.newRandomGenerator(12345, 67890)
    self.parallaxDistance = 25
end

if false then
    ---@return lootplot.main.CloudBackground
    ---@diagnostic disable-next-line: cast-local-type, missing-return
    function CloudBackground() end
end

---@param rng love.RandomGenerator
---@param ratio number
---@private
function CloudBackground.makeCanvasForTopDown(rng, ratio)
    local width = 50 + rng:random() * 100

    -- Make sure dimensions is divisible by 4
    width = math.ceil(width / 4) * 4
    local height = math.ceil(width / ratio / 4) * 4

    return love.graphics.newCanvas(width, height, {dpiscale = 1})
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
local function distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

---@private
function CloudBackground.getScale(cloudtype)
    return (1 + (4 - cloudtype) / 4) * 2.5
end

---@param rng love.RandomGenerator
---@param canvas love.Texture must be created for offscreen rendering
---@private
function CloudBackground.bakeTopDownClouds(rng, canvas)
    local JITTER = 10
    local ELLIPSE_RATIO = 2
    local CIRCLES = 20
	local TAU = 2 * math.pi

    local width, height = canvas:getDimensions()
    local cx, cy = width / 2, height / 2
    local widthForEllipse = cx / ELLIPSE_RATIO
    local heightForEllipse = cy / ELLIPSE_RATIO

	local radialAngles = {}
	for i = 1, CIRCLES do
		local angle = ((i + rng:random()) * TAU / CIRCLES ) % TAU
		radialAngles[#radialAngles+1] = angle
	end

	table.sort(radialAngles)

	local points = {}

	for _, angle in ipairs(radialAngles) do
		local x = math.cos(angle) * widthForEllipse + (rng:random() * 2 - 1) * JITTER
		local y = math.sin(angle) * heightForEllipse + (rng:random() * 2 - 1) * JITTER
		points[#points+1] = {x + cx, y + cy}
	end

    local circles = {}
    local pointsForLine = {}

	for i, p in ipairs(points) do
		local p_min_1 = points[(i - 2) % #points + 1]
		local p_pls_1 = points[i % #points + 1]
		local minCircleRadius = math.max(
			distance(p[1], p[2], p_min_1[1], p_min_1[2]),
			distance(p[1], p[2], p_pls_1[1], p_pls_1[2])
		)
        local maxCircleRadius = math.min(
            math.min(p[1], width - p[1]),
            math.min(p[2], height - p[2])
        )
        local circleRadius = math.min(minCircleRadius, maxCircleRadius)
		circles[#circles+1] = {p[1], p[2], circleRadius}
		pointsForLine[#pointsForLine+1] = p[1]
		pointsForLine[#pointsForLine+1] = p[2]
	end

    -- Note to self and others:
    -- The primitive drawing only draws either opaque or transparent pixel.
    -- Since there's no semi-transparent pixels in this canvas, it's fine
    -- to draw the canvas using straight alpha instead of premultiplied alpha.
    love.graphics.push("all")
    love.graphics.reset()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(1, 1, 1, 0)

    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon("fill", pointsForLine)

    for _, c in ipairs(circles) do
        love.graphics.circle("fill", c[1], c[2], c[3])
    end

    -- debug
    -- love.graphics.setColor(1, 0, 0)
    -- love.graphics.line(pointsForLine)

    love.graphics.pop()
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param boundingBox number
---@private
function CloudBackground.isCloudInArea(x, y, width, height, boundingBox)
    local x1 = -boundingBox * 1.5
    local y1 = -boundingBox * 1.5
    local x2 = width + boundingBox * 1.5
    local y2 = height + boundingBox * 1.5
    return x >= x1 and y >= y1 and x <= x2 and y <= y2
end

local function makeAngleSigned(angle)
    angle = angle % 360
    return angle > 180 and 360 - angle or angle
end

---@param t table
---@param width number
---@param height number
---@param outside boolean
---@private
function CloudBackground:setupTableForTopDown(t, width, height, outside)
    t.texture = self.cloudCanvases[self.rng:random(#self.cloudCanvases)]
    t.type = self.rng:random(1, 4) -- 1 = top, 2 = mid1, 3 = mid2, 4 = bottom

    local boundingBox = math.max(t.texture:getDimensions()) * CloudBackground.getScale(t.type)
    local minPos = -boundingBox * 1.5
    local maxWidth = width + boundingBox * 1.5
    local maxHeight = height + boundingBox * 1.5

    if outside then
        -- Spawn the clouds outside the screen
        local x, y
        local halfBB = boundingBox / 2
        local minPos2 = -halfBB - self.parallaxDistance
        repeat
            x = self.rng:random() * (maxWidth - minPos) + minPos
            y = self.rng:random() * (maxHeight - minPos) + minPos
            local posCond = not (
                (x >= minPos2 and x < (width + halfBB + self.parallaxDistance)) and
                (y >= minPos2 and y < (height + halfBB + self.parallaxDistance))
            )
        until posCond and math.abs(makeAngleSigned(math.deg(math.atan2(height / 2 - y, width / 2 - x) - self.directionAngle))) <= 90
        t.x = x
        t.y = y
    else
        t.x = self.rng:random() * (maxWidth - minPos) + minPos
        t.y = self.rng:random() * (maxHeight - minPos) + minPos
    end
    t.flipX = self.rng:random(0, 1) * 2 - 1
    t.flipY = self.rng:random(0, 1) * 2 - 1
    t.rotate = self.rng:random(0, 3) -- in 90 degree increments
    t.speed = (5 - t.type) * 5
    t.speed = t.speed + (self.rng:random() * 2 - 1) * 0.1 * t.speed

    -- Compute direction deviation
    local value = self.rng:random() * 2 - 1
    local deviation = value ^ 3
    t.directionDeviation = deviation * math.pi / 4
end

---@private
function CloudBackground:setup()
    local CLOUD_VARIATION = 10
    local CLOUD_INSTANCES = 100

    local width, height = love.graphics.getDimensions()

    for _ = 1, CLOUD_VARIATION do
        local canvas = CloudBackground.makeCanvasForTopDown(self.rng, 1 + self.rng:random())
        canvas:setFilter("nearest", "nearest")
        CloudBackground.bakeTopDownClouds(self.rng, canvas)
        self.cloudCanvases[#self.cloudCanvases+1] = canvas
    end

    for _ = 1, CLOUD_INSTANCES do
        local t = {}
        self:setupTableForTopDown(t, width, height, false)
        self.cloudInstance[#self.cloudInstance+1] = t
    end
end

---@private
function CloudBackground.sortTopDownLayer(a, b)
    return a.type > b.type
end

function CloudBackground:update(dt)
    if #self.cloudCanvases == 0 then
        self:setup()
    end

    if self.timeUntilDirectionChange <= 0 then
        local MIN_CHANGE_TIME = 60
        local MAX_CHANGE_TIME = 500

        local value = self.rng:random() * 2 - 1
        local angleChange = (value ^ 3) * math.pi
        local duration = MIN_CHANGE_TIME + self.rng:random() * (MAX_CHANGE_TIME - MIN_CHANGE_TIME)
        self.changeOfDirectionAngle = angleChange / duration
        self.timeUntilDirectionChange = duration
    end
    self.timeUntilDirectionChange = self.timeUntilDirectionChange - dt
    self.directionAngle = (self.directionAngle + self.changeOfDirectionAngle * dt) % (2 * math.pi)

    local width, height = love.graphics.getDimensions()

    for _, inst in ipairs(self.cloudInstance) do
        local angle = self.directionAngle + inst.directionDeviation
        local d = inst.speed * dt
        local dx = math.cos(angle) * d
        local dy = math.sin(angle) * d

        inst.x = inst.x + dx
        inst.y = inst.y + dy

        local boundingBox = math.max(inst.texture:getDimensions()) * CloudBackground.getScale(inst.type)
        if not CloudBackground.isCloudInArea(inst.x, inst.y, width, height, boundingBox) then
            -- Rebuild clouds
            self:setupTableForTopDown(inst, width, height, true)
        end
    end
end

local BACKGROUND_COLOR = objects.Color("#FF7F91FF") -- sky
local CLOUD_COLOR_LEVEL = {
    objects.Color("#FFD1D8FF"), -- top cloud
    objects.Color("#FFBDC6FF"), -- mid1 cloud
    objects.Color("#FFA8B5FF"), -- mid2 cloud
    objects.Color("#FF94A3FF")  -- bottom cloud
}

function CloudBackground:draw(opacity)
    local width, height = love.graphics.getDimensions()
    local colorOpacity = objects.Color(1, 1, 1, opacity)

    love.graphics.setColor(BACKGROUND_COLOR * colorOpacity)
    love.graphics.rectangle("fill", 0, 0, width, height)

    table.sort(self.cloudInstance, CloudBackground.sortTopDownLayer)

    -- Compute parallax
    local cx, cy = width / 2, height / 2
    local mx, my = input.getPointerPosition()
    local px = (cx - mx) * self.parallaxDistance / cx
    local py = (cy - my) * self.parallaxDistance / cy

    -- Draw clouds
    for _, inst in ipairs(self.cloudInstance) do
        local tx, ty = inst.texture:getDimensions()
        local scale = CloudBackground.getScale(inst.type)
        love.graphics.setColor(CLOUD_COLOR_LEVEL[inst.type] * colorOpacity)
        love.graphics.draw(
            inst.texture,
            inst.x + px / inst.type, inst.y + py / inst.type,
            inst.rotate * math.pi / 2,
            scale * inst.flipX,
            scale * inst.flipY,
            tx / 2, ty / 2
        )
    end
end

function CloudBackground:resize(width, height)
    -- Rebuild every clouds
    for _, inst in ipairs(self.cloudInstance) do
        -- Rebuild clouds
        self:setupTableForTopDown(inst, width, height, false)
    end
end

return CloudBackground
