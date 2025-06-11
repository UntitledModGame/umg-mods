local W,H = 3000,1500
local minsize = 40
local DELTA = (minsize * lp.constants.WORLD_SLOT_DISTANCE) / 2

if client then

local cosmicBackground = require("client.cosmicBackground")

function cosmicBg()
    return cosmicBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfStar = 100,

        backgroundColor = objects.Color("#" .. "FF0A091F"),
        starColorMin = {2, 4, 6},
    })
end

function heavenlyBg()
    return cosmicBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfStar = 100,

        backgroundColor = objects.Color("#" .. "FF2B140A"),
        starColorMin = {7, 4, 4},
    })
end

end

local function returnTrue()
    return true
end

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:cosmicBackground", {
    name = "Cosmic (by: skahd)",
    constructor = cosmicBg,
    isUnlocked = returnTrue,
    icon = "cosmic_background",
    fogColor = objects.Color("#" .. "FF060413")
})

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:heavenlyBackground", {
    name = "Heavenly Dimension (by: skahd)",
    constructor = heavenlyBg,
    isUnlocked = returnTrue,
    icon = "heavenly_background",
    fogColor = objects.Color("#" .. "FF180606")
})