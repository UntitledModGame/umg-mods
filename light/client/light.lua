


local DEFAULT = {0.55,0.55,0.7,1} --{0.85,0.85,0.85}


local defaultLighting = DEFAULT


local light = {}

local lightGroup = umg.group("x","y","light")


local light_image, W, H


local LEIGH = 20

local canvas = love.graphics.newCanvas(
    love.graphics.getWidth() + LEIGH,
    love.graphics.getHeight() + LEIGH
)



umg.on("@resize", function(w,h)
    canvas = love.graphics.newCanvas(
        love.graphics.getWidth() + LEIGH,
        love.graphics.getHeight() + LEIGH
    )
end)



local DEFAULT_SIZE = 50
local DEFAULT_COLOR = {1,1,1}



local function drawLight(ent, globalModifier)
    local l = ent.light
    local size = l.size or DEFAULT_SIZE
    if l.image then
        error("Custom light images aren't supported yet")
    end
    local sizeMod = umg.ask("light:getLightSizeMultiplier", ent) or 1
    local scale = (size / W) * sizeMod * globalModifier

    local c = l.color or DEFAULT_COLOR
    local mult = (l.dark and -1) or 1
    love.graphics.setColor(c[1]*mult ,c[2]*mult ,c[3]*mult ,(c[4] or 1))

    love.graphics.draw(light_image, ent.x, ent.y, ent.rot, scale, scale, W/2, H/2)
end


local function resetLighting(dimension)
    local overseerEnt = dimensions.getOverseer(dimension)
    local col = overseerEnt.lighting or defaultLighting
    local r,g,b = col[1], col[2], col[3]
    local r1,g1,b1 = umg.ask("light:getGlobalLightingModifier")
    r1 = r1 or 0
    g1 = g1 or 0
    b1 = b1 or 0
    love.graphics.clear(r+r1, g+g1, b+b1)
end



local function setupCanvas(camera)
    love.graphics.push("all")
    love.graphics.setCanvas(canvas)
    local dimension = camera:getDimension()

    -- reset lights:
    resetLighting(dimension)

    local globalModifier = umg.ask("light:getGlobalLightSizeMultiplier") or 1

    -- display all lights:
    for _, ent in ipairs(lightGroup) do
        -- TODO: Check if entity is on the screen
        -- (its hard because of canvases, lg.getWidth() is not available)
        local dim = dimensions.getDimension(ent)
        if dim == dimension then
            drawLight(ent, globalModifier)
        end
    end

    love.graphics.setCanvas()
    love.graphics.pop()
end


local function drawCanvas()
    love.graphics.push("all")
    love.graphics.origin()

    love.graphics.setColor(1,1,1,1)
    love.graphics.setCanvas()
    love.graphics.setBlendMode("multiply", "premultiplied")
    love.graphics.draw(canvas)
    love.graphics.pop()
end


umg.on("rendering:drawEffects", function(camera)
    setupCanvas(camera)
    local mode, alphamode = love.graphics.getBlendMode( )
    drawCanvas()
    love.graphics.setBlendMode(mode, alphamode)
end)




function light.setDefaultLighting(color)
    defaultLighting = color
end



function light.setLightImage(imgName)
    light_image = love.graphics.newImage(imgName)
    W, H = light_image:getDimensions()
end


--[[
    important note:
    This image is stored OUTSIDE of assets/images,
    which means that it won't be loaded by the texture atlas.
]]
local DEFAULT_LIGHT_IMAGE = "lights/default_light.png"

light.setLightImage(DEFAULT_LIGHT_IMAGE)




return light
