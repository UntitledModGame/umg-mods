

-- a Set for all shockwave objects that are being drawn
local shockwaveSet = objects.Set()



local DEFAULT_THICKNESS = 4

local DEFAULT_START_RADIUS = 10
local DEFAULT_END_RADIUS = 100

local DEFAULT_DURATION = 0.15


local DEFAULT_TYPE = "line"


local dvecTc = typecheck.assert("dvector")

local Color = objects.Color


local function setDefaultValues(sw)
    dvecTc(sw)

    sw.color = Color(sw.color or Color.WHITE)
    sw.endColor = Color(sw.endColor or sw.color)

    sw.thickness = sw.thickness or DEFAULT_THICKNESS
    sw.startRadius = sw.startRadius or DEFAULT_START_RADIUS
    sw.endRadius = sw.endRadius or DEFAULT_END_RADIUS
    sw.duration = sw.duration or DEFAULT_DURATION
    sw.type = sw.type or DEFAULT_TYPE
    assert(sw.type == "fill" or sw.type == "line", "shockwave type must be fill or line")
    
    sw.radius = sw.startRadius
    sw.dr = (sw.endRadius - sw.startRadius) / sw.duration
    return sw
end


function update(self, dt)
    self.radius = self.radius + (self.dr * dt)
    if self.dr < 0 then
        -- then the radius is running backwards
        if self.radius < self.endRadius then
            self.isFinished = true
        end
    else
        if self.radius > self.endRadius then
            self.isFinished = true
        end
    end
end





local setLineWidth = love.graphics.setLineWidth
local setColour = love.graphics.setColor

function draw(self)
    local lineThickness = self.thickness
    local tick = (self.radius-self.startRadius)/(self.endRadius-self.startRadius)
    local dSign = self.dr / math.abs(self.dr)
    local color = self.color:lerp(self.endColor, tick)

    local alpha = (1-tick)
    setColour(color[1], color[2], color[3], alpha)
    setLineWidth(lineThickness)
    local rad = math.max(0, self.radius - dSign*lineThickness)
    love.graphics.circle(self.type, self.x, self.y, rad)
end




umg.on("state:gameUpdate", function(dt)
    for _,sw in ipairs(shockwaveSet) do
        update(sw, dt)
        if sw.isFinished then
            shockwaveSet:remove(sw)
        end
    end
end)




umg.on("rendering:drawEffects", function(camera)
    local dimension = camera:getDimension()
    for _,sw in ipairs(shockwaveSet) do
        local dim = spatial.getDimension(sw.dimension)
        if dim == dimension then
            draw(sw)
        end
    end
end)




local function shockwave(options)
    local sw = setDefaultValues(options)
    shockwaveSet:add(sw)
end



return shockwave

