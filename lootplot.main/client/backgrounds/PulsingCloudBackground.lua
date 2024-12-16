
---@class lootplot.main.PulsingCloudBackground: lootplot.backgrounds.IBackground
local PulsingCloudBackground = objects.Class("lootplot.main:PulsingCloudBackground"):implement(lp.backgrounds.IBackground)



--- CONSTANTS:
local CLOUD_MOVE_SPEED = 3.5

local CLOUD_SIZE = 1.5

local CLOUD_BLOB_PULSE_SPEED = 0.6

local BACKGROUND_COLOR = objects.Color("#FF8FA1FF") -- sky
local CLOUD_COLOR_LEVEL = {
    objects.Color("#FF94A3FF"),  -- bottom cloud 2
    objects.Color("#FF94A3FF"),  -- bottom cloud
    objects.Color("#FFA8B5FF"), -- mid2 cloud
    objects.Color("#FFBDC6FF"), -- mid1 cloud
    -- objects.Color("#FFD1D8FF"), -- top cloud
}




local function generateCloudBlobs(rng, size)
    local BASE_BLOB_SIZE = 1 -- higher = blobs are similar sizes
    local CLUMP_FACTOR = 1.5 -- higher = more clumped

    local blobs = objects.Array()
    local numBlobs = rng:random(4,7)
    for x=-numBlobs/2, numBlobs/2 do
        blobs:add({
            size = size * (BASE_BLOB_SIZE + (1 - math.abs(x)/(numBlobs/2))),
            x = x/CLUMP_FACTOR * size,
            y = ((rng:random() - 0.5) * 2) * size * 0.7/CLUMP_FACTOR
        })
    end
    return blobs
end


---@param rng love.RandomGenerator
local function newCloud(self, rng)
    local cloud = {
        x = self.worldX + rng:random() * self.worldWidth,
        y = self.worldY + rng:random() * self.worldHeight,
        level = rng:random(1,#CLOUD_COLOR_LEVEL),
    }
    cloud.blobs = generateCloudBlobs(rng, self.cloudSize / ((3+cloud.level) / 3))
    cloud.speed = cloud.level * CLOUD_MOVE_SPEED
    self.clouds:add(cloud)
end


function PulsingCloudBackground:init(args)
    typecheck.assertKeys(args, {
        "numberOfClouds", "worldX", "worldY", "worldWidth", "worldHeight"
    })
    self.clouds = objects.Array()

    self.worldX = args.worldX
    self.worldY = args.worldY
    self.worldWidth = args.worldWidth
    self.worldHeight = args.worldHeight
    self.cloudSize = self.worldWidth / 50 * CLOUD_SIZE

    local rng = love.math.newRandomGenerator(love.math.getRandomSeed())
    for _=1, args.numberOfClouds do
        newCloud(self, rng)
    end
    table.sort(self.clouds, function(a, b)
        return a.level < b.level
    end)
end


local function distToHorizontalEdge(self, cloud)
    local center = self.worldX + self.worldWidth/2
    local distFromCenter = math.abs(center - cloud.x)
    local distToEdge = self.worldWidth/2 - distFromCenter
    return distToEdge
end


local function updateCloud(self, cloud, dt)
    local d = distToHorizontalEdge(self, cloud)
    if d < -10 then
        cloud.x = self.worldX - 5
    end
    cloud.x = cloud.x + cloud.speed * dt
end


---@param dt number
function PulsingCloudBackground:update(dt)
    for _, c in ipairs(self.clouds)do
        updateCloud(self, c, dt)
    end
end



local lg = love.graphics
local function drawCloud(self, cloud, opacity)
    lg.setColor(CLOUD_COLOR_LEVEL[cloud.level])
    for i, b in ipairs(cloud.blobs) do
        local x,y = cloud.x + b.x, cloud.y + b.y
        local s = b.size
        lg.push()
        lg.translate(x+s/2,y+s/2)
        local offset = i % 2 == 0 and 1.44343 or -0.3
        local time = love.timer.getTime() * CLOUD_BLOB_PULSE_SPEED
        local dr = 0.2 * (s/2) * (1 + math.sin(time + offset)) / 2
        lg.circle("fill", -s/2, -s/2, s/2 + dr)
        -- lg.rectangle("fill", -s/2,-s/2,s,s)
        lg.pop()
    end
end



---@param opacity number
function PulsingCloudBackground:draw(opacity)
    love.graphics.setColor(BACKGROUND_COLOR * opacity)
    love.graphics.rectangle("fill", self.worldX, self.worldY, self.worldWidth, self.worldHeight)
    for _,c in ipairs(self.clouds) do
        drawCloud(self, c, opacity)
    end
end

---@param width number
---@param height number
function PulsingCloudBackground:resize(width, height)
end

return PulsingCloudBackground
