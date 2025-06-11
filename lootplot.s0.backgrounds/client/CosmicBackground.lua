---@class lootplot.s0.backgrounds.cosmicBackground
local cosmicBackground = objects.Class("lootplot.s0.backgrounds:cosmicBackground"):implement(lp.backgrounds.IBackground)

local function generateStars(self, rng, args)
    local scale = args.scale or rng:random(3, 8)/10

    local star = {
        x = self.worldX + rng:random() * self.worldWidth,
        y = self.worldY + rng:random() * self.worldHeight,
        rot = rng:random(-314, 314)/100,
        scale = scale,
        layerIndex = args.layerIndex or rng:random(5, 9)/10,
        image = args.type,
        color = args.color,
        colorPulses = args.colorPulses,
    }
    self.glowStars:add(star)
end


local function getColor(rng, args)
    return {rng:random(args.starColorMin[1], 10)/10, rng:random(args.starColorMin[2], 10)/10, rng:random(args.starColorMin[3], 10)/10}
end


function cosmicBackground:init(args)
    self.glowStars = objects.Array()

    local cam = camera.get()
    self.initialCamX, self.initialCamY = cam:getPos()

    self.backgroundColor = args.backgroundColor
    self.worldX = args.worldX
    self.worldY = args.worldY
    self.worldWidth = args.worldWidth
    self.worldHeight = args.worldHeight

    local rng = love.math.newRandomGenerator(love.math.getRandomSeed())

    
    for i=1, args.numberOfStar*3 do
        generateStars(self, rng, {
            type="shine_128", layerIndex = 0.4, scale = rng:random(10, 35)/10,
        color=getColor(rng,args)})
    end

    for i=1, args.numberOfStar*20 do
        generateStars(self, rng, {type="glow_8",
        color=getColor(rng,args)})
    end

    for i=1, args.numberOfStar*40 do
        generateStars(self, rng, {type="shine_8",
        color=getColor(rng,args)})
    end

    for i=1, args.numberOfStar do
        generateStars(self, rng, {type="glow_128", scale = (rng:random(2, 7)/10)^2+0.2,
        color=getColor(rng,args)})
    end
    
    for i=1, args.numberOfStar*5 do
        generateStars(self, rng, {type="sparkle_16", colorPulses = true,
        color=getColor(rng,args)})
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

    local STAR_SPEED = 1.2
    star.x = star.x - star.layerIndex * STAR_SPEED * dt
    star.y = star.y - star.layerIndex * STAR_SPEED * dt
end



function cosmicBackground:update(dt)
    for _, star in ipairs(self.glowStars)do
        updateStar(self, star, dt)
    end
end



local lg = love.graphics


local function drawGlowStars(self, star, cx, cy)
    lg.setColor(star.color)
    rendering.drawImage(star.image, 
        star.x+(cx/3*(star.layerIndex^2)), 
        star.y+(cy/3*(star.layerIndex^2)),
        star.rot, star.scale, star.scale
    )
end


---@param opacity number
function cosmicBackground:draw(opacity)
    love.graphics.setColor(self.backgroundColor * opacity)
    love.graphics.rectangle("fill", self.worldX, self.worldY, self.worldWidth, self.worldHeight)

    local cam = camera.get()
    local cx, cy = cam:getPos()
    cx = cx - self.initialCamX
    cy = cy - self.initialCamY
    for _, star in ipairs(self.glowStars) do
        drawGlowStars(self, star, cx, cy)
    end
end

return cosmicBackground
