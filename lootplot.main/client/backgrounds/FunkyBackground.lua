


---@class lootplot.main.FunkyBackground: lootplot.main.Background
local FunkyBackground = objects.Class("lootplot.main:FunkyBackground")



function FunkyBackground:init(args)
    typecheck.assertKeys(args, {
        "color", "noisePeriod", "nodeDistance", "nodeHueShift", "noiseSpeed",
        "worldX", "worldY", "worldWidth", "worldHeight"
    })
    self.color = objects.Color(args.color)
    self.noisePeriod = args.noisePeriod
    self.nodeDistance = args.nodeDistance

    self.nodeHueShift = args.nodeHueShift
    self.nodeSaturationShift = args.nodeSaturationShift
    self.nodeValueShfit = args.nodeValueShfit

    self.noiseSpeed = args.noiseSpeed

    self.worldX = args.worldX
    self.worldY = args.worldY
    self.worldWidth = args.worldWidth
    self.worldHeight = args.worldHeight
end


local CIRC_BULGE = 2.2
local RADIUS_OFFSET = -0.4
local lg=love.graphics

---@param opacity number
function FunkyBackground:draw(opacity)
    local c = self.color
    ---@cast c objects.Color
    local h,s,v = c:getHSV()
    local time = math.sin(love.timer.getTime() * self.noiseSpeed)
    time = time + 13.245
    --[[
    for some reason we gotta offset time by some value, or else
    we get the same noise value everywhere...?
    (Sampling near 0 gives uniform results for some reason, regardless of x,y)
    ]]
    lg.setColor(self.color * opacity)
    lg.rectangle("fill", self.worldX, self.worldY, self.worldWidth, self.worldHeight)
    for x=self.worldX, self.worldWidth, self.nodeDistance do
        for y=self.worldY, self.worldHeight, self.nodeDistance do
            local sampX = ((x-self.worldX) / self.noisePeriod)
            local sampY = ((y-self.worldY) / self.noisePeriod)
            local noise = love.math.simplexNoise(sampX, sampY, time)
            local radius = self.nodeDistance * (noise + RADIUS_OFFSET) * CIRC_BULGE
            if radius > 0 then
                local dh = self.nodeHueShift * noise
                local vh = self.nodeValueShfit * noise
                local sh = self.nodeSaturationShift * noise
                lg.setColor(objects.Color.HSVtoRGB(h+dh, s+sh, v+vh))
                lg.circle("fill", x, y, radius, 6)
            end
        end
    end
end

function FunkyBackground:update()
end

---@param width number
---@param height number
function FunkyBackground:resize(width, height)
end

return FunkyBackground
