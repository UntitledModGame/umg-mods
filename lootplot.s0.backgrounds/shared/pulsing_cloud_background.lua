local constructor = nil

if client then

local PulsingCloudBackground = require("client.PulsingCloudBackground")

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

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:pulsing_cloud_background", {
    name = localization.localize("Cloud Background"),
    constructor = constructor,
    icon = "pulsing_cloud_background"
})