---@class lootplot.s0.backgrounds.cosmicBackground
local cosmicBackground = objects.Class("lootplot.s0.backgrounds:cosmicBackground"):implement(lp.backgrounds.IBackground)

local function generateStars(self, rng, args)
    local size = args.size or rng:random(3, 8)/10

    local star = {
        x = self.worldX + rng:random() * self.worldWidth,
        y = self.worldY + rng:random() * self.worldHeight,
        rot = rng:random(-314, 314)/100,
        size = size,
        layerIndex = args.layerIndex or rng:random(5, 9)/10,
        image = args.type,
        color = args.color,
        colorPulses = args.colorPulses,
    }
    self.glowStars:add(star)
end

function cosmicBackground:init(args)
    self.glowStars = objects.Array()

    self.backgroundColor = args.backgroundColor
    self.worldX = args.worldX
    self.worldY = args.worldY
    self.worldWidth = args.worldWidth
    self.worldHeight = args.worldHeight

    local rng = love.math.newRandomGenerator(love.math.getRandomSeed())

    
    for i=1, args.numberOfStar/2 do
        generateStars(self, rng, {type="shine_512", layerIndex = 0.4, size = rng:random(8, 12)/10,
        color={rng:random(args.starColorMin[1], 10)/10, rng:random(args.starColorMin[2], 10)/10, rng:random(args.starColorMin[3], 10)/10}})
    end

    for i=1, args.numberOfStar*50 do
        generateStars(self, rng, {type="glow_8",
        color={rng:random(args.starColorMin[1], 10)/10, rng:random(args.starColorMin[2], 10)/10, rng:random(args.starColorMin[3], 10)/10}})
    end

    for i=1, args.numberOfStar*70 do
        generateStars(self, rng, {type="shine_8",
        color={rng:random(args.starColorMin[1], 10)/10, rng:random(args.starColorMin[2], 10)/10, rng:random(args.starColorMin[3], 10)/10}})
    end

    for i=1, args.numberOfStar do
        generateStars(self, rng, {type="glow_128", size = (rng:random(2, 7)/10)^2+0.2,
        color={rng:random(args.starColorMin[1], 10)/10, rng:random(args.starColorMin[2], 10)/10, rng:random(args.starColorMin[3], 10)/10}})
    end
    
    for i=1, args.numberOfStar*5 do
        generateStars(self, rng, {type="sparkle_32", colorPulses = true,
        color={rng:random(args.starColorMin[1], 10)/10, rng:random(args.starColorMin[2], 10)/10, rng:random(args.starColorMin[3], 10)/10}})
    end

    table.sort(self.glowStars, function (a, b)
        return a.layerIndex < b.layerIndex
    end)
end


local function distToHorizontalEdge(self, star)
    local center = self.worldX + self.worldWidth/2
    local distFromCenter = math.abs(center - star.x)
    local distToEdge = self.worldWidth/2 - distFromCenter
    return distToEdge
end

local function distToVerticalEdge(self, star)
    local center = self.worldY + self.worldHeight/2
    local distFromCenter = math.abs(center - star.y)
    local distToEdge = self.worldHeight/2 - distFromCenter
    return distToEdge
end

local function updateStar(self, star, dt)
    if distToHorizontalEdge(self, star) < -10 then
        star.x = self.worldX+self.worldWidth + 5
    end
    if distToVerticalEdge(self, star) < -10 then
        star.y = self.worldY+self.worldHeight + 5
    end
    star.x = star.x - star.layerIndex * 10 * dt
    star.y = star.y - star.layerIndex * 10 * dt

    if star.colorPulses == true then
        local rng = love.math.newRandomGenerator(love.math.getRandomSeed())

        if star.originalColor == nil then
            star.originalColor = {}
            for i, c in ipairs(star.color) do
                star.originalColor[i] = c
            end
            star.isPulsing = true
            star.pulseAmount = rng:random(1, 5)/10
        end

        if star.isPulsing then
            star.pulseAmount = star.pulseAmount + rng:random(7, 10)/100*dt
            if star.pulseAmount > 0.5 then
                star.isPulsing = false
            end
        else
            star.pulseAmount = star.pulseAmount - rng:random(7, 10)/100*dt
            if star.pulseAmount < 0 then
                star.isPulsing = true
            end
        end
        
        star.color = {star.originalColor[1]+star.pulseAmount/2, star.originalColor[2]+star.pulseAmount/2, star.originalColor[3]+star.pulseAmount/2}
    end
end


function cosmicBackground:update(dt)
    for _, star in ipairs(self.glowStars)do
        updateStar(self, star, dt)
    end
end



local lg = love.graphics
local camCenterX = 780
local camCenterY = 520

local function drawGlowStars(self, star)
    lg.setColor(star.color)
    local cam = camera.get()
    local cx, cy = cam:getPos()
    cx = cx - camCenterX
    cy = cy - camCenterY
    rendering.drawImage(star.image, star.x+(cx/3*(star.layerIndex^2)), star.y+(cy/3*(star.layerIndex^2)), star.rot, star.size, star.size)
end


---@param opacity number
function cosmicBackground:draw(opacity)
    love.graphics.setColor(self.backgroundColor * opacity)
    love.graphics.rectangle("fill", self.worldX, self.worldY, self.worldWidth, self.worldHeight)
    for _, star in ipairs(self.glowStars) do
        drawGlowStars(self, star)
    end
end

return cosmicBackground
