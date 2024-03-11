
local function applyDefaults(psys)
    psys:setParticleLifetime(0.4, 0.7)
    psys:setDirection(-math.pi/2)
    psys:setSpeed(60,70)
    psys:setEmissionRate(0)
    psys:setSpread(math.pi/2)
    psys:setEmissionArea("uniform", 6,6)
    psys:setSpin(-5,5)
    psys:setRotation(-2*math.pi, 2*math.pi)
    psys:setRelativeRotation(false)
    psys:setLinearAcceleration(0, 250)
end



local DEFAULT_BUFFER_SIZE = 50

local function newParticleSystem(images, buffer_size)
    if #images == 0 then
        error("Attempted to define a particleSystem with no particle images")
    end
    local psys = love.graphics.newParticleSystem(client.atlas.image, buffer_size or DEFAULT_BUFFER_SIZE)
    local buffer = objects.Array()
    local _,pW,pH
    for _,img in ipairs(images) do
        local quad = client.assets.images[img]
        _,_,pW,pH = quad:getViewport()
        assert(quad, "Non existant image: " .. tostring(img))
        buffer:add(quad)
    end

    psys:setQuads(buffer)
    applyDefaults(psys)
    psys:setOffset(pW/2, pH/2)
    
    return psys
end



return newParticleSystem
