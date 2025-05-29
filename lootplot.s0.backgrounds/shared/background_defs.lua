
local loc = localization.localize


local sunsetCtor = nil
local cherryCtor = nil
local defaultCtor = nil
local popcornCtor = nil
local tealCtor = nil
local voidCtor = nil
local starCtor = nil
local aquaCtor = nil
local crimsonCtor = nil



-- Backgrounds are unlocked in order of definition,
-- Each time you win a game, you unlock a new background.
local UNLOCK_WIN_COUNT = 1

local function winToUnlock()
    local currWinCount = UNLOCK_WIN_COUNT -- capture closure
    UNLOCK_WIN_COUNT = UNLOCK_WIN_COUNT + 1
    local function isUnlocked()
        if lp.getWinCount() >= currWinCount then
            return true
        end
        return false
    end
    return isUnlocked
end




if client then

local CloudBackground = require("client.CloudBackground")


local W,H = 3000,1500
-- HACK: kinda hacky, hardcode plot offset
local minsize = 40
local DELTA = (minsize * lp.constants.WORLD_SLOT_DISTANCE) / 2

function defaultCtor()
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


function popcornCtor()
    return CloudBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfClouds = 100,

        backgroundColor = objects.Color("#" .. "FFFDFAA3"),
        cloudColor = objects.Color("#" .. "FFFDFAA3"),
    })
end


function voidCtor()
    return CloudBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfClouds = 0,

        backgroundColor = objects.Color("#FF370354"),
        cloudColor = objects.Color("#FF370354"),
    })
end


function tealCtor()
    return CloudBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfClouds = 100,

        backgroundColor = objects.Color("#FF53E2AF"),
        cloudColor = objects.Color("#FF53E2AF"),
    })
end


local StarBackground = require("client.StarBackground")
function starCtor()
    return StarBackground(3)
end


function aquaCtor()
    return CloudBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfClouds = 100,

        backgroundColor = objects.Color("#" .. "FF11FFF7"),
        cloudColor = objects.Color("#" .. "FF83FFFB"),
    })
end


function crimsonCtor()
    return CloudBackground({
        worldX = -W/2 + DELTA, worldY = -H/2 + DELTA,
        worldWidth = W, worldHeight = H,
        numberOfClouds = 0,

        backgroundColor = objects.Color("#" .. "FF400D21"),
        cloudColor = objects.Color("#" .. "FF400D21"),
    })
end




end

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:sky_cloud_background", {
    name = loc("Default"),
    constructor = defaultCtor,
    icon = "sky_cloud_background"
})

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:sunset_background", {
    name = loc("Sunset"),
    constructor = sunsetCtor,
    isUnlocked = winToUnlock(),
    icon = "sunset_cloud_background"
})

local STAR_FOG_COLOR
do
local R,G,B = 18, 0, 33
STAR_FOG_COLOR = {R/255, G/255, B/255}
end
lp.backgrounds.registerBackground("lootplot.s0.backgrounds:star_background", {
    name = loc("Star Background"),
    description = loc("Just stars"),
    constructor = starCtor,
    isUnlocked = winToUnlock(),
    icon = "star_background",
    fogColor = STAR_FOG_COLOR,
})



lp.backgrounds.registerBackground("lootplot.s0.backgrounds:cherry_background", {
    name = loc("Cherry"),
    constructor = cherryCtor,
    isUnlocked = winToUnlock(),
    icon = "cherry_cloud_background"
})

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:teal_background", {
    name = loc("Teal"),
    constructor = tealCtor,
    isUnlocked = winToUnlock(),
    icon = "teal_cloud_background"
})

lp.backgrounds.registerBackground("lootplot.s0.backgrounds:popcorn_background", {
    name = loc("Popcorn"),
    constructor = popcornCtor,
    isUnlocked = winToUnlock(),
    icon = "popcorn_background",
})


lp.backgrounds.registerBackground("lootplot.s0.backgrounds:void_background", {
    name = loc("Void"),
    constructor = voidCtor,
    isUnlocked = winToUnlock(),
    icon = "void_background",
    fogColor = objects.Color("#" .. "FF250732")
})


lp.backgrounds.registerBackground("lootplot.s0.backgrounds:aqua_background", {
    name = loc("Aqua"),
    constructor = aquaCtor,
    isUnlocked = winToUnlock(),
    icon = "aqua_cloud_background",
    fogColor = objects.Color("#" .. "FFB6FAFF")
})


lp.backgrounds.registerBackground("lootplot.s0.backgrounds:crimson_background", {
    name = loc("Crimson"),
    constructor = crimsonCtor,
    isUnlocked = winToUnlock(),
    fogColor = objects.Color("#" .. "FF0F0003"),
    icon = "crimson_background",
})


