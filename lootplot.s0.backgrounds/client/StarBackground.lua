---@class lootplot.s0.backgrounds.StarBackground: lootplot.backgrounds.IBackground
local StarBackground = objects.Class("lootplot.s0.backgrounds:StarBackground"):implement(lp.backgrounds.IBackground)

local RADIUS_X = 4000 -- negative and positive
local RADIUS_Y = 3000 -- negative and positive

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

---@param nlayers integer
function StarBackground:init(nlayers)
    local rng = love.math.newRandomGenerator(SEED)

    ---@type love.SpriteBatch[]
    self.layers = {}

    for _ = 1, nlayers or 3 do
        local nstars = RADIUS_X + RADIUS_Y
        local sb = love.graphics.newSpriteBatch(client.atlas:getTexture(), nstars)

        for _ = 1, nstars do
            local x = rng:random(-RADIUS_X, RADIUS_X)
            local y = rng:random(-RADIUS_Y, RADIUS_Y)
            sb:add(client.assets.images[STARS[rng:random(1, #STARS)]], x, y)
        end

        self.layers[#self.layers+1] = sb
    end
end

function StarBackground:draw(opacity)
    love.graphics.setColor(1, 1, 1, opacity * 0.8)
    local cam = camera.get()
    local cx, cy = cam:getPos()

    for l, sb in ipairs(self.layers) do
        local parallaxScale = 1 - (l / (#self.layers + 1))
        love.graphics.draw(sb, cx * parallaxScale, cy * parallaxScale, 0, 1 / (1 - l), 1 / (1 - l))
    end
end

return StarBackground
