

local lg = love.graphics


---@class lootplot.s0.backgrounds.CloudBackground: lootplot.backgrounds.IBackground
local CloudBackground = objects.Class("lootplot.s0.backgrounds:CloudBackground"):implement(lp.backgrounds.IBackground)



local NUM_CLOUD_LAYERS = 5
local CLOUDS_PER_LAYER = 35

local BASE_CLOUD_SPEED = 10


---@param baseColor objects.Color
---@return objects.Color[]
local function makeColors(baseColor)
    local arr = objects.Array()

    local h,s,l = baseColor:getHSL()

    local MAX_L = 1
    local MIN_L = l
    local dl = (MAX_L - MIN_L) / NUM_CLOUD_LAYERS

    for i=1, NUM_CLOUD_LAYERS do
        local newL = l + (dl * i)
        arr:add(objects.Color(
            objects.Color.HSLtoRGB(h, s, newL)
        ))
    end

    return arr
end


local BOUNDS = 2000


local POSSIBLE_CLOUD_BITS = objects.Array()
for i=1,5 do
    POSSIBLE_CLOUD_BITS:add("background_cloud_bit_" .. i)
end


local MIN_BITS_PER_CLOUD = 1
local MAX_BITS_PER_CLOUD = 4

local CLOUD_BIT_SEP = 8
local CLOUD_BIT_VARIANCE = 3

local function newCloud(layerIndex)
    local bits = objects.Array()
    local numBits = math.floor(math.random(MIN_BITS_PER_CLOUD, MAX_BITS_PER_CLOUD))

    local d = CLOUD_BIT_VARIANCE
    for i=1, numBits do
        bits:add({
            ox = math.random(-d,d) + i * CLOUD_BIT_SEP,
            oy = math.random(-d,d),
            image = table.random(POSSIBLE_CLOUD_BITS)
        })
    end

    return {
        x = love.math.random(-BOUNDS, BOUNDS),
        y = love.math.random(-BOUNDS, BOUNDS),

        layerIndex = layerIndex,

        bits = bits,
    }
end


local function drawCloud(cloud)
    for _,b in ipairs(cloud.bits) do
        local rot = love.timer.getTime()
        rendering.drawImage(b.image, cloud.x + b.ox, cloud.y + b.oy, rot)
    end
end


local function updateCloud(cloud, dt)
    cloud.x = cloud.x + cloud.layerIndex * BASE_CLOUD_SPEED * dt

    if cloud.x > BOUNDS then
        cloud.x = -BOUNDS
    end
end



---@param baseColor objects.Color
function CloudBackground:init(baseColor)
    self.colors = makeColors(baseColor)

    self.cloudLayers = {--[[
        [layerIndex] -> Array-of-clouds
    ]]}

    for layer=1, NUM_CLOUD_LAYERS do
        local clouds = objects.Array()
        for _=1, #CLOUDS_PER_LAYER do
            clouds:add(newCloud(layer))
        end
        self.cloudLayers[layer] = clouds
    end
end


function CloudBackground:draw(opacity)
    for i, clouds in pairs(self.cloudLayers) do
        lg.setColor(self.colors[i])
        for _, cloud in ipairs(clouds) do
            drawCloud(cloud)
        end
    end
end


---@param dt number
function CloudBackground:update(dt)
    for layerIndex, clouds in pairs(self.cloudLayers) do
        for _, cloud in ipairs(clouds) do
            updateCloud(cloud, dt)
        end
    end
end


return CloudBackground
