local loc = localization.localize

local constructor = nil

if client then

local FunkyBackground = require("client.FunkyBackground")

local W,H = 3000,1500
-- HACK: kinda hacky, hardcode plot offset
local minsize = math.min(lp.main.constants.WORLD_PLOT_SIZE[1], lp.main.constants.WORLD_PLOT_SIZE[2])
local DELTA = (minsize * lp.constants.WORLD_SLOT_DISTANCE) / 2

function constructor()
    return FunkyBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
    
        nodeDistance = 25,
        nodeHueShift = 25,
        nodeValueShfit = 0,
        nodeSaturationShift = 0,
        noisePeriod = 200,
        color = objects.Color(0.62,0.2,0.93),
        noiseSpeed = 0.1,
    })
end

end

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:funky_background", {
    name = loc("Funky Background"),
    description = loc("Acid Trip"),
    constructor = constructor
})
