
local sunsetCtor = nil
local cherryCtor = nil
local skyCtor = nil
local tealCtor = nil
local abstractCtor = nil


if client then

local CloudBackground = require("client.CloudBackground")

local W,H = 3000,1500
-- HACK: kinda hacky, hardcode plot offset
local minsize = 40
local DELTA = (minsize * lp.constants.WORLD_SLOT_DISTANCE) / 2

function skyCtor()
    return CloudBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfClouds = 100,

        backgroundColor = objects.Color("#FF8FA1FF"),
        cloudColor = objects.Color("#FF8FA1FF"),
    })
end

function cherryCtor()
    return CloudBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfClouds = 100,

        backgroundColor = objects.Color("#FFFFC2EE"),
        cloudColor = objects.Color("#FFFFC2EE"),
    })
end

function sunsetCtor()
    return CloudBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfClouds = 100,

        backgroundColor = objects.Color("#FFFFCA91"),
        cloudColor = objects.Color("#FFFFCA91"),
        -- backgroundColor = objects.Color("#FFFFE8C8"),
        -- cloudColor = objects.Color("#FFFFE8C8"),
    })
end

function tealCtor()
    return CloudBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfClouds = 100,

        backgroundColor = objects.Color("#FF88FCD7"),
        cloudColor = objects.Color("#FFBFFFEB"),
    })
end


function abstractCtor()
    return CloudBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfClouds = 0,

        backgroundColor = objects.Color("#FFFFFFFF"),
        cloudColor = objects.Color("#FFFFFFFF"),
    })
end

end

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:sky_cloud_background", {
    name = localization.localize("Cloud Background"),
    constructor = skyCtor,
    icon = "sky_cloud_background"
})

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:cherry_background", {
    name = localization.localize("Cherry Background"),
    constructor = cherryCtor,
    icon = "cherry_cloud_background"
})

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:sunset_background", {
    name = localization.localize("Sunset Background"),
    constructor = sunsetCtor,
    icon = "sunset_cloud_background"
})

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:teal_background", {
    name = localization.localize("Teal Background"),
    constructor = tealCtor,
    icon = "teal_cloud_background"
})

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:abstract_background", {
    name = localization.localize("Abstract Background"),
    constructor = abstractCtor,
    icon = "abstract_background",
    fogColor = objects.Color(64/255,0.97,0.98)
})


