---@class lootplot.s0.backgrounds.StarBackground: lootplot.backgrounds.IBackground
local StarBackground = objects.Class("lootplot.s0.backgrounds:StarBackground"):implement(lp.backgrounds.IBackground)

local RADIUS_X = 4000 -- negative and positive
local RADIUS_Y = 3000 -- negative and positive
local BACKGROUND_SIZE = 256

local STARS = {
    "blue_star",
    "buff_star_1",
    "deep_blue_star",
    "pink_star",
    "red_star",
    "small_yellow_star",
    "yellow_star"
}

local SEED = 12345

local function makeNoise(r, g, b, div, sx, sy)
    local imgNoise = love.image.newImageData(BACKGROUND_SIZE, BACKGROUND_SIZE)
    imgNoise:mapPixel(function(x, y)
        local n = love.math.simplexNoise(sx + x / div, sy + y / div)
        return r, g, b, n
    end)
    local img = love.graphics.newImage(imgNoise)
    img:setFilter("linear", "linear") -- forced linear filterinig
    return img
end

local COLORS = {
    objects.Color("#ff78eb36"), -- 78eb36
    objects.Color("#ffba36eb"), -- ba36eb
    objects.Color("#ffeb3636"), -- eb3636
}

---@param nlayers integer
function StarBackground:init(nlayers)
    local rng = love.math.newRandomGenerator(SEED)

    ---@type love.SpriteBatch[]
    self.layers = {}
    ---@type love.Texture[]
    self.noises = {}

    for i = 1, nlayers or 3 do
        local nstars = math.floor((RADIUS_X + RADIUS_Y) * 1.5)
        local sb = love.graphics.newSpriteBatch(client.atlas:getTexture(), nstars)

        for _ = 1, nstars do
            local x = rng:random(-RADIUS_X, RADIUS_X)
            local y = rng:random(-RADIUS_Y, RADIUS_Y)
            sb:add(client.assets.images[STARS[rng:random(1, #STARS)]], x, y)
        end

        self.layers[#self.layers+1] = sb

    end

    for _, c in ipairs(COLORS) do
        -- Make nebula background
        local ox = (rng:random() * 2 - 1) * 5000
        local oy = (rng:random() * 2 - 1) * 5000
        self.noises[#self.noises+1] = makeNoise(c[1], c[2], c[3], 300, ox, oy)
    end
end

function StarBackground:draw(opacity)
    love.graphics.setColor(1, 1, 1, opacity * 0.8)
    -- We need to draw the colored background at screen-space
    do
        love.graphics.push()
        love.graphics.origin()
        local x, y, w, h = 0,0,love.graphics.getDimensions()
        love.graphics.setColor(1, 1, 1, 0.3)
        for _, n in ipairs(self.noises) do
            love.graphics.draw(n, x, y, 0, w / BACKGROUND_SIZE, h / BACKGROUND_SIZE)
        end
        love.graphics.pop()
    end

    local cam = camera.get()
    local cx, cy = cam:getPos()

    love.graphics.setColor(1, 1, 1)
    for l, sb in ipairs(self.layers) do
        -- HACK:  DONT ask how this works, i shotgun debugged it
        local parallaxScale = (1.2 - ((l+1)/(#self.layers))/2)
        local len = #self.layers
        local opacityy = l/len
        love.graphics.setColor(1,1,1, opacityy)
        love.graphics.draw(sb, cx * parallaxScale, cy * parallaxScale, 0, 1, 1)
    end
end

return StarBackground
