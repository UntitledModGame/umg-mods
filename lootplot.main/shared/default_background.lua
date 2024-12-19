local CONST = require("shared.lpmain_const")

local constructor = nil

if client then

local PulsingCloudBackground = require("client.backgrounds.PulsingCloudBackground")

local W,H = 3000,1500
-- HACK: kinda hacky, hardcode plot offset
local minsize = math.min(lp.main.constants.WORLD_PLOT_SIZE[1], lp.main.constants.WORLD_PLOT_SIZE[2])
local DELTA = (minsize * lp.constants.WORLD_SLOT_DISTANCE) / 2

function constructor()
    return PulsingCloudBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfClouds = 100
    })
end

end

lp.backgrounds.registerBackground(CONST.DEFAULT_BG_NAME, {
    name = localization.localize("Cloud Background"),
    constructor = constructor,
    icon = "default_background"
})
